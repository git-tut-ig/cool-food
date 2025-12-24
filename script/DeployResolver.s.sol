// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Script} from "lib/forge-std/src/Script.sol";
import {Resolver} from "../src/resolver/Resolver.sol";

contract DeployResolver is Script {
    // Former run() renamed to deploy() so tests can call it directly without broadcast
    function deploy() public returns (address resolverAddr) {
        Resolver resolver = new Resolver();
        resolverAddr = address(resolver);
    }

    // Entrypoint used by `forge script` which handles broadcasting and env vars
    function run() public returns (address resolverAddr) {
        vm.startBroadcast();
        resolverAddr = deploy();
        vm.stopBroadcast();
    }
}
