// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IResolver {
    function getAddress(string calldata name) external view returns (address);
    function getAddressByHash(bytes32 nameHash) external view returns (address);

    // Allow setting an address for a name (no access control by design for deployment scripts and tests)
    function setAddress(string calldata name, address addr) external;
}
