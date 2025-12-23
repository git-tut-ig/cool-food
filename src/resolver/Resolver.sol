// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {IResolver} from "./IResolver.sol";

contract Resolver is IResolver {
    mapping(bytes32 => address) private registry;

    event AddressSet(bytes32 indexed nameHash, string name, address addr);

    function setAddress(string calldata name, address addr) external {
        bytes32 h = keccak256(abi.encodePacked(name));
        registry[h] = addr;
        emit AddressSet(h, name, addr);
    }

    function getAddress(string calldata name) external view override returns (address) {
        return registry[keccak256(abi.encodePacked(name))];
    }

    function getAddressByHash(bytes32 nameHash) external view override returns (address) {
        return registry[nameHash];
    }
}
