pragma solidity ^0.5.0;

import "./UnifiedStorage.sol";
import "./InstrumentRegistry.sol";
import "./NutsToken.sol";
import "./NutsEscrow.sol";
import "./Instrument.sol";

contract NutsPlatform {
    uint256 private lastIssuanceId = 0;
    UnifiedStorage private _storage;
    InstrumentRegistry private _instrumentRegistry;
    NutsToken private _token;
    NutsEscrow private _escrow;
    uint256 constant TOKEN_AMOUNT = 10;

    constructor() public {
        _storage = new UnifiedStorage();
        _instrumentRegistry = new InstrumentRegistry();
        _token = new NutsToken();
        _escrow = new NutsEscrow();
    }

    function createInstrument(address instrument_address, uint256 expiration) public {
        _token.transferFrom(msg.sender, address(this), TOKEN_AMOUNT);
        _instrumentRegistry.create(msg.sender, instrument_address, expiration);
    }

    function deactivateInstrument(address instrument_address) public {
        _token.transfer(msg.sender, TOKEN_AMOUNT);
        _instrumentRegistry.deactivate(instrument_address);
    }

    function createIssuance(address instrument_address, string memory state) public returns (uint256) {
        require(_instrumentRegistry.validate(instrument_address), "Instrument invalid");
        lastIssuanceId = lastIssuanceId + 1;
        uint issuance_id = lastIssuanceId;
        Instrument instrument = Instrument(instrument_address);
        string memory new_state = instrument.createIssuance(issuance_id, state);
        _storage.save(bytes32ToString(bytes32(issuance_id)), new_state);

        return issuance_id;
    }

    function engageIssuance(uint256 issuance_id, string memory buyer_state) public returns (uint256) {
        return 0;
    }

    function deposit(uint256 issuance_id, uint256 amount) public {

    }

    function depositToken(uint256 issuance_id, address token, uint256 amount) public {

    }

    function notify(uint256 issuance_id, string memory event_name, string memory event_payload) public {

    }

    function bytes32ToString (bytes32 data) internal pure returns (string memory) {
        bytes memory bytesString = new bytes(32);
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[j] = char;
            }
        }
        return string(bytesString);
    }

}