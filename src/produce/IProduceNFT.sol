// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {IERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {IProduct} from "./IProduct.sol";

interface IProduceNFT is IERC721, IProduct {
    event Minted(address indexed party, uint256 indexed tokenId, ProductInfo productInfo);
    event Produced(uint256 indexed tokenId);
    event Spoiled(address indexed originator, uint256 indexed tokenId, bytes reason);
    event Closed(uint256 indexed tokenId, ProductRating rating);
    event Closed(uint256 indexed tokenId);
    event LostOrDamaged(uint256 indexed tokenId);

    enum Status {
        CREATED, // Minted, not yet attached to a sensor
        PRODUCED, // Product produced and packed. Sensor attached.
        CLOSED, // Product is delivered to end customer.
        LOST_DAMAGED // Product is lost or damaged.
    }

    /**
     * @notice Mints a new NFT for the specified product.
     * @param productInfo The product information to be associated with the NFT.
     * @return tokenId The ID of the newly minted NFT.
     */
    function mint(ProductInfo calldata productInfo, string calldata tokenURI) external returns (uint256 tokenId);

    function produced(uint256 tokenId) external;

    /**
     * @notice Marks a product NFT as spoiled.
     * @param tokenId The ID of the NFT to mark as spoiled.
     * @param reason The reason for marking the NFT as spoiled.
     * @dev TBD: Design reason format.
     */
    function markSpoiled(uint256 tokenId, bytes calldata reason) external;

    function close(uint256 tokenId) external;
    function close(uint256 tokenId, ProductRating calldata rating) external;
    function lostOrDamaged(uint256 tokenId) external;

    /**
     * @notice Returns the status of a product NFT.
     * @param tokenId The ID of the NFT to query.
     * @return status The current status of the NFT.
     */
    function getStatus(uint256 tokenId) external view returns (Status);
}
