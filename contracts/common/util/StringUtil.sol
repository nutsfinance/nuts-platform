pragma solidity ^0.5.0;

/**
 * Utility library to handle strings.
 */
library StringUtil {

    /**
     * Convert a unint data to string
     */
    function uintToString(uint data) pure internal returns (string memory) {
        return bytes32ToString(bytes32(data));
    }

    /**
     * Convert a bytes32 data to string
     */
    function bytes32ToString (bytes32 data) pure internal returns (string memory) {
        bytes memory bytesString = new bytes(32);
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[j] = char;
            }
        }
        return string(bytesString);
    }

    /**
     * Convert an address data to bytes
     */
    function addressToBytes(address x) pure internal returns (bytes memory) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++) {
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        }
        return b;
    }

    /**
     * Convert an address data to string
     */
    function addressToString(address x) pure internal returns (string memory) {
        return string(addressToBytes(x));
    }

    /**
     * Convert a bytes data to address
     */
    function bytesToAddress(bytes memory data) pure internal returns (address) {
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(data, 0x20), 0)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    /**
     * Convert a string to uint
     */
    function stringToUint(bytes memory b) pure internal returns (uint result) {
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }

    /**
     * Check whether a string is unit
     */
    function isUint(bytes memory b) pure internal returns (bool) {
        for (uint i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            if (c < 48 || c > 57)   {
                return false;
            }
        }

        return true;
    }

    /**
     * Check whether two bytes arrays are the same
     */
    function equals(bytes memory a, bytes memory b) pure internal returns (bool) {
        if (a.length != b.length) {
            return false;
        }
        for (uint i = 0; i < a.length; i++) {
            if (a[i] != b[i]) {
                return false;
            }
        }

        return true;
    }

    function equals(string memory a, string memory b) pure internal returns (bool) {
        return equals(bytes(a), bytes(b));
    }
}