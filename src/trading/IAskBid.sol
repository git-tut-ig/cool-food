// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IAskBid {
    struct Ask {
        uint256 askId;
        address seller;
        uint256 tokenId;
        AskStatus status;
    }

    struct AskParams {
        address seller;
        uint256 tokenId;
    }

    struct Bid {
        uint256 bidId;
        uint256 askId;
        address bidder;
        uint256 price;
        BidStatus status;
    }

    struct BidParams {
        uint256 askId;
        address bidder;
        uint256 price;
    }

    enum AskStatus {
        ACTIVE,
        CANCELLED,
        ACCEPTED
    }

    enum BidStatus {
        ACTIVE,
        CANCELLED,
        ACCEPTED,
        REJECTED
    }
}
