pragma solidity ^0.5.0;

// import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

import "./UnifiedStorage.sol";
import "./InstrumentRegistry.sol";
import "./NutsToken.sol";
import "./NutsEscrow.sol";
import "./Instrument.sol";
import "./common/property/Property.sol";
import "./common/payment/Transfer.sol";
import "./common/util/StringUtil.sol";

/**
 * Core contract: The portal of NUTS platform.
 * All external operations are done through the NUTS platform.
 */
contract NutsPlatform {
    using Property for Property.Properties;
    using Transfer for Transfer.Transfers;

    // The sequence used to generate issuance id
    uint256 private lastIssuanceId = 0;
    UnifiedStorage private _storage;
    InstrumentRegistry private _instrumentRegistry;
    NutsToken private _token;
    NutsEscrow private _escrow;
    uint256 constant TOKEN_AMOUNT = 10;

    // TODO Can we use local variable instead?
    Property.Properties private _properties;
    Transfer.Transfers private _transfers;

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
     * @return issuance_id The id of the newly created issuance
     */
    function createIssuance(address instrument_address, string memory seller_data) public returns (uint256) {
        require(_instrumentRegistry.validate(instrument_address), "Invalid instrument");
        lastIssuanceId = lastIssuanceId + 1;
        uint issuance_id = lastIssuanceId;
        Instrument instrument = Instrument(instrument_address);
        (string memory updated_state, string memory action) = instrument.createIssuance(issuance_id, msg.sender, seller_data);

        // Create a new property map for the issuance
        _properties.clear();
        _properties.setUintValue('issuance_id', issuance_id);
        _properties.setAddressValue('instrument_address', instrument_address);
        _properties.setAddressValue('seller_address', msg.sender);
        _properties.setUintValue('created', now);
        _properties.setStringValue('state', updated_state);
        // Persist the updated state
        string memory issuance_state = string(_properties.save());
        _storage.save(StringUtil.uintToString(issuance_id), issuance_state);
        _properties.clear();

        // Post-actions
        processAction(issuance_id, action);

        return issuance_id;
    }

    /**
     * @dev Invoked by buyer to engage an issuance
     * @param issuance_id The id of the issuance
     * @param buyer_state The custom parameters of the engagement
     */
    function engageIssuance(uint256 issuance_id, string memory buyer_state) public {
        // Retrieve the issuance data
        string memory issuance_state = _storage.lookup(StringUtil.uintToString(issuance_id));
        _properties.clear();
        _properties.load(bytes(issuance_state));
        Instrument instrument = Instrument(_properties.getAddressValue('instrument_address'));

        // Retrieve the issuance balance
        string memory state = _properties.getStringValue('state');
        string memory balance = _escrow.getIssuanceBalance(issuance_id);

        (string memory updated_state, string memory action) = instrument.engage(issuance_id, 
            state, balance, msg.sender, buyer_state);

        // Update issuance state
        _properties.setStringValue('state', updated_state);
        issuance_state = string(_properties.save());
        _storage.save(StringUtil.uintToString(issuance_id), issuance_state);
        _properties.clear();

        // Post actions
        processAction(issuance_id, action);
    }

    /**
     * @dev Inovked by seller/buyer to transfer Ether to the issuance. The Ether to be transferred
     *      must be deposited in the escrow already, so the transfer is done in the escrow internally.
     * @param issuance_id The id of the issuance to which the Ether is deposited
     * @param amount The amount of Ether to transfer to the issuance
     */
    function deposit(uint256 issuance_id, uint256 amount) public {
        // Retrieve issuance data
        string memory issuance_state = _storage.lookup(StringUtil.uintToString(issuance_id));
        _properties.clear();
        _properties.load(bytes(issuance_state));
        Instrument instrument = Instrument(_properties.getAddressValue('instrument_address'));

        // Retrieve the issuance balance
        string memory state = _properties.getStringValue('state');
        string memory balance = _escrow.getIssuanceBalance(issuance_id);

        // Complete Ether transfer
        _escrow.transferToIssuance(msg.sender, issuance_id, amount);
        (string memory updated_state, string memory action) = instrument.processTransfer(issuance_id, 
            state, balance, msg.sender, amount);

        // Update issuance state
        _properties.setStringValue('state', updated_state);
        issuance_state = string(_properties.save());
        _storage.save(StringUtil.uintToString(issuance_id), issuance_state);
        _properties.clear();

        // Post-actions
        processAction(issuance_id, action);
    }

     /**
     * @dev Inovked by seller/buyer to transfer ERC20 token to the issuance. The token to be transferred
     *      must be deposited in the escrow already, so the transfer is done in the escrow internally.
     * @param issuance_id The id of the issuance to which the token is deposited
     @ @param token_address The address of the token 
     * @param amount The amount of token to transfer to the issuance
     */
    function depositToken(uint256 issuance_id, address token_address, uint256 amount) public {
        // Retrieve issuance data
        string memory issuance_state = _storage.lookup(StringUtil.uintToString(issuance_id));
        _properties.clear();
        _properties.load(bytes(issuance_state));
        Instrument instrument = Instrument(_properties.getAddressValue('instrument_address'));

        // Retrieve the issuance balance
        string memory state = _properties.getStringValue('state');
        string memory balance = _escrow.getIssuanceBalance(issuance_id);

        // Complete the token transfer
        _escrow.transferTokenToIssuance(msg.sender, issuance_id, ERC20(token_address), amount);
        (string memory updated_state, string memory action) = instrument.processTokenTransfer(issuance_id, 
           state, balance, msg.sender, token_address, amount);

        // Update issuance state
        _properties.setStringValue('state', updated_state);
        issuance_state = string(_properties.save());
        _storage.save(StringUtil.uintToString(issuance_id), issuance_state);
        _properties.clear();

        // Post-actions
        processAction(issuance_id, action);
    }

    /**
     * @dev Callback entry for scheduled custom event or entrance for custom operations
     * @param issuance_id The id of the issuance
     * @param event_name Name of custom event, event_name of EventScheduled event
     * @param event_payload Payload of custom event, event_payload of EventScheduled event
     */
    function notify(uint256 issuance_id, string memory event_name, string memory event_payload) public {
        // Retrieve issuance data
        string memory issuance_state = _storage.lookup(StringUtil.uintToString(issuance_id));
        _properties.clear();
        _properties.load(bytes(issuance_state));
        Instrument instrument = Instrument(_properties.getAddressValue('instrument_address'));

        // Retrieve the issuance balance
        string memory state = _properties.getStringValue('state');
        string memory balance = _escrow.getIssuanceBalance(issuance_id);

        (string memory updated_state, string memory action) = instrument.processEvent(issuance_id, 
            state, balance, event_name, event_payload);

        // Update issuance state
        _properties.setStringValue('state', updated_state);
        issuance_state = string(_properties.save());
        _storage.save(StringUtil.uintToString(issuance_id), issuance_state);
        _properties.clear();

        // Post action
        processAction(issuance_id, action);
    }

    function processAction(uint issuance_id, string memory action) private {
        if (bytes(action).length == 0)  return;
        _transfers.load(bytes(action));

        for (uint i = 0; i < _transfers.actions.length; i++) {
            if (_transfers.actions[i].isEther) {
                _escrow.transferFromIssuance(_transfers.actions[i].receiverAddress, issuance_id,
                    _transfers.actions[i].amount);
            } else {
                _escrow.transferTokenFromIssuance(_transfers.actions[i].receiverAddress, issuance_id, 
                    ERC20(_transfers.actions[i].tokenAddress), _transfers.actions[i].amount);
            }
        }
        _transfers.clear();
    }
}