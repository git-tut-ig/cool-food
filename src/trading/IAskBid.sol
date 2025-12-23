// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IAskBid {
    /// @notice Represents an ask put by a seller for a specific NFT.
    struct Ask {
        uint256 askId;
        address seller;
        uint256 tokenId;
        AskStatus status;
    }

    /// @notice Parameters required to create an `Ask`.
    struct AskParams {
        address seller;
        uint256 tokenId;
    }

    /// @notice Represents a bid put on an `Ask`.
    struct Bid {
        uint256 bidId;
        uint256 askId;
        address bidder;
        uint256 price;
        BidStatus status;
    }

    /// @notice Parameters required to create a `Bid`.
    struct BidParams {
        uint256 askId;
        address bidder;
        uint256 price;
    }

    /// @notice Status for an `Ask`.
    enum AskStatus {
        ACTIVE,
        CANCELLED,
        ACCEPTED
    }

    /// @notice Status for a `Bid`.
    enum BidStatus {
        ACTIVE,
        CANCELLED,
        ACCEPTED,
        REJECTED
    }
}
