pragma solidity ^0.5.0;

import "./common/property/Property.sol";

contract Issuance {
    using Property for Property.Properties;

    Property.Properties private _properties;


    function loadProperties(bytes memory data) public {
        _properties.load(data);
    }

    function saveProperties() public view returns (bytes memory data) {
        data = _properties.save();
    }

    function setStringProperty(string memory key, string memory value) public {
        _properties.setStringValue(key, value);
    }

    function getStringProperty(string memory key) public view returns (string memory data) {
        data = _properties.getStringValue(key);
    }

    function setIntProperty(string memory key, int value) public {
        _properties.setIntValue(key, value);
    }

    function getIntProperty(string memory key) public view returns (int data) {
        data = _properties.getIntValue(key);
    }

    function setBoolProperty(string memory key, bool value) public {
        _properties.setBoolValue(key, value);
    }

    function getBoolProperty(string memory key) public view returns (bool data) {
        data = _properties.getBoolValue(key);
    }

    function setUintProperty(string memory key, uint value) public {
        _properties.setUintValue(key, value);
    }

    function getUintProperty(string memory key) public view returns (uint data) {
        data = _properties.getUintValue(key);
    }

    function addStringElement(string memory key, string memory element) public {
        string[] memory list;
        // TODO Any optimization on it?
        if (_properties.containsKey(key)) {
            string[] memory tmp = _properties.getStringArrayValue(key);
            list = new string[](tmp.length + 1);
            for (uint i = 0; i < tmp.length; i++) {
                list[i] = tmp[i];
            }
            list[tmp.length] = element;
        } else {
            list = new string[](1);
            list[0] = element;
        }

        _properties.setStringArrayValue(key, list);
    }

    function getStringElement(string memory key, uint index) public view returns (string memory element) {
        require(_properties.containsKey(key), "The key does not exist");
        string[] memory tmp = _properties.getStringArrayValue(key);
        require(tmp.length > index, "The index out of bound");

        element = tmp[index];
    }
}