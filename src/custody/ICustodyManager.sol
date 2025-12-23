// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

/**
 * @title ICustodyManager
 * @notice Interface for managing custody records for produced items (NFTs).
 * @dev Implementations track current custody owner and a history of custody records
 *      identified by `tokenId`. The `correlationId` can be used by off-chain systems
 *      to correlate custody operations with external events.
 */
interface ICustodyManager {
    /**
     * @notice Emitted when custody is recorded for a token.
     * @param correlationId An external correlation id supplied by the caller (e.g., order id).
     * @param tokenId The id of the token (product) for which custody is recorded.
     * @param custodyOwner The address that is now the custodian of the token.
     * @param startTime Unix timestamp (seconds) marking when custody starts.
     */
    event CustodyAdded(uint256 indexed correlationId, uint256 indexed tokenId, address custodyOwner, uint40 startTime);

    /**
     * @notice A single custody record stored in the custody history for a token.
     * @param custodyOwner The address that held custody.
     * @param startTime Unix timestamp (seconds) when custody began.
     */
    struct Custody {
        address custodyOwner;
        uint40 startTime;
    }

    /**
     * @notice Record that `custodyOwner` takes custody of `tokenId` starting at `startTime`.
     * @dev `correlationId` is application-defined and useful for off-chain correlation.
     * @param tokenId The token id whose custody is being recorded.
     * @param custodyOwner The account receiving custody of the token.
     * @param startTime Unix timestamp (seconds) when custody starts.
     * @param correlationId External id used to correlate this custody record with off-chain systems.
     */
    function addCustody(uint56 tokenId, address custodyOwner, uint40 startTime, uint256 correlationId) external;

    /**
     * @notice Return the current custody owner for `tokenId`.
     * @param tokenId The token id to query.
     * @return custodyOwner The current custody owner's address, or `address(0)` if none recorded.
     */
    function getCurrentCustody(uint256 tokenId) external view returns (address custodyOwner);

    /**
     * @notice Return the custody history for `tokenId` in chronological order (earliest first).
     * @param tokenId The token id to query.
     * @return An array of `Custody` records.
     */
    function getCustodyHistory(uint256 tokenId) external view returns (Custody[] memory);
}
