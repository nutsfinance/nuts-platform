pragma solidity ^0.5.0;

import "./access/WriterRole.sol";
import "./ProtoBufRuntime.sol";

/**
 * @title A generic data storage contract.
 * Supported values include: String, address, int, uint, bool.
 * Complex types should look for serialization/deserialization frameworks.
 */
contract UnifiedStorage is WriterRole {
    mapping(string => string) private _stringData;
    mapping(string => bytes) private _bytesData;
    mapping(string => address) private _addressData;
    mapping(string => uint) private _uintData;
    mapping(string => int) private _intData;
    mapping(string => bool) private _boolData;

    function getString(string memory key) public view onlyWriter returns (string memory) {
        return _stringData[key];
    }

    function setString(string memory key, string memory value) public onlyWriter {
       _stringData[key] = value;
    }

    function getBytes(string memory key) public view onlyWriter returns (bytes memory) {
        return ProtoBufRuntime.decodeStorage(_bytesData[key]);
    }

    function setBytes(string memory key, bytes memory value) public onlyWriter {
        ProtoBufRuntime.encodeStorage(_bytesData[key], value);
    }

    function getAddress(string memory key) public view onlyWriter returns (address) {
        return _addressData[key];
    }

    function setAddress(string memory key, address value) public onlyWriter {
       _addressData[key] = value;
    }

    function getUint(string memory key) public view onlyWriter returns (uint) {
        return _uintData[key];
    }

    function setUint(string memory key, uint value) public onlyWriter {
       _uintData[key] = value;
    }

    function getInt(string memory key) public view onlyWriter returns (int) {
        return _intData[key];
    }

    function setInt(string memory key, int value) public onlyWriter {
       _intData[key] = value;
    }

    function getBool(string memory key) public view onlyWriter returns (bool) {
        return _boolData[key];
    }

    function setBool(string memory key, bool value) public onlyWriter {
       _boolData[key] = value;
    }
}
