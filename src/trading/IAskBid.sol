// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

/**
 * @title IAskBid
 * @notice Shared types used by the TradeNFT marketplace: Ask/Bid structs, params and statuses.
 */
interface IAskBid {
    /**
     * @notice Represents an Ask Order put by a seller for a specific NFT.
     * @param askId Unique ask identifier.
     * @param seller Address of the token owner placing the ask.
     * @param tokenId The NFT token id being offered.
     * @param status Current `AskStatus` for the ask.
     */
    struct Ask {
        uint256 askId;
        address seller;
        uint256 tokenId;
        AskStatus status;
    }

    /**
     * @notice Parameters required to create an `Ask Order`.
     * @param seller Address that will be the seller of the ask.
     * @param tokenId NFT token id to list.
     */
    struct AskParams {
        address seller;
        uint256 tokenId;
    }

    /**
     * @notice Represents a Bid Order put on an `Ask`.
     * @param bidId Unique bid identifier.
     * @param askId The ask this bid targets.
     * @param bidder Address placing the bid.
     * @param price Price offered (in project token smallest unit).
     * @param status Current `BidStatus` for the bid.
     */
    struct Bid {
        uint256 bidId;
        uint256 askId;
        address bidder;
        uint256 price;
        BidStatus status;
    }

    /**
     * @notice Parameters required to create a `Bid Order`.
     * @param askId The ask id to target.
     * @param bidder Address placing the bid.
     * @param price Price offered.
     */
    struct BidParams {
        uint256 askId;
        address bidder;
        uint256 price;
    }

    /**
     * @notice Status for an `Ask Order`.
     */
    enum AskStatus {
        ACTIVE,
        CANCELLED,
        ACCEPTED
    }

    /**
     * @notice Status for a `Bid Order`.
     */
    enum BidStatus {
        ACTIVE,
        CANCELLED,
        ACCEPTED,
        REJECTED
    }
}
