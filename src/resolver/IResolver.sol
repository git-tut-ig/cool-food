// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IResolver {
    function getAddress(string calldata name) external view returns (address);
    function getAddressByHash(bytes32 nameHash) external view returns (address);
}
