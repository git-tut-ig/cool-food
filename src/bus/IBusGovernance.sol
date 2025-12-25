// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Subscription} from "../bus/IBus.sol";

interface IBusGovernance {
    function governanceSubscribe(address receiver, uint256 eventType) external returns (uint256 subscriptionId);
    function governanceSubscribe(address receiver, uint256[] calldata eventTypes)
        external
        returns (uint256 subscriptionId);

    function governanceSubscribe(address receiver, address emitter) external returns (uint256 subscriptionId);
    function governanceSubscribe(address receiver, address emitter, uint256 eventType)
        external
        returns (uint256 subscriptionId);
    function governanceSubscribe(address receiver, address emitter, uint256[] memory eventTypes)
        external
        returns (uint256 subscriptionId);

    function governanceGetSubscriptions(address receiver) external view returns (Subscription[] memory);

    function governanceUnsubscribe(address receiver, uint256 subscriptionId) external;
    function governanceUnsubscribeAll(address receiver) external;
}
