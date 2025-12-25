// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Script} from "lib/forge-std/src/Script.sol";
import {Bus} from "../src/bus/Bus.sol";

contract DeployTradeNFT is Script {
    address private constant ZERO = address(0);

    // Former run renamed to deploy for direct invocation from tests
    function deploy(address resolverAddr) public returns (address busAddr) {
        Bus bus = new Bus();
        busAddr = address(bus);
        if (resolverAddr != ZERO) {
            IResolver(resolverAddr).setAddress("Bus", busAddr);
        }
    }

    // Entrypoint used by `forge script` which will broadcast
    function run() public returns (address busAddr) {
        address resolverAddr = vm.envAddress("RESOLVER");
        vm.startBroadcast();
        busAddr = deploy(resolverAddr);
        vm.stopBroadcast();
    }
}
