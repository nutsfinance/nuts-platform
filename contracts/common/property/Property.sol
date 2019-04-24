pragma solidity ^0.5.0;

import "../seriality/BytesToTypes.sol";
import "../seriality/TypesToBytes.sol";
import "../seriality/SizeOf.sol";
import "../util/StringUtil.sol";

/**
 * Core library to handle state serialization/deserialization
 * All states are serialied into bytes to persist in unified storage
 * and deserialize to properties while in use.
 */
library Property {

    /**
     * An internal data structure to store the property key-val pair
     */
    struct Entry {
        bytes key;
        bytes value;
    }

    /**
     * An external data structure to store the property data
     * Note: The data index starts with 1 to check the existing of property key
     */
    struct Properties {
        mapping(bytes => uint)  indices;    // Mapping: Property key -> Property data array index
        Entry[] data;                       // Array: Actual property data
    }

    /**
     * Common API functions
     */
    
    /**
     * Check whether a given property key exists
     * Note that the index starts with 1 to help check key existence
     */
    function containsKey(Properties storage properties, string memory key) internal view returns (bool) {
        return properties.indices[bytes(key)] > 0;
    }

    modifier keyExist(Properties storage properties, string memory key) {
        require(containsKey(properties, key), "Key does not exist");
        _;
    }

    function clear(Properties storage properties) internal {
        // Clears the mapping
        for (uint i = 0; i < properties.data.length; i++) {
            delete properties.indices[properties.data[i].key];
        }

        // Clears the data
        properties.data.length = 0;
    }

    /**
     * Important function to parse custom parameters
     * Note: Currently only string and uint parameters are supported.
     * Note: Parameters are of the format: aaa=bbb&ccc=ddd&ee=11
     */
    function parseParameters(Properties storage properties, string memory parameters) internal {
        // Clears the data
        clear(properties);

        uint start = 0;
        uint mid = 0;

        bytes memory data = bytes(parameters);
        for (uint i = 0; i < data.length; i++) {
            if (data[i] == "=") {
                mid = i;
            } else if (data[i] == "&") {
                ( bytes memory key, bytes memory value ) = getParameterPair(data, start, mid, i);

                start = i + 1;
                if (StringUtil.isUint(value)) {
                    uint uintValue = StringUtil.stringToUint(value);
                    setUintValue(properties, string(key), uintValue);
                } else {
                    setBytesValue(properties, string(key), value);
                }
            }
        }

        ( bytes memory key, bytes memory value ) = getParameterPair(data, start, mid, data.length);
        if (StringUtil.isUint(value)) {
            uint uintValue = StringUtil.stringToUint(value);
            setUintValue(properties, string(key), uintValue);
        } else {
            setBytesValue(properties, string(key), value);
        }
    }

    function getParameterPair(bytes memory data, uint start, uint mid, uint end) pure internal returns (bytes memory key, bytes memory value) {
        key = new bytes(mid - start);
        value = new bytes(end - mid - 1);

        for (uint j = start; j < mid; j++) {
            key[j - start] = data[j];
        }

        for (uint k = mid + 1; k < end; k++) {
            value[k - mid - 1] = data[k];
        }
    }


    /**
     * Deserialize properties from bytes
     */
    function load(Properties storage properties, bytes memory data) internal {
        // Clears the data
        clear(properties);

        uint offset = data.length;
        uint index = 1;
        while (offset > 0) {
            bytes memory key = new bytes(BytesToTypes.getStringSize(offset, data));
            BytesToTypes.bytesToString(offset, data, key);
            offset -= BytesToTypes.getStringSize(offset, data);

            bytes memory value = new bytes(BytesToTypes.getStringSize(offset, data));
            BytesToTypes.bytesToString(offset, data, value);
            offset -= BytesToTypes.getStringSize(offset, data);
            
            properties.data.push(Entry(key, value));
            properties.indices[key] = index;
            index += 1;
        }
    }

    /**
     * Serialize properties to bytes
     */
    function save(Properties storage properties) internal view returns (bytes memory data) {
        uint size = 0;
        for (uint i = 0; i < properties.data.length; i++) {            
            size += SizeOf.sizeOfString(properties.data[i].key);
            size += SizeOf.sizeOfString(properties.data[i].value);
        }

        data = new bytes(size);
        uint offset = size;
        for (uint i = 0; i < properties.data.length; i++) {
            TypesToBytes.stringToBytes(offset, properties.data[i].key, data);
            offset -= SizeOf.sizeOfString(properties.data[i].key);

            TypesToBytes.stringToBytes(offset, properties.data[i].value, data);
            offset -= SizeOf.sizeOfString(properties.data[i].value);
        }
    }

    /**
     * Type-specific API functions for value types
     */
    function getBytesValue(Properties storage properties, string memory key) internal view keyExist(properties, key) returns (bytes memory value) {
        value = properties.data[properties.indices[bytes(key)] - 1].value;
    }

    function setBytesValue(Properties storage properties, string memory key, bytes memory value) internal {
        uint index = properties.indices[bytes(key)];
        // New key
        if (index == 0) {
            properties.data.push(Entry(bytes(key), value));
            properties.indices[bytes(key)] = properties.data.length;
        } else {
            properties.data[index - 1] = Entry(bytes(key), value);
        }
    }

    function getStringValue(Properties storage properties, string memory key) internal view keyExist(properties, key) returns (string memory value) {
        bytes memory data = getBytesValue(properties, key);
        value = string(data);
    }

    function setStringValue(Properties storage properties, string memory key, string memory value) internal {
        setBytesValue(properties, key, bytes(value));
    }

    function getIntValue(Properties storage properties, string memory key) internal view keyExist(properties, key) returns (int value) {
        bytes memory data = getBytesValue(properties, key);
        value = BytesToTypes.bytesToInt256(data.length, data);
    }

    function setIntValue(Properties storage properties, string memory key, int value) internal {
        bytes memory data = new bytes(32);
        TypesToBytes.intToBytes(32, value, data);
        setBytesValue(properties, key, data);
    }

    // Note: This is not the most efficient way to store bool; better to store it using 1 byte
    // Currently implement using uint due to the limit of BytesToTypes.bytesToBool
    // TODO Implement it with mstore8 and mload8
    function getBoolValue(Properties storage properties, string memory key) internal view keyExist(properties, key) returns (bool value) {
        uint data = getUintValue(properties, key);
        value = data == 1;
    }

    function setBoolValue(Properties storage properties, string memory key, bool value) internal {
        setUintValue(properties, key, value ? 1 : 0);
    }

    function getUintValue(Properties storage properties, string memory key) internal view keyExist(properties, key) returns (uint value) {
        bytes memory data = getBytesValue(properties, key);
        value = BytesToTypes.bytesToUint256(data.length, data);
        // Note: The bytes data might be smaller than 32 bytes!
        // value = StringUtil.stringToUint(string(data));
    }

    function setUintValue(Properties storage properties, string memory key, uint value) internal {
        bytes memory data = new bytes(32);
        TypesToBytes.uintToBytes(32, value, data);
        setBytesValue(properties, key, data);
    }

    function getAddressValue(Properties storage properties, string memory key) internal view keyExist(properties, key) returns (address value) {
        bytes memory data = getBytesValue(properties, key);
        value = StringUtil.bytesToAddress(data);
    }

    function setAddressValue(Properties storage properties, string memory key, address value) internal {
        setStringValue(properties, key, StringUtil.addressToString(value));
    }

    /**
     * Type-specific API functions for arrays
     */
    function getBytesArrayValue(Properties storage properties, string memory key) internal view keyExist(properties, key) returns (bytes[] memory value) {
        bytes memory data = getBytesValue(properties, key);
        uint offset = data.length;
        uint length = BytesToTypes.bytesToUint256(offset, data);
        offset -= 32;
        value = new bytes[](length);

        for (uint i = 0; i < length; i++) {
            bytes memory entry = new bytes(BytesToTypes.getStringSize(offset, data));
            BytesToTypes.bytesToString(offset, data, entry);
            offset -= BytesToTypes.getStringSize(offset, data);

            value[i] = entry;
        }
    }

    function setBytesArrayValue(Properties storage properties, string memory key, bytes[] memory value) internal {
        uint size = 32;
        for (uint i = 0; i < value.length; i++) {
            size += SizeOf.sizeOfString(value[i]);
        }

        bytes memory data = new bytes(size);
        uint offset = size;
        TypesToBytes.uintToBytes(offset, value.length, data);
        offset -= 32;

        for (uint i = 0; i < value.length; i++) {
            TypesToBytes.stringToBytes(offset, value[i], data);
            offset -= SizeOf.sizeOfString(value[i]);
        }

        setBytesValue(properties, key, data);
    }

    function getStringArrayValue(Properties storage properties, string memory key) internal view keyExist(properties, key) returns (string[] memory value) {
        bytes memory data = getBytesValue(properties, key);
        uint offset = data.length;
        uint length = BytesToTypes.bytesToUint256(offset, data);
        offset -= 32;
        value = new string[](length);

        for (uint i = 0; i < length; i++) {
            bytes memory entry = new bytes(BytesToTypes.getStringSize(offset, data));
            BytesToTypes.bytesToString(offset, data, entry);
            offset -= SizeOf.sizeOfString(entry);

            value[i] = string(entry);
        }
    }

    function setStringArrayValue(Properties storage properties, string memory key, string[] memory value) internal {
        uint size = 32;
        for (uint i = 0; i < value.length; i++) {
            size += SizeOf.sizeOfString(bytes(value[i]));
        }

        bytes memory data = new bytes(size);
        uint offset = size;
        TypesToBytes.uintToBytes(offset, value.length, data);
        offset -= 32;

        for (uint i = 0; i < value.length; i++) {
            TypesToBytes.stringToBytes(offset, bytes(value[i]), data);
            offset -= SizeOf.sizeOfString(bytes(value[i]));
        }

        setBytesValue(properties, key, data);
    }

    function getIntArrayValue(Properties storage properties, string memory key) internal view keyExist(properties, key) returns (int[] memory value) {
        bytes memory data = getBytesValue(properties, key);
        uint offset = data.length;
        uint length = BytesToTypes.bytesToUint256(offset, data);
        offset -= 32;
        value = new int[](length);

        for (uint i = 0; i < length; i++) {
            value[i] = BytesToTypes.bytesToInt256(offset, data);
            offset -= 32;
        }
    }

    function setIntArrayValue(Properties storage properties, string memory key, int[] memory value) internal {
        uint size = 32 * (value.length + 1);

        bytes memory data = new bytes(size);
        uint offset = size;
        TypesToBytes.uintToBytes(offset, value.length, data);
        offset -= 32;

        for (uint i = 0; i < value.length; i++) {
            TypesToBytes.intToBytes(offset, value[i], data);
            offset -= 32;
        }

        setBytesValue(properties, key, data);
    }

    function getUintArrayValue(Properties storage properties, string memory key) internal view keyExist(properties, key) returns (uint[] memory value) {
        bytes memory data = getBytesValue(properties, key);
        uint offset = data.length;
        uint length = BytesToTypes.bytesToUint256(offset, data);
        offset -= 32;
        value = new uint[](length);

        for (uint i = 0; i < length; i++) {
            value[i] = BytesToTypes.bytesToUint256(offset, data);
            offset -= 32;
        }
    }

    function setUintArrayValue(Properties storage properties, string memory key, uint[] memory value) internal {
        uint size = 32 * (value.length + 1);

        bytes memory data = new bytes(size);
        uint offset = size;
        TypesToBytes.uintToBytes(offset, value.length, data);
        offset -= 32;

        for (uint i = 0; i < value.length; i++) {
            TypesToBytes.uintToBytes(offset, value[i], data);
            offset -= 32;
        }

        setBytesValue(properties, key, data);
    }

    /**
     * Utility functions
     */

    function getStringOrDefault(Property.Properties storage properties, string memory key, string memory defaultValue) internal view returns (string memory) {
        return containsKey(properties, key) ? getStringValue(properties, key) : defaultValue;
    }

    function getUintOrDefault(Property.Properties storage properties, string memory key, uint defaultValue) internal view returns (uint) {
        return containsKey(properties, key) ? getUintValue(properties, key) : defaultValue;
    }

    function getIntOrDefault(Property.Properties storage properties, string memory key, int defaultValue) internal view returns (int) {
        return containsKey(properties, key) ? getIntValue(properties, key) : defaultValue;
    }

    function getAddressOrDefault(Property.Properties storage properties, string memory key, address defaultValue) internal view returns (address) {
        return containsKey(properties, key) ? getAddressValue(properties, key) : defaultValue;
    }

    function getBoolOrDefault(Property.Properties storage properties, string memory key, bool defaultValue) internal view returns (bool) {
        return containsKey(properties, key) ? getBoolValue(properties, key) : defaultValue;
    }
}