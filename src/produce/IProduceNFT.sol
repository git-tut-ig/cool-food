// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {IERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {IERC721Metadata} from "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IProduct} from "./IProduct.sol";

/**
 * @title IProduceNFT
 * @notice ERC721-based interface for Produce NFTs which carry `ProductInfo` metadata and lifecycle events.
 */
interface IProduceNFT is IERC721, IERC721Metadata, IProduct {
    /**
     * @notice Emitted when a new token is minted for a party.
     * @param party The party address that initially owns the minted token.
     * @param tokenId The minted token id.
     * @param productInfo The product metadata associated with the token.
     */
    event Minted(address indexed party, uint256 indexed tokenId, ProductInfo productInfo);

    /**
     * @notice Emitted when a token transitions to `PRODUCED` status.
     */
    event Produced(uint256 indexed tokenId);

    /**
     * @notice Emitted when a token is marked spoiled.
     * @param originator The account that marked the token spoiled.
     * @param tokenId The token id marked spoiled.
     * @param reason Arbitrary bytes reason for off-chain indexing.
     */
    event Spoiled(address indexed originator, uint256 indexed tokenId, bytes reason);

    /**
     * @notice Emitted when a token is closed with a rating.
     */
    event Closed(uint256 indexed tokenId, ProductRating rating);

    /**
     * @notice Emitted when a token is closed without a rating.
     */
    event Closed(uint256 indexed tokenId);

    /**
     * @notice Emitted when a token is reported lost or damaged.
     */
    event LostOrDamaged(uint256 indexed tokenId);

    /**
     * @notice Lifecycle statuses for a Produce NFT.
     */
    enum Status {
        CREATED, // Minted, not yet attached to a sensor
        PRODUCED, // Product produced and packed. Sensor attached.
        CLOSED, // Product is delivered to end customer.
        LOST_DAMAGED // Product is lost or damaged.
    }

    /**
     * @notice Mints a new NFT for the specified product.
     * @param productInfo The product information to be associated with the NFT.
     * @param tokenURI Optional metadata URI for the token.
     * @return tokenId The ID of the newly minted NFT.
     * @custom:reverts ProduceNFT__InvalidProduct if provided `productInfo` is invalid (implementation-defined).
     */
    function mint(ProductInfo calldata productInfo, string calldata tokenURI) external returns (uint256 tokenId);

    /**
     * @notice Marks a product NFT as produced.
     * @param tokenId The ID of the NFT to mark as produced.
     * @custom:reverts ProduceNFT__NotOwner if the caller is not authorized to mark produced.
     */
    function produced(uint256 tokenId) external;

    /**
     * @notice Marks a product NFT as spoiled.
     * @param tokenId The ID of the NFT to mark as spoiled.
     * @param reason The reason for marking the NFT as spoiled.
     * @dev Reason is arbitrary bytes for off-chain indexing.
     */
    function markSpoiled(uint256 tokenId, bytes calldata reason) external;

    /**
     * @notice Close an order for `tokenId` without rating.
     * @param tokenId The token id to close.
     */
    function close(uint256 tokenId) external;

    /**
     * @notice Close an order for `tokenId` with a `ProductRating`.
     * @param tokenId The token id to close.
     * @param rating The `ProductRating` to attach.
     */
    function close(uint256 tokenId, ProductRating calldata rating) external;

    /**
     * @notice Mark a token as lost or damaged.
     * @param tokenId The token id to mark.
     */
    function lostOrDamaged(uint256 tokenId) external;

    /**
     * @notice Returns the status of a product NFT.
     * @param tokenId The ID of the NFT to query.
     * @return status The current status of the NFT.
     */
    function getStatus(uint256 tokenId) external view returns (Status);

    /**
     * @notice Returns the product metadata for `tokenId`.
     * @param tokenId The token id to query.
     * @return The `ProductInfo` struct associated with the token.
     */
    function getProductInfo(uint256 tokenId) external view returns (ProductInfo memory);
}
