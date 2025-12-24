// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

/**
 * @title IPartyManagement
 * @notice Tracks membership of accounts in parties and exposes read helpers.
 * @dev Implementations may enforce access control for `addAccount`/`removeAccount`.
 */
interface IPartyManagement {
    /**
     * @dev Emitted when `account` is added to `partyId`.
     * @param partyId The id of the party the account was added to.
     * @param account The account that was added.
     */
    event AccountAdded(uint256 indexed partyId, address indexed account);

    /**
     * @dev Emitted when `account` is removed from `partyId`.
     * @param partyId The id of the party the account was removed from.
     * @param account The account that was removed.
     */
    event AccountRemoved(uint256 indexed partyId, address indexed account);

    /**
     * @notice Add an `account` to a party.
     * @dev Implementations should enforce permissions and emit `AccountAdded` on success.
     * @param partyId The id of the party to add the account to.
     * @param account The account address to add.
     * @custom:reverts PartyManagement__AlreadyMember if the account is already a member of the same party (implementation-defined).
     */
    function addAccount(uint256 partyId, address account) external;

    /**
     * @notice Remove an `account` from a party.
     * @dev Implementations should enforce permissions and emit `AccountRemoved` on success.
     * @param partyId The id of the party to remove the account from.
     * @param account The account address to remove.
     * @custom:reverts PartyManagement__NotMember if the account is not a member of `partyId` (implementation-defined).
     */
    function removeAccount(uint256 partyId, address account) external;

    /**
     * @notice Get the party id for an `account`.
     * @param account The account to query.
     * @return partyId The id of the party the account belongs to, or `0` if none (implementation-defined).
     */
    function getParty(address account) external view returns (uint256 partyId);

    /**
     * @notice Get all accounts in a party.
     * @param partyId The id of the party to query.
     * @return accounts An array of addresses that are members of the given party.
     */
    function getAccounts(uint256 partyId) external view returns (address[] memory accounts);
}
