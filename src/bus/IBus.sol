// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

/**
 * @dev Event struct is used to represent an event in the system.
 * @param hash The hash of the event.
 * @param eventType The type of the event.
 * @param emitter The address of the emitter of the event.
 * @param data The data associated with the event.
 */
struct Event {
    bytes32 hash;
    uint256 eventType;
    address emitter;
    bytes data;
}

struct Subscription {
    uint256 id;
    address emitter;
    uint256[] eventTypes;
}

interface IEventReciever {
    function onEvent(Event memory e) external;
}

/**
 * @dev All Subscribe functions are cummulative and additive.
 */
interface IBus {
    function emitEvent(Event memory e) external;

    /**
     * @dev Subscribe for a single eventType
     * @dev Adds new filter. If filter already exists, does nothing
     */
    function subscribe(uint256 eventType) external returns (uint256 subscriptionId);
    function subscribe(uint256[] memory eventTypes) external returns (uint256 subscriptionId);

    function subscribe(address emitter) external returns (uint256 subscriptionId);
    function subscribe(address emitter, uint256 eventType) external returns (uint256 subscriptionId);
    function subscribe(address emitter, uint256[] memory eventTypes) external returns (uint256 subscriptionId);

    function getSubscriptions() external view returns (Subscription[] memory);

    function unsubscribe(uint256 subscriptionId) external;
    function unsubscribeAll() external;
}
