// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

/**
 * @title IResolver
 * @notice Simple name -> address resolver used to locate system contracts by string name.
 * @dev Implementations provide read helpers by name and by precomputed name hash.
 */
interface IResolver {
    /**
     * @notice Get the address registered under `name`.
     * @param name The human-readable name used for lookup.
     * @return The contract address registered for `name`, or address(0) if none.
     */
    function getAddress(string calldata name) external view returns (address);

    /**
     * @notice Get the address registered under a precomputed name hash.
     * @param nameHash The keccak256 hash of the name.
     * @return The contract address registered for `nameHash`, or address(0) if none.
     */
    function getAddressByHash(bytes32 nameHash) external view returns (address);

    /**
     * @notice Register or update the address for a name.
     * @dev No access control enforced in the interface; implementations may restrict callers.
     * @param name The human-readable name to register.
     * @param addr The address to associate with `name`.
     */
    function setAddress(string calldata name, address addr) external;
}
