pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/ownership/Secondary.sol";

contract InstrumentRegistry is Secondary {
    struct InstrumentStatus {
        address instrumentAddress;
        address creator;
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

    function create(address fspAddress, address instrumentAddress, uint256 expiration) public onlyPrimary {
        require(_instruments[instrumentAddress].instrumentAddress != address(0x0), "Instrument already exists");
        _instruments[instrumentAddress] = InstrumentStatus(instrumentAddress, fspAddress, true, now, now + expiration);
        _fsps[fspAddress].fspAddress = fspAddress;
        _fsps[fspAddress].instrumentAddresses.push(instrumentAddress);
    }

    function deactivate(address instrumentAddress) public onlyPrimary {
        _instruments[instrumentAddress].active = false;
    }

    function validate(address instrumentAddress) public view onlyPrimary returns (bool) {
        InstrumentStatus storage status = _instruments[instrumentAddress];
        // Either no expiry(expiration = creation) or not expire yet
        return status.active && (status.expiration == status.creation || status.expiration < now);
    }
}