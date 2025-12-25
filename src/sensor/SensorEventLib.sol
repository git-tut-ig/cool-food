// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {ISensor, Measurement} from "./ISensor.sol";

library SensorEventLib {
    // Need to think and enumerate possible sensor events
    //

    struct Activated {
        bytes16 Id;
        bytes16 sensorId;
        uint16 eventType;
        uint256 timestamp;
    }

    struct Spoiled {
        bytes16 Id;
        bytes16 sensorId;
        uint16 eventType;
        uint256 timestamp;

        bytes16[] events;
        bytes16[] measurements;
    }
}
