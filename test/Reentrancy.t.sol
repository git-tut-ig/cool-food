// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Resolver} from "../src/resolver/Resolver.sol";
import {ProduceNFT} from "../src/produce/ProduceNFT.sol";
import {TradeNFT} from "../src/trading/TradeNFT.sol";
import {ITradeNFT} from "../src/trading/ITradeNFT.sol";
import {IAskBid} from "../src/trading/IAskBid.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IProduct} from "../src/produce/IProduct.sol";

contract MaliciousToken is ERC20 {
    address public target;
    uint256 public targetAsk;

    constructor() ERC20("Malicious", "MAL") {}

    function setTarget(address _t, uint256 a) external {
        target = _t;
        targetAsk = a;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        // Attempt re-entrancy into TradeNFT.createBid
        if (target != address(0)) {
            // This call should revert due to ReentrancyGuardTransient in TradeNFT
            ITradeNFT(target).createBid(IAskBid.BidParams({askId: targetAsk, bidder: from, price: amount}));
        }
        _transfer(from, to, amount);
        return true;
    }
}

contract ReentrantReceiver is IERC721Receiver {
    ProduceNFT public prod;

    constructor(ProduceNFT _prod) {
        prod = _prod;
    }

    // on receiving token, try to call mint again (re-entrancy)
    function onERC721Received(address, address, uint256, bytes calldata) external returns (bytes4) {
        IProduct.ProductInfo memory info =
            IProduct.ProductInfo({externalId: "re", producer: msg.sender, attributes: new IProduct.Attribute[](0)});
        // This should revert due to nonReentrant in ProduceNFT.mint
        prod.mint(info, "uri");
        return this.onERC721Received.selector;
    }

    function doMint() external {
        IProduct.ProductInfo memory info =
            IProduct.ProductInfo({externalId: "re", producer: address(this), attributes: new IProduct.Attribute[](0)});
        prod.mint(info, "uri");
    }
}

contract ReentrancyTest is Test {
    Resolver resolver;
    ProduceNFT produce;
    TradeNFT trade;
    MaliciousToken malToken;

    function setUp() public {
        resolver = new Resolver();
        produce = new ProduceNFT("Produce", "P");
        malToken = new MaliciousToken();

        // register token and produce in resolver
        resolver.setAddress("TokenCF", address(malToken));
        resolver.setAddress("ProduceNFT", address(produce));

        trade = new TradeNFT(address(resolver));
        resolver.setAddress("TradeNFT", address(trade));
    }

    function testCreateBid_reentrancyBlocked() public {
        address seller = address(0xBEEF);
        address buyer = address(0xCAFE);

        // mint tokens and approve
        malToken.mint(buyer, 1000);
        vm.prank(buyer);
        malToken.approve(address(trade), 1000);

        // seller mints produce and approves trade
        vm.prank(seller);
        IProduct.ProductInfo memory p =
            IProduct.ProductInfo({externalId: "foo", producer: seller, attributes: new IProduct.Attribute[](0)});
        uint256 tokenId = produce.mint(p, "uri");

        vm.prank(seller);
        produce.setApprovalForAll(address(trade), true);

        // create ask
        vm.prank(seller);
        trade.createAsk(IAskBid.AskParams({seller: seller, tokenId: tokenId}));

        // configure malicious token to attack during transferFrom
        malToken.setTarget(address(trade), 1);

        // Expect createBid to revert due to re-entrancy
        vm.prank(buyer);
        vm.expectRevert();
        trade.createBid(IAskBid.BidParams({askId: 1, bidder: buyer, price: 100}));

        // balance and bids unchanged
        assertEq(malToken.balanceOf(buyer), 1000);
        ITradeNFT.Bid memory b = trade.getBid(1);
        assertEq(b.bidId, uint256(0));
    }

    function testProduceMint_reentrancyBlocked() public {
        ReentrantReceiver recv = new ReentrantReceiver(produce);

        // Call doMint from receiver which will trigger onERC721Received re-entry
        vm.prank(address(recv));
        vm.expectRevert();
        recv.doMint();

        // Ensure no token minted (ownerOf should revert)
        vm.expectRevert();
        produce.ownerOf(1);
    }
}
