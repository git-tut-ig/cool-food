// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

/// @title ISensor
/// @notice Types for a sensor that can be attached to produce NFTs.
interface ISensor {
    /// @notice Status of a sensor relative to a product/NFT.
    enum SensorStatus {
        NOT_ATTACHED, // NFT minted, but no sensor attached
        ACTIVE, // Sensor attached to the product
        INACTIVE // Sensor disactivate
    }

    /// @notice Lightweight sensor metadata stored on-chain.
    /// @param sensorId Unique short identifier for the sensor (application-level).
    /// @param status Current status of the sensor.
    struct Sensor {
        bytes16 sensorId;
        SensorStatus status;
    }
}
