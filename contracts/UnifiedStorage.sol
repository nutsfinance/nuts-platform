pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/ownership/Secondary.sol";

contract UnifiedStorage is Secondary {
    mapping(string => string) private _data;

    function save(string memory key, string memory value) public onlyPrimary {
        _data[key] = value;
    }

    function lookup(string memory key) public view onlyPrimary returns (string memory) {
        return _data[key];
    }
}