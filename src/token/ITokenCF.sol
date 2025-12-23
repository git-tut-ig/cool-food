// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITokenCF is IERC20 {
    function increaseAllowance(address spender, uint256 addedValue) external;
}

