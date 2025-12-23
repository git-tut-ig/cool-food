// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {ITokenCF} from "./ITokenCF.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuardTransient} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuardTransient.sol";

contract TokenCF is ITokenCF, ERC20, ReentrancyGuardTransient {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    /// @notice Mint tokens to an address. No access control by design for tests/deploy scripts.
    function mint(address to, uint256 amount) external nonReentrant {
        // Effects
        _mint(to, amount);
        // No external interactions
    }

    /// @notice increaseAllowance helper
    function increaseAllowance(address spender, uint256 addedValue) external override nonReentrant {
        _approve(_msgSender(), spender, allowance(_msgSender(), spender) + addedValue);
    }

    /// @dev permissive transferFrom: allow the caller to move their own balance without prior approval
    function transferFrom(address from, address to, uint256 amount)
        public
        virtual
        override(ERC20, IERC20)
        nonReentrant
        returns (bool)
    {
        if (_msgSender() == from) {
            _transfer(from, to, amount);
            return true;
        }
        return super.transferFrom(from, to, amount);
    }
}

