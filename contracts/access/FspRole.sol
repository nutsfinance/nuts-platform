pragma solidity ^0.5.0;

import "../lib/access/Roles.sol";

contract FspRole {
    using Roles for Roles.Role;

    event FspAdded(address indexed account);
    event FspRemoved(address indexed account);

    Roles.Role private _fsps;

    constructor () internal {
        _addFsp(msg.sender);
    }

    modifier onlyFsp() {
        require(isFsp(msg.sender), "FspRole: caller does not have the Fsp role");
        _;
    }

    function isFsp(address account) public view returns (bool) {
        return _fsps.has(account);
    }

    function addFsp(address account) public onlyFsp {
        _addFsp(account);
    }

    function renounceFsp() public {
        _removeFsp(msg.sender);
    }

    function _addFsp(address account) internal {
        _fsps.add(account);
        emit FspAdded(account);
    }

    function _removeFsp(address account) internal {
        _fsps.remove(account);
        emit FspRemoved(account);
    }
}