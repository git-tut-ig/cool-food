// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface ITradeNFT {
    event AskPut(uint256 indexed askId, address indexed seller, uint256 indexed tokenId);
    event AskCancel(uint256 indexed askId, address indexed seller, uint256 indexed tokenId);

    event BidPut(uint256 indexed bidId, address indexed bidder, uint256 indexed askId, uint256 price);
    event BidCancelled(uint256 indexed bidId, Bid bid);

    event BidAgreed(uint256 indexed bidId, Bid bid);
    event BidRejected(uint256 indexed bidId, Bid bid);

    struct Ask {
        uint256 askId;
        address seller;
        uint256 tokenId;
    }

    struct Bid {
        uint256 bidId;
        address bidder;
        uint256 price;
    }

    function putAsk(Ask calldata ask) external returns (uint256 askId);
    function getAsk(uint256 askId) external view returns (Ask memory);
    function cancelAsk(uint256 askId) external;
    function getBids(uint256 askId) external view returns (Bid[] memory);
    function agreedBid(uint256 askId, uint256 bidId) external;

    function putBid(uint256 askId, Bid calldata bid) external returns (uint256 bidId);
    function cancelBid(uint256 askId, uint256 bidId) external;
}
