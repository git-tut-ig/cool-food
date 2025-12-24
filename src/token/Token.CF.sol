// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {ITokenCF} from "./ITokenCF.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuardTransient} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuardTransient.sol";

/**
 * @title TokenCF
 * @notice A small, test-friendly ERC20 token used by the Cool Food project.
 * @dev Implements `ITokenCF` and extends OpenZeppelin `ERC20`. The contract exposes
 *      a `mint` helper without access controls for use in tests and deployment scripts.
 */
contract TokenCF is ITokenCF, ERC20, ReentrancyGuardTransient {
    /**
     * @notice Construct a new `TokenCF` instance.
     * @param name_ The token name (e.g. "CoolFood Token").
     * @param symbol_ The token symbol (e.g. "CF").
     */
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    /**
     * @notice Mint `amount` tokens to `to`.
     * @dev No access control is enforced here on purpose — this is intended for
     *      tests and controlled deployment scripts only. The function is marked
     *      `nonReentrant` and uses the internal `_mint` which emits the standard
     *      `Transfer` event defined by ERC20.
     * @param to Recipient of the minted tokens.
     * @param amount Number of tokens to mint (in token base units).
     */
    function mint(address to, uint256 amount) external nonReentrant {
        _mint(to, amount);
    }

    /**
     * @inheritdoc ITokenCF
     * @dev This implementation reads the current allowance and increases it by
     *      `addedValue` using `_approve`. The call is `nonReentrant` to guard
     *      against reentrancy in complex test scenarios.
     */
    function increaseAllowance(address spender, uint256 addedValue) external override nonReentrant {
        _approve(_msgSender(), spender, allowance(_msgSender(), spender) + addedValue);
    }
}

