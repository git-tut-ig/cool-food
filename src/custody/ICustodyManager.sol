// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {IArbitrageConsumer} from "../arbitrage/IArbitrageConsumer.sol";

/**
 * @title ICustodyManager
 * @dev Interface for custody management.
 * @dev TBD: externalID usage for retrieval, update, etc.
 */
interface ICustodyManager is IArbitrageConsumer {
    event CustodyAdded(uint256 indexed correlationId, uint256 indexed tokenId, address custodyOwner, uint40 startTime);

    struct Custody {
        address custodyOwner;
        uint40 startTime;
    }

    function addCustody(uint56 tokenId, address custodyOwner, uint40 startTime, uint256 correlationId) external;

    function getCurrentCustody(uint256 tokenId) external view returns (address custodyOwner);
    function getCustodyHistory(uint256 tokenId) external view returns (Custody[] memory);
}
