// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

struct Parameter {
    string key;
    uint256 value;
    uint8 decimals;
}

struct Measurement {
    bytes16 id;
    bytes16 sensorId;
    uint256 start;
    uint256 end;
    string uri;
}

struct Event {
    bytes16 Id;
    bytes16 sensorId;
    uint16 eventType;
    uint256 timestamp;
    bytes data;
}

interface ISensor {
    event SensorCreated(bytes16 indexed sensorId, Parameter[] parameters);

    function createSensor(bytes16 sensorId, Parameter[] calldata parameters) external;
    function listSensorParameters(bytes16 sensorId) external view returns (Parameter[] memory);

    // Sensor Events
    function addEvent(Event calldata sensorEvent) external;
    function batchAddEvent(Event[] calldata sensorEvents) external;
    function getEvent(bytes16 eventId) external view returns (Event memory);
    function batchGetEvent(bytes16[] calldata eventIds) external view returns (Event[] memory);
    //function listEventsBySensorId(bytes16 sensorId) external view returns (Event[] memory);
    //function listEventsBySensorIdAndType(bytes16 sensorId, uint16 eventType) external view returns (Event[] memory);

    // Sensor measurements
    function addMeasurement(Measurement calldata measurement) external;
    function batchAddMeasurement(Measurement[] calldata measurements) external;
    function getMeasurement(bytes16 measurementId) external view returns (Measurement memory);
    function batchGetMeasurement(bytes16[] calldata measurementIds) external view returns (Measurement[] memory);
    //function listMeasurementBySensorId(bytes16 sensorId) external view returns (Measurement[] memory);
    //function listMeasurementBySensorAndDate(bytes16 sensorId, uint256 start, uint256 end)
    //    external
    //    view
    //    returns (Measurement[] memory);
    //function getLastMeasurementBySensorId(bytes16 sensorId) external view returns (Measurement memory);
}
