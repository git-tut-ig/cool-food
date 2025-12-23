// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {ERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract ProduceNFT is IProduceNFT, ERC721 {}
