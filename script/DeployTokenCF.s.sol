// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Script} from "lib/forge-std/src/Script.sol";
import {TokenCF} from "../src/token/Token.CF.sol";
import {IResolver} from "../src/resolver/IResolver.sol";

contract DeployTokenCF is Script {
    // Former run renamed to deploy for direct invocation from tests
    function deploy(address resolverAddr) public returns (address tokenAddr) {
        TokenCF token = new TokenCF("CoolToken", "CF");
        tokenAddr = address(token);
        IResolver(resolverAddr).setAddress("TokenCF", tokenAddr);
    }

    // Entrypoint used by `forge script` to broadcast and collect env vars
    function run() public returns (address tokenAddr) {
        // Example: allow overriding resolver address through env var RESOLVER
        address resolverAddr = vm.envAddress("RESOLVER");
        vm.startBroadcast();
        tokenAddr = deploy(resolverAddr);
        vm.stopBroadcast();
    }
}
