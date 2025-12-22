// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IProduct {
    struct ProductInfo {
        uint256 externalId;
        address partyId;
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
