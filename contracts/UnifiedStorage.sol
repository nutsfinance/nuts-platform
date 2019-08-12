pragma solidity ^0.5.0;

import "./lib/access/WhitelistAdminRole.sol";
import "./ProtoBufRuntime.sol";

/**
 * @title A generic data storage where all data are string-to-string mappings.
 */
contract UnifiedStorage is WhitelistAdminRole {
    mapping(string => bytes) private _data;

    function getValue(string memory key) public view onlyWhitelistAdmin returns (bytes memory) {
        return ProtoBufRuntime.decodeStorage(_data[key]);
    }

    function setValue(string memory key, bytes memory value) public onlyWhitelistAdmin {
      ProtoBufRuntime.encodeStorage(_data[key], value);
    }
}
