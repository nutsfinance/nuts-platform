pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/access/roles/WhitelistAdminRole.sol";

contract UnifiedStorage is WhitelistAdminRole {
    mapping(uint256 => string) private _commonProperties;
    mapping(uint256 => string) private _customProperties;

    function getCommonProperties(uint256 issuanceId) public view onlyWhitelistAdmin returns (string memory) {
        return _commonProperties[issuanceId];
    }

    function saveCommonProperties(uint256 issuanceId, string memory properties) public onlyWhitelistAdmin {
        _commonProperties[issuanceId] = properties;
    }

    function getCustomProperties(uint256 issuanceId) public view onlyWhitelistAdmin returns (string memory) {
        return _customProperties[issuanceId];
    }

    function saveCustomProperties(uint256 issuanceId, string memory properties) public onlyWhitelistAdmin {
        _customProperties[issuanceId] = properties;
    }
}