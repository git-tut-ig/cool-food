// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {IAskBid} from "./IAskBid.sol";

/**
 * @title ITradeNFT
 * @notice Marketplace contract for trading `ProduceNFT` tokens using the project token.
 * @dev Supports puts/asks, bidding, acceptance flows and safe ERC20 transfers.
 */
interface ITradeNFT is IAskBid {
    /**
     * @notice Errors thrown by `TradeNFT` implementations.
     */
    error ITradeNFT__NotOwner();
    error ITradeNFT__InvalidAsk();
    error ITradeNFT__InvalidBid();
    error ITradeNFT__NotBidder();
    error ITradeNFT__NotSeller();
    error ITradeNFT__NotActive();

    /**
     * @notice Emitted when an ask is created.
     */
    event AskPut(uint256 indexed askId, address indexed seller, uint256 indexed tokenId);

    /**
     * @notice Emitted when an ask is cancelled by the seller.
     */
    event AskCancel(uint256 indexed askId, address indexed seller, uint256 indexed tokenId);

    /**
     * @notice Emitted when a bid is created for an ask.
     */
    event BidPut(uint256 indexed askId, uint256 indexed bidId, address indexed bidder, uint256 price);

    /**
     * @notice Emitted when a bid is cancelled by the bidder.
     */
    event BidCancelled(uint256 indexed askId, uint256 indexed bidId, address indexed bidder);

    /**
     * @notice Emitted when a bid is accepted and transferred to seller.
     */
    event BidAgreed(uint256 indexed askId, uint256 indexed bidId, address indexed bidder, uint256 price);

    /**
     * @notice Emitted when a non-accepted active bid is rejected upon another bid acceptance.
     */
    event BidRejected(uint256 indexed askId, uint256 indexed bidId, address indexed bidder);

    /**
     * @notice Create an ask for `ask.tokenId` by `ask.seller`.
     * @param ask Parameters to create the ask (see `IAskBid` for `AskParams`).
     * @return askId The id of the created ask.
     */
    function createAsk(AskParams calldata ask) external returns (uint256 askId);

    /**
     * @notice Return ask details for `askId`.
     * @param askId The id of the ask to query.
     * @return The `Ask` struct for `askId`.
     */
    function getAsk(uint256 askId) external view returns (Ask memory);

    /**
     * @notice Cancel an active ask. Caller must be the seller.
     * @param askId The id of the ask to cancel.
     */
    function cancelAsk(uint256 askId) external;

    /**
     * @notice Place a bid on an ask. Caller must transfer tokens to the contract.
     * @param bid The bidding parameters (see `IAskBid` for `BidParams`).
     * @return bidId The id of the created bid.
     */
    function createBid(BidParams calldata bid) external returns (uint256 bidId);

    /**
     * @notice Return bid details for `bidId`.
     * @param bidId The id of the bid to query.
     * @return The `Bid` struct for `bidId`.
     */
    function getBid(uint256 bidId) external view returns (Bid memory);

    /**
     * @notice List bids for a given ask, excluding cancelled bids.
     * @param askId The ask id to list bids for.
     * @return An array of `Bid` structs for the ask.
     */
    function listBidsByAskId(uint256 askId) external view returns (Bid[] memory);

    /**
     * @notice List only active bids for a given ask.
     * @param askId The ask id to list active bids for.
     * @return An array of active `Bid` structs for the ask.
     */
    function listActiveBidsByAskId(uint256 askId) external view returns (Bid[] memory);

    /**
     * @notice Cancel an active bid. Caller must be the bidder.
     * @param bidId The id of the bid to cancel.
     */
    function cancelBid(uint256 bidId) external;

    /**
     * @notice Seller accepts a bid; NFT transfer and token settlement occur.
     * @param bidId The id of the bid being accepted.
     */
    function acceptBid(uint256 bidId) external;
}
