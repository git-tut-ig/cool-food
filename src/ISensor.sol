// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface ISensor {
    enum SensorStatus {
        NOT_ATTACHED, // NFT minted, but no sensor attached
        ACTIVE, // Sensor attached to the product
        INACTIVE // Sensor disactivate
    }

    struct Sensor {
        bytes16 sensorId; // Unique identifier for the sensor
        SensorStatus status; // Current status of the sensor
    }
}
