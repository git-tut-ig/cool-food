// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {IBus, Event, Subscription, IEventReciever} from "./IBus.sol";

/**
 * @title Bus contract
 * @notice TODO: implement IBusGovernance
 * @notice TODO: implement permissions
 *
 */
contract Bus is IBus {
    error Bus__NotImplemented();

    event BusReceiverRevert(address indexed receiver, address indexed emitter, uint256 indexed eventType);

    struct SubscriptionInternal {
        address emitter;
        mapping(uint256 => bool) eventTypes;
    }

    address private constant ANY_EMITTER = address(0);

    // starts with 1 index, to support receiver index
    address[] private receivers;
    mapping(address => uint256) receiverIndex;
    mapping(address => SubscriptionInternal[]) private receiver2subscription;

    constructor() {
        receivers.push(address(0));
        // Initialization code here
    }

    // Implement the IBus interface methods here
    function emitEvent(Event memory e) external override {
        for (uint256 i = 1; i < receivers.length; i++) {
            address receiver = receivers[i];
            SubscriptionInternal[] storage subscriptions = receiver2subscription[receiver];

            if (isMatch(e, subscriptions)) {
                try IEventReciever(receiver).onEvent(e) {}
                catch {
                    emit BusReceiverRevert(receiver, e.emitter, e.eventType);
                }
            }
        }
    }

    /**
     * @dev Subscribe for a single eventType
     * @dev Adds new filter. If filter already exists, does nothing
     */
    function subscribe(uint256 eventType) external override returns (uint256 subscriptionId) {}

    function subscribe(uint256[] memory eventTypes) external override returns (uint256 subscriptionId) {}

    function subscribe(address emitter) external override returns (uint256 subscriptionId) {}

    function subscribe(address emitter, uint256 eventType) external override returns (uint256 subscriptionId) {
        uint256[] memory events = new uint256[](1);
        events[0] = eventType;
        return _subscribe(emitter, events);
    }

    function subscribe(address emitter, uint256[] memory eventTypes)
        external
        override
        returns (uint256 subscriptionId)
    {
        return _subscribe(emitter, eventTypes);
    }

    function _subscribe(address emitter, uint256[] memory eventTypes) internal returns (uint256 subscriptionId) {
        revert Bus__NotImplemented();
    }

    function getSubscriptions() external view returns (Subscription[] memory) {}

    function unsubscribe(uint256 subscriptionId) external override {}
    function unsubscribeAll() external override {}

    function isMatch(Event memory e, SubscriptionInternal[] storage s) internal view virtual returns (bool) {
        for (uint256 i = 0; i < s.length; i++) {
            SubscriptionInternal storage subscription = s[i];

            if (subscription.emitter == ANY_EMITTER || subscription.emitter == e.emitter) {
                if (subscription.eventTypes[e.eventType]) {
                    return true;
                }
            }
        }

        return false;
    }
}
