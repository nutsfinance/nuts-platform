pragma solidity ^0.5.0;

import "../seriality/BytesToTypes.sol";
import "../seriality/TypesToBytes.sol";
import "../seriality/SizeOf.sol";
import "../util/StringUtil.sol";

/**
 * Core library to handle state serialization/deserialization
 * All states are serialied into bytes to persist in unified storage
 * and deserialize to self while in use.
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
    function containsKey(Properties storage self, string memory key) internal view returns (bool) {
        return self.indices[bytes(key)] > 0;
    }

    modifier keyExist(Properties storage self, string memory key) {
        require(containsKey(self, key), "Key does not exist");
        _;
    }

    function clear(Properties storage self) internal {
        // Clears the mapping
        for (uint i = 0; i < self.data.length; i++) {
            delete self.indices[self.data[i].key];
        }

        // Clears the data
        self.data.length = 0;
    }

    /**
     * Important function to parse custom parameters
     * Note: Currently only string and uint parameters are supported.
     * Note: Parameters are of the format: aaa=bbb&ccc=ddd&ee=11
     */
    function parseParameters(Properties storage self, string memory parameters) internal {
        // Clears the data
        clear(self);

        uint start = 0;
        uint mid = 0;

        bytes memory data = bytes(parameters);
        for (uint i = 0; i < data.length; i++) {
            if (data[i] == "=") {
                mid = i;
            } else if (data[i] == "&") {
                (bytes memory key, bytes memory value) = getParameterPair(data, start, mid, i);

                start = i + 1;
                if (StringUtil.isUint(value)) {
                    uint uintValue = StringUtil.stringToUint(value);
                    setUintValue(self, string(key), uintValue);
                } else {
                    setBytesValue(self, string(key), value);
                }
            }
        }

        (bytes memory key, bytes memory value) = getParameterPair(data, start, mid, data.length);
        if (StringUtil.isUint(value)) {
            uint uintValue = StringUtil.stringToUint(value);
            setUintValue(self, string(key), uintValue);
        } else {
            setBytesValue(self, string(key), value);
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
     * Deserialize self from bytes
     */
    function load(Properties storage self, bytes memory data) internal {
        // Clears the data
        clear(self);

        uint offset = data.length;
        uint index = 1;
        while (offset > 0) {
            bytes memory key = new bytes(BytesToTypes.getStringSize(offset, data));
            BytesToTypes.bytesToString(offset, data, key);
            offset -= BytesToTypes.getStringSize(offset, data);

            bytes memory value = new bytes(BytesToTypes.getStringSize(offset, data));
            BytesToTypes.bytesToString(offset, data, value);
            offset -= BytesToTypes.getStringSize(offset, data);
            
            self.data.push(Entry(key, value));
            self.indices[key] = index;
            index += 1;
        }
    }

    /**
     * Serialize self to bytes
     */
    function save(Properties storage self) internal view returns (bytes memory data) {
        uint size = 0;
        for (uint i = 0; i < self.data.length; i++) {            
            size += SizeOf.sizeOfString(self.data[i].key);
            size += SizeOf.sizeOfString(self.data[i].value);
        }

        data = new bytes(size);
        uint offset = size;
        for (uint i = 0; i < self.data.length; i++) {
            TypesToBytes.stringToBytes(offset, self.data[i].key, data);
            offset -= SizeOf.sizeOfString(self.data[i].key);

            TypesToBytes.stringToBytes(offset, self.data[i].value, data);
            offset -= SizeOf.sizeOfString(self.data[i].value);
        }
    }

    /**
     * Type-specific API functions for value types
     */
    function getBytesValue(Properties storage self, string memory key) internal view keyExist(self, key) returns (bytes memory value) {
        value = self.data[self.indices[bytes(key)] - 1].value;
    }

    function setBytesValue(Properties storage self, string memory key, bytes memory value) internal {
        uint index = self.indices[bytes(key)];
        // New key
        if (index == 0) {
            self.data.push(Entry(bytes(key), value));
            self.indices[bytes(key)] = self.data.length;
        } else {
            self.data[index - 1] = Entry(bytes(key), value);
        }
    }

    function getStringValue(Properties storage self, string memory key) internal view keyExist(self, key) returns (string memory value) {
        bytes memory data = getBytesValue(self, key);
        value = string(data);
    }

    function setStringValue(Properties storage self, string memory key, string memory value) internal {
        setBytesValue(self, key, bytes(value));
    }

    function getIntValue(Properties storage self, string memory key) internal view keyExist(self, key) returns (int value) {
        bytes memory data = getBytesValue(self, key);
        value = BytesToTypes.bytesToInt256(data.length, data);
    }

    function setIntValue(Properties storage self, string memory key, int value) internal {
        bytes memory data = new bytes(32);
        TypesToBytes.intToBytes(32, value, data);
        setBytesValue(self, key, data);
    }

    // Note: This is not the most efficient way to store bool; better to store it using 1 byte
    // Currently implement using uint due to the limit of BytesToTypes.bytesToBool
    // TODO Implement it with mstore8 and mload8
    function getBoolValue(Properties storage self, string memory key) internal view keyExist(self, key) returns (bool value) {
        uint data = getUintValue(self, key);
        value = data == 1;
    }

    function setBoolValue(Properties storage self, string memory key, bool value) internal {
        setUintValue(self, key, value ? 1 : 0);
    }

    function getUintValue(Properties storage self, string memory key) internal view keyExist(self, key) returns (uint value) {
        bytes memory data = getBytesValue(self, key);
        value = BytesToTypes.bytesToUint256(data.length, data);
        // Note: The bytes data might be smaller than 32 bytes!
        // value = StringUtil.stringToUint(string(data));
    }

    function setUintValue(Properties storage self, string memory key, uint value) internal {
        bytes memory data = new bytes(32);
        TypesToBytes.uintToBytes(32, value, data);
        setBytesValue(self, key, data);
    }

    function getAddressValue(Properties storage self, string memory key) internal view keyExist(self, key) returns (address value) {
        bytes memory data = getBytesValue(self, key);
        value = StringUtil.bytesToAddress(data);
    }

    function setAddressValue(Properties storage self, string memory key, address value) internal {
        setStringValue(self, key, StringUtil.addressToString(value));
    }

    /**
     * Type-specific API functions for arrays
     */
    function getBytesArrayValue(Properties storage self, string memory key) internal view keyExist(self, key) returns (bytes[] memory value) {
        bytes memory data = getBytesValue(self, key);
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

    function setBytesArrayValue(Properties storage self, string memory key, bytes[] memory value) internal {
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

        setBytesValue(self, key, data);
    }

    function getStringArrayValue(Properties storage self, string memory key) internal view keyExist(self, key) returns (string[] memory value) {
        bytes memory data = getBytesValue(self, key);
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

    function setStringArrayValue(Properties storage self, string memory key, string[] memory value) internal {
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

        setBytesValue(self, key, data);
    }

    function getIntArrayValue(Properties storage self, string memory key) internal view keyExist(self, key) returns (int[] memory value) {
        bytes memory data = getBytesValue(self, key);
        uint offset = data.length;
        uint length = BytesToTypes.bytesToUint256(offset, data);
        offset -= 32;
        value = new int[](length);

        for (uint i = 0; i < length; i++) {
            value[i] = BytesToTypes.bytesToInt256(offset, data);
            offset -= 32;
        }
    }

    function setIntArrayValue(Properties storage self, string memory key, int[] memory value) internal {
        uint size = 32 * (value.length + 1);

        bytes memory data = new bytes(size);
        uint offset = size;
        TypesToBytes.uintToBytes(offset, value.length, data);
        offset -= 32;

        for (uint i = 0; i < value.length; i++) {
            TypesToBytes.intToBytes(offset, value[i], data);
            offset -= 32;
        }

        setBytesValue(self, key, data);
    }

    function getUintArrayValue(Properties storage self, string memory key) internal view keyExist(self, key) returns (uint[] memory value) {
        bytes memory data = getBytesValue(self, key);
        uint offset = data.length;
        uint length = BytesToTypes.bytesToUint256(offset, data);
        offset -= 32;
        value = new uint[](length);

        for (uint i = 0; i < length; i++) {
            value[i] = BytesToTypes.bytesToUint256(offset, data);
            offset -= 32;
        }
    }

    function setUintArrayValue(Properties storage self, string memory key, uint[] memory value) internal {
        uint size = 32 * (value.length + 1);

        bytes memory data = new bytes(size);
        uint offset = size;
        TypesToBytes.uintToBytes(offset, value.length, data);
        offset -= 32;

        for (uint i = 0; i < value.length; i++) {
            TypesToBytes.uintToBytes(offset, value[i], data);
            offset -= 32;
        }

        setBytesValue(self, key, data);
    }

    /**
     * Utility functions
     */

    function getStringOrDefault(Property.Properties storage self, string memory key, string memory defaultValue) internal view returns (string memory) {
        return containsKey(self, key) ? getStringValue(self, key) : defaultValue;
    }

    function getUintOrDefault(Property.Properties storage self, string memory key, uint defaultValue) internal view returns (uint) {
        return containsKey(self, key) ? getUintValue(self, key) : defaultValue;
    }

    function getIntOrDefault(Property.Properties storage self, string memory key, int defaultValue) internal view returns (int) {
        return containsKey(self, key) ? getIntValue(self, key) : defaultValue;
    }

    function getAddressOrDefault(Property.Properties storage self, string memory key, address defaultValue) internal view returns (address) {
        return containsKey(self, key) ? getAddressValue(self, key) : defaultValue;
    }

    function getBoolOrDefault(Property.Properties storage self, string memory key, bool defaultValue) internal view returns (bool) {
        return containsKey(self, key) ? getBoolValue(self, key) : defaultValue;
    }
}