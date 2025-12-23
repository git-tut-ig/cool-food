// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {IPartyManagement} from "./IPartyManagement.sol";

/// @notice Basic implementation of `IPartyManagement` with owner-only administration.
contract PartyManagement is IPartyManagement {
    error PartyManagement__NotOwner(address caller);
    error PartyManagement__ZeroAddress();
    error PartyManagement__InvalidPartyId(uint256 partyId);
    error PartyManagement__AlreadyAssigned(address account);
    error PartyManagement__NotMember(uint256 partyId, address account);

    address public owner;

    mapping(address => uint256) private _account2party;
    mapping(uint256 => address[]) private _party2accounts;
    mapping(address => uint256) private _indexOfAccount;

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        if (msg.sender != owner) revert PartyManagement__NotOwner(msg.sender);
    }

    /// @notice Set deployer as owner
    constructor() {
        owner = msg.sender;
    }

    /// @notice Transfer ownership to `newOwner`
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert PartyManagement__ZeroAddress();
        owner = newOwner;
    }

    /**
     * @inheritdoc IPartyManagement
     */
    function addAccount(uint256 partyId, address account) external onlyOwner {
        if (account == address(0)) revert PartyManagement__ZeroAddress();
        if (partyId == 0) revert PartyManagement__InvalidPartyId(partyId);
        if (_account2party[account] != 0) revert PartyManagement__AlreadyAssigned(account);
        _party2accounts[partyId].push(account);
        _indexOfAccount[account] = _party2accounts[partyId].length - 1;
        _account2party[account] = partyId;

        emit AccountAdded(partyId, account);
    }

    /**
     * @inheritdoc IPartyManagement
     */
    function removeAccount(uint256 partyId, address account) external onlyOwner {
        if (_account2party[account] != partyId) revert PartyManagement__NotMember(partyId, account);

        // Swap-remove from array
        uint256 idx = _indexOfAccount[account];
        uint256 last = _party2accounts[partyId].length - 1;
        if (idx != last) {
            address swapped = _party2accounts[partyId][last];
            _party2accounts[partyId][idx] = swapped;
            _indexOfAccount[swapped] = idx;
        }
        _party2accounts[partyId].pop();

        // Clear membership
        delete _indexOfAccount[account];
        _account2party[account] = 0;

        emit AccountRemoved(partyId, account);
    }

    /**
     * @inheritdoc IPartyManagement
     */
    function getParty(address account) external view returns (uint256 partyId) {
        return _account2party[account];
    }

    /**
     * @inheritdoc IPartyManagement
     */
    function getAccounts(uint256 partyId) external view returns (address[] memory accounts) {
        return _party2accounts[partyId];
    }
}
