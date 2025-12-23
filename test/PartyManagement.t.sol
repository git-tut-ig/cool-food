// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {PartyManagement} from "../src/deprecated/PartyManagement.sol";

contract PartyManagementTest is Test {
    PartyManagement party;

    function setUp() public {
        party = new PartyManagement();
    }

    function testAddAndGet() public {
        address acct = address(0xBEEF);
        party.addAccount(1, acct);
        assertEq(party.getParty(acct), 1);
        address[] memory members = party.getAccounts(1);
        assertEq(members.length, 1);
        assertEq(members[0], acct);
    }

    function testRemove() public {
        address acct = address(0xCAFE);
        party.addAccount(2, acct);
        assertEq(party.getParty(acct), 2);
        party.removeAccount(2, acct);
        assertEq(party.getParty(acct), 0);
        address[] memory members = party.getAccounts(2);
        assertEq(members.length, 0);
    }

    function testOnlyOwnerCannotBeBypassed() public {
        address acct = address(0xDEAD);
        vm.prank(address(0x1234));
        vm.expectRevert();
        party.addAccount(3, acct);
    }
}
