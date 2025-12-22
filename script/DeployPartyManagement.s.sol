// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "forge-std/Script.sol";
import "../src/deprecated/PartyManagement.sol";

contract DeployPartyManagement is Script {
    function run() external returns (address) {
        vm.startBroadcast();
        PartyManagement pm = new PartyManagement();
        vm.stopBroadcast();
        return address(pm);
    }
}
