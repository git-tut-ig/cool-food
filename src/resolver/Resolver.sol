// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {IResolver} from "./IResolver.sol";

/// @title Resolver
/// @notice A tiny on-chain name resolver mapping string names (via hash) to addresses.
/// @dev Intended for use in tests and lightweight deployments where a full ENS-like
///      registry would be overkill.
contract Resolver is IResolver {
    mapping(bytes32 => address) private registry;

    /// @notice Emitted when an address is set for a name.
    /// @param nameHash The keccak256 hash of the name.
    /// @param name The original name string supplied.
    /// @param addr The address associated with the name.
    event AddressSet(bytes32 indexed nameHash, string name, address addr);

    /// @notice Set or update the address for `name`.
    /// @param name The human-readable name to register.
    /// @param addr The address to associate with `name`.
    function setAddress(string calldata name, address addr) external {
        bytes32 h = keccak256(abi.encodePacked(name));
        registry[h] = addr;
        emit AddressSet(h, name, addr);
    }

    /// @inheritdoc IResolver
    function getAddress(string calldata name) external view override returns (address) {
        return registry[keccak256(abi.encodePacked(name))];
    }

    /// @inheritdoc IResolver
    function getAddressByHash(bytes32 nameHash) external view override returns (address) {
        return registry[nameHash];
    }
}
