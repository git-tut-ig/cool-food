// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

/**
 * @title IProduct
 * @notice Shared product metadata types used by produce NFTs.
 */
interface IProduct {
    /**
     * @notice Basic product metadata used by produce NFTs.
     * @param externalId External identifier (e.g., SKU or supply-chain id).
     * @param producer Address of the producer organization or party.
     * @param attributes Arbitrary key/value attributes attached to the product.
     */
    struct ProductInfo {
        string externalId;
        address producer;
        Attribute[] attributes;
    }

    /**
     * @notice Arbitrary name/value attribute attached to a product.
     * @param name Attribute name.
     * @param value Attribute value.
     */
    struct Attribute {
        string name;
        string value;
    }

    /**
     * @notice Rating provided for a product when closing an order.
     * @param rater The account that supplied the rating.
     * @param rating Numeric rating value (application-defined scale).
     */
    struct ProductRating {
        address rater;
        uint256 rating;
    }
}
