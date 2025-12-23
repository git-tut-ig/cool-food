// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Script} from "lib/forge-std/src/Script.sol";
import {TradeNFT} from "../src/trading/TradeNFT.sol";
import {IResolver} from "../src/resolver/IResolver.sol";

contract DeployTradeNFT is Script {
    // Former run renamed to deploy for direct invocation from tests
    function deploy(address resolverAddr) public returns (address tradeAddr) {
        TradeNFT trade = new TradeNFT(resolverAddr);
        tradeAddr = address(trade);
        IResolver(resolverAddr).setAddress("TradeNFT", tradeAddr);
    }

    // Entrypoint used by `forge script` which will broadcast
    function run() public returns (address tradeAddr) {
        address resolverAddr = vm.envAddress("RESOLVER");
        vm.startBroadcast();
        tradeAddr = deploy(resolverAddr);
        vm.stopBroadcast();
    }
}
