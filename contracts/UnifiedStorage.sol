pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/access/roles/WhitelistAdminRole.sol";

/**
 * @title A generic data storage where all data are string-to-string mappings.
 */
contract UnifiedStorage is WhitelistAdminRole {
    mapping(string => string) private _data;

    function getValue(string memory key) public view onlyWhitelistAdmin returns (string memory) {
        return _data[key];
    }

    function setValue(string memory key, string memory value) public onlyWhitelistAdmin {
       _data[key] = value;
    }
}