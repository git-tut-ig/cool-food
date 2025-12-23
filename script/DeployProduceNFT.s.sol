// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Script} from "lib/forge-std/src/Script.sol";
import {ProduceNFT} from "../src/produce/ProduceNFT.sol";
import {IResolver} from "../src/resolver/IResolver.sol";

contract DeployProduceNFT is Script {
    // Former run renamed to deploy for test usage
    function deploy(address resolverAddr) public returns (address produceAddr) {
        ProduceNFT produce = new ProduceNFT("CoolProduce", "CP");
        produceAddr = address(produce);
        IResolver(resolverAddr).setAddress("ProduceNFT", produceAddr);
    }

    // Entrypoint used by `forge script`
    function run() public returns (address produceAddr) {
        address resolverAddr = vm.envAddress("RESOLVER");
        vm.startBroadcast();
        produceAddr = deploy(resolverAddr);
        vm.stopBroadcast();
    }
}
