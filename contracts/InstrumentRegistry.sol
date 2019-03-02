pragma solidity ^0.5.0;

contract InstrumentRegistry {
    struct InstrumentStatus {
        address instrument_address;
        address creator;
        bool active;
        uint256 creation;
        uint256 expiration;
    }

    struct FSPStatus {
        address fsp_address;
        address[] instrument_addresses;
    }

    mapping(address => InstrumentStatus) private _instruments;
    mapping(address => FSPStatus) private _fsps;

    function create(address fsp_address, address instrument_address, uint256 expiration) public {
        require(_instruments[instrument_address].instrument_address != address(0x0), "Instrument already exists");
        _instruments[instrument_address] = InstrumentStatus(instrument_address, fsp_address, true, now, now + expiration);
        _fsps[fsp_address].fsp_address = fsp_address;
        _fsps[fsp_address].instrument_addresses.push(instrument_address);
    }

    function deactivate(address instrument_address) public {
        _instruments[instrument_address].active = false;
    }

    function validate(address instrument_address) public view returns (bool) {
        InstrumentStatus storage status = _instruments[instrument_address];
        // Either no expiry(expiration = creation) or not expire yet
        return status.active && (status.expiration == status.creation || status.expiration < now);
    }
}