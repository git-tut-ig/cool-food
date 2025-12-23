// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {IAskBid} from "./IAskBid.sol";

interface ITradeNFT is IAskBid {
    event AskPut(uint256 indexed askId, address indexed seller, uint256 indexed tokenId);
    event AskCancel(uint256 indexed askId, address indexed seller, uint256 indexed tokenId);

    event BidPut(uint256 indexed askId, uint256 indexed bidId, address indexed bidder, uint256 price);
    event BidCancelled(uint256 indexed askId, uint256 indexed bidId, address indexed bidder);

    event BidAgreed(uint256 indexed askId, uint256 indexed bidId, address indexed bidder, uint256 price);
    event BidRejected(uint256 indexed askId, uint256 indexed bidId, address indexed bidder);

    function createAsk(AskParams calldata ask) external returns (uint256 askId);
    function getAsk(uint256 askId) external view returns (Ask memory);
    function cancelAsk(uint256 askId) external;

    function createBid(BidParams calldata bid) external returns (uint256 bidId);
    function getBid(uint256 bidId) external view returns (Bid memory);
    function listBidsByAskId(uint256 askId) external view returns (Bid[] memory);
    function listActiveBidsByAskId(uint256 askId) external view returns (Bid[] memory);
    function cancelBid(uint256 bidId) external;
    function acceptBid(uint256 bidId) external;
}
