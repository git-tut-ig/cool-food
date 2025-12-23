// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IProduct {
    struct ProductInfo {
        string externalId;
        address producer;
        Attribute[] attributes;
    }

    struct Attribute {
        string name;
        string value;
    }

    struct ProductRating {
        address rater;
        uint256 rating;
    }
}
