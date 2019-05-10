pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/access/roles/WhitelistAdminRole.sol";

contract UnifiedStorage is WhitelistAdminRole {
    mapping(string => string) private _data;

    function save(string memory key, string memory value) public onlyWhitelistAdmin {
        _data[key] = value;
    }

    function lookup(string memory key) public view onlyWhitelistAdmin returns (string memory) {
        return _data[key];
    }
}