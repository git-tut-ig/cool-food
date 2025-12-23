// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IProduct {
    /// @notice Basic product metadata used by produce NFTs.
    struct ProductInfo {
        string externalId;
        address producer;
        Attribute[] attributes;
    }

    /// @notice Arbitrary name/value attribute attached to a product.
    struct Attribute {
        string name;
        string value;
    }

    /// @notice Rating provided for a product when closing an order.
    struct ProductRating {
        address rater;
        uint256 rating;
    }
}
