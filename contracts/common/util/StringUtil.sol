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
     * Convert an address data to string
     */
    function addressToString(address x) pure internal returns (string memory) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++) {
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        }
        return string(b);
    }

    /**
     * Convert a bytes data to address
     */
    function bytesToAddress(bytes memory _address) pure internal returns (address) {
        uint160 m = 0;

        for (uint8 i = 0; i < 20; i++) {
            m *= 256;
            m += _uint160(address[i]);
        }

        return address(m);
    }
}