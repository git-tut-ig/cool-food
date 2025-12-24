// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ITokenCF
 * @notice Interface extension for test helper token used in the Cool Food project.
 * @dev Extends the standard `IERC20` with a convenience `increaseAllowance` helper.
 */
interface ITokenCF is IERC20 {
    /**
     * @notice Atomically increases the allowance granted to `spender` by the caller.
     * @dev Convenience to avoid the approve -> increase pattern in tests. Implementations
     *      should follow the ERC20 allowance semantics and emit an `Approval` event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) external;
}

