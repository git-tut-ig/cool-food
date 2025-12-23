// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {ITradeNFT} from "./ITradeNFT.sol";
import {IResolver} from "../resolver/IResolver.sol";
import {ITokenCF} from "../token/ITokenCF.sol";
import {IProduceNFT} from "../produce/IProduceNFT.sol";

import {ReentrancyGuardTransient} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuardTransient.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract TradeNFT is ITradeNFT, ReentrancyGuardTransient {
    using SafeERC20 for IERC20;
    IResolver public resolver;

    uint256 private askCounter;
    uint256 private bidCounter;

    mapping(uint256 => Ask) private asks;
    mapping(uint256 => Bid) private bids;
    mapping(uint256 => uint256[]) private bidsByAsk;

    error NotOwner();
    error InvalidAsk();
    error InvalidBid();
    error NotBidder();
    error NotSeller();
    error NotActive();

    constructor(address resolverAddr) {
        resolver = IResolver(resolverAddr);
    }

    function _token() internal view returns (ITokenCF) {
        return ITokenCF(resolver.getAddress("TokenCF"));
    }

    function _produce() internal view returns (IProduceNFT) {
        return IProduceNFT(resolver.getAddress("ProduceNFT"));
    }

    function createAsk(AskParams calldata ask) external override returns (uint256 askId) {
        // Caller must be seller
        if (msg.sender != ask.seller) revert NotSeller();
        // Token must exist and seller must be the owner
        if (_produce().ownerOf(ask.tokenId) != ask.seller) revert NotOwner();

        askCounter++;
        askId = askCounter;
        asks[askId] = Ask({askId: askId, seller: ask.seller, tokenId: ask.tokenId, status: AskStatus.ACTIVE});
        emit AskPut(askId, ask.seller, ask.tokenId);
    }

    function getAsk(uint256 askId) external view override returns (Ask memory) {
        return asks[askId];
    }

    function cancelAsk(uint256 askId) external override {
        Ask storage a = asks[askId];
        if (a.seller != msg.sender) revert NotSeller();
        if (a.status != AskStatus.ACTIVE) revert NotActive();
        a.status = AskStatus.CANCELLED;
        emit AskCancel(askId, msg.sender, a.tokenId);
    }

    function createBid(BidParams calldata bid) external override nonReentrant returns (uint256 bidId) {
        // Checks
        Ask memory askObj = asks[bid.askId];
        if (askObj.askId == 0 || askObj.status != AskStatus.ACTIVE) revert InvalidAsk();
        if (bid.price == 0) revert InvalidBid();
        if (bid.bidder != msg.sender) revert NotBidder();

        // Effects (CEI: update state before external interactions)
        bidCounter++;
        bidId = bidCounter;
        bids[bidId] =
            Bid({bidId: bidId, askId: bid.askId, bidder: bid.bidder, price: bid.price, status: BidStatus.ACTIVE});
        bidsByAsk[bid.askId].push(bidId);

        // Interaction: transfer tokens into contract using SafeERC20
        IERC20(address(_token())).safeTransferFrom(msg.sender, address(this), bid.price);

        emit BidPut(bid.askId, bidId, bid.bidder, bid.price);
    }

    function getBid(uint256 bidId) external view override returns (Bid memory) {
        return bids[bidId];
    }

    function listBidsByAskId(uint256 askId) external view override returns (Bid[] memory) {
        uint256[] memory ids = bidsByAsk[askId];
        // return bids excluding cancelled bids (they should not appear in active listing)
        uint256 count = 0;
        for (uint256 i = 0; i < ids.length; i++) {
            if (bids[ids[i]].status != BidStatus.CANCELLED) count++;
        }
        Bid[] memory out = new Bid[](count);
        uint256 idx = 0;
        for (uint256 i = 0; i < ids.length; i++) {
            Bid memory b = bids[ids[i]];
            if (b.status != BidStatus.CANCELLED) {
                out[idx++] = b;
            }
        }
        return out;
    }

    function listActiveBidsByAskId(uint256 askId) external view override returns (Bid[] memory) {
        uint256[] memory ids = bidsByAsk[askId];
        uint256 count = 0;
        for (uint256 i = 0; i < ids.length; i++) {
            if (bids[ids[i]].status == BidStatus.ACTIVE) count++;
        }
        Bid[] memory out = new Bid[](count);
        uint256 idx = 0;
        for (uint256 i = 0; i < ids.length; i++) {
            Bid memory b = bids[ids[i]];
            if (b.status == BidStatus.ACTIVE) {
                out[idx++] = b;
            }
        }
        return out;
    }

    function cancelBid(uint256 bidId) external override nonReentrant {
        Bid storage b = bids[bidId];
        if (b.bidId == 0) revert InvalidBid();
        if (b.bidder != msg.sender) revert NotBidder();
        if (b.status != BidStatus.ACTIVE) revert NotActive();
        b.status = BidStatus.CANCELLED;
        // Refund using SafeERC20
        IERC20(address(_token())).safeTransfer(b.bidder, b.price);
        emit BidCancelled(b.askId, b.bidId, b.bidder);
    }

    function acceptBid(uint256 bidId) external override nonReentrant {
        Bid storage b = bids[bidId];
        if (b.bidId == 0) revert InvalidBid();
        if (b.status != BidStatus.ACTIVE) revert NotActive();
        Ask storage a = asks[b.askId];
        if (a.seller != msg.sender) revert NotSeller();
        if (a.status != AskStatus.ACTIVE) revert NotActive();

        // Effects first (CEI): mark accepted to avoid races
        b.status = BidStatus.ACCEPTED;
        a.status = AskStatus.ACCEPTED;

        // Transfer NFT from seller to bidder - seller must have approved this contract
        IProduceNFT prod = _produce();
        address seller = a.seller;
        uint256 tokenId = a.tokenId;
        prod.transferFrom(seller, b.bidder, tokenId);

        // Pay seller only the accepted bid price using SafeERC20
        IERC20(address(_token())).safeTransfer(seller, b.price);
        emit BidAgreed(b.askId, b.bidId, b.bidder, b.price);

        // Refund and reject remaining active bids
        uint256[] storage ids = bidsByAsk[b.askId];
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            if (id == bidId) continue;
            Bid storage other = bids[id];
            if (other.status == BidStatus.ACTIVE) {
                other.status = BidStatus.REJECTED;
                IERC20(address(_token())).safeTransfer(other.bidder, other.price);
                emit BidRejected(b.askId, other.bidId, other.bidder);
            }
        }
    }
}

