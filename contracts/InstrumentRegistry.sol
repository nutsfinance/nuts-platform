pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/access/roles/WhitelistAdminRole.sol";

/**
 * @title The registry of instruments.
 */
contract InstrumentRegistry is WhitelistAdminRole {
    struct InstrumentStatus {
        address instrumentAddress;
        address fspAddress;
        bool active;
        uint256 creation;
        uint256 expiration;
    }

    struct FSPStatus {
        address fspAddress;
        address[] instrumentAddresses;
    }

    mapping(address => InstrumentStatus) private _instruments;
    mapping(address => FSPStatus) private _fsps;

    /**
     * @dev Creates a new instruments in the registry.
     * @param fspAddress The address of the FSP which creates the instrument.
     * @param instrumentAddress The address the deployed instrument contract.
     * @param expiration The TTL of the instrument. 0 means never expires.
     */
    function create(address fspAddress, address instrumentAddress, uint256 expiration) public onlyWhitelistAdmin {
        require(fspAddress != address(0x0), "FSP address must be set");
        require(instrumentAddress != address(0x0), "Instrument address must be set");
        require(_instruments[instrumentAddress].instrumentAddress == address(0x0), "Instrument already exists");
        _instruments[instrumentAddress] = InstrumentStatus(instrumentAddress, fspAddress, true, now, now + expiration);
        _fsps[fspAddress].fspAddress = fspAddress;
        _fsps[fspAddress].instrumentAddresses.push(instrumentAddress);
    }

    /**
     * @dev Deactivates an instrument.
     * @param fspAddress The address of the FSP who deactivates the instrument.
     * @param instrumentAddress The address of the instrumetn to deactivate.
     */
    function deactivate(address fspAddress, address instrumentAddress) public onlyWhitelistAdmin {
        require(fspAddress != address(0x0), "FSP address must be set");
        require(instrumentAddress != address(0x0), "Instrument address must be set");
        require(isWhitelistAdmin(fspAddress) || _instruments[instrumentAddress].fspAddress == fspAddress,
            "Only admin or creator can deactivate an instrument");
        _instruments[instrumentAddress].active = false;
    }

    /**
     * @dev Validate an instrument.
     * @param instrumentAddress The address of the instrument to validate.
     */
    function validate(address instrumentAddress) public view onlyWhitelistAdmin returns (bool) {
        require(instrumentAddress != address(0x0), "Instrument address must be set");
        InstrumentStatus storage status = _instruments[instrumentAddress];
        // Validity check
        // 1. Not deactivated(status.active = true)
        // 2. Either expiration = 0 or expiration > now
        return status.active && (status.expiration == status.creation || status.expiration > now);
    }
}