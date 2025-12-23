// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {PartyManagement} from "../src/deprecated/PartyManagement.sol";

contract PartyManagementBranchesTest is Test {
    PartyManagement party;

    address other = address(0x1234);

    function setUp() public {
        party = new PartyManagement();
    }

    function testTransferOwnership_zeroReverts() public {
        vm.expectRevert();
        party.transferOwnership(address(0));
    }

    function testTransferOwnership_and_newOwnerCanAct() public {
        // transfer to `other`
        party.transferOwnership(other);
        // now current test contract is not owner; calls should revert
        vm.expectRevert();
        party.addAccount(10, address(0x1));

        // calls from new owner succeed
        vm.prank(other);
        party.addAccount(10, address(0x1));
        assertEq(party.getParty(address(0x1)), 10);
    }

    function testAdd_invalids_and_alreadyAssigned() public {
        // zero account
        vm.expectRevert();
        party.addAccount(1, address(0));

        // zero partyId
        vm.expectRevert();
        party.addAccount(0, address(0x2));

        // normal add then double-add should revert (already assigned)
        party.addAccount(2, address(0x3));
        vm.expectRevert();
        party.addAccount(2, address(0x3));
    }

    function testRemove_notMemberReverts() public {
        // remove when not a member
        vm.expectRevert();
        party.removeAccount(5, address(0x9));
    }

    function testSwapRemoval_updatesIndexes() public {
        address a = address(0x10);
        address b = address(0x11);
        // add two accounts to same party
        party.addAccount(7, a);
        party.addAccount(7, b);
        address[] memory membersBefore = party.getAccounts(7);
        assertEq(membersBefore.length, 2);

        // remove first element (index 0) to trigger swap path
        party.removeAccount(7, a);
        address[] memory membersAfter = party.getAccounts(7);
        assertEq(membersAfter.length, 1);
        // remaining member should be b
        assertEq(membersAfter[0], b);
        // b's party should still be 7
        assertEq(party.getParty(b), 7);
    }

    function testEvents_emitted_onAddAndRemove() public {
        address acct = address(0x55);
        // basic smoke to ensure events don't revert and branch executed
        party.addAccount(8, acct);
        party.removeAccount(8, acct);
    }
}
