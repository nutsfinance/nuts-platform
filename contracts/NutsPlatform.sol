pragma solidity ^0.5.0;

import "./UnifiedStorage.sol";
import "./InstrumentRegistry.sol";
import "./NutsToken.sol";
import "./NutsEscrow.sol";
import "./Instrument.sol";
import "./common/property/Property.sol";
import "./common/util/StringUtil.sol";

/**
 * Core contract: The portal of NUTS platform.
 * All external operations are done through the NUTS platform.
 */
contract NutsPlatform {
    using Property for Property.Properties;

    // The sequence used to generate issuance id
    uint256 private lastIssuanceId = 0;
    UnifiedStorage private _storage;
    InstrumentRegistry private _instrumentRegistry;
    NutsToken private _token;
    NutsEscrow private _escrow;
    uint256 constant TOKEN_AMOUNT = 10;

    // TODO Can we use local variable instead?
    Property.Properties private _properties;

    constructor() public {
        _storage = new UnifiedStorage();
        _instrumentRegistry = new InstrumentRegistry();
        _token = new NutsToken();
        _escrow = new NutsEscrow();
    }

    /**
     * @dev Invoked by FSP to register a new instrument.
     * @param instrument_address The address of the instrument contract
     * @param expiration The lifetime of the issuance in days. 0 means never expires.
     */
     // TODO Add role-based access control for FSP
    function createInstrument(address instrument_address, uint256 expiration) external {
        _token.transferFrom(msg.sender, address(this), TOKEN_AMOUNT);
        _instrumentRegistry.create(msg.sender, instrument_address, expiration);
    }

    /**
     * @dev Invoked by FSP to unregister an instrument
     * @param instrument_address The address of the instrument contract
     */
    // TODO Add role-based access control for FSP
    function deactivateInstrument(address instrument_address) public {
        _token.transfer(msg.sender, TOKEN_AMOUNT);
        _instrumentRegistry.deactivate(instrument_address);
    }

    /**
     * @dev Invoked by seller to create new issuance
     * @param instrument_address The address of the instrument of which the issuance is created
     * @param seller_data The custom parameter 
     */
    function createIssuance(address instrument_address, string memory seller_data) public returns (uint256) {
        require(_instrumentRegistry.validate(instrument_address), "Invalid instrument");
        lastIssuanceId = lastIssuanceId + 1;
        uint issuance_id = lastIssuanceId;
        Instrument instrument = Instrument(instrument_address);
        string memory state = instrument.createIssuance(issuance_id, msg.sender, seller_data);

        // Create a new property map for the issuance
        _properties.clear();
        _properties.setUintValue('issuance_id', issuance_id);
        _properties.setAddressValue('seller', msg.sender);
        _properties.setUintValue('created', Now());
        _properties.setStringValue('state', state);
        _storage.save(StringUtil.uintToString(issuance_id), _properties.save());
        _properties.clear();

        return issuance_id;
    }

    function engageIssuance(uint256 issuance_id, string memory buyer_state) public {
        _properties.clear();
        
    }

    function deposit(uint256 issuance_id, uint256 amount) public {

    }

    function depositToken(uint256 issuance_id, address token, uint256 amount) public {

    }

    function notify(uint256 issuance_id, string memory event_name, string memory event_payload) public {

    }

}