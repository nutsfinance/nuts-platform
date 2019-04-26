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
     * @param instrumentAddress The address of the instrument contract
     * @param expiration The lifetime of the issuance in days. 0 means never expires.
     */
     // TODO Add role-based access control for FSP
    function createInstrument(address instrumentAddress, uint256 expiration) external {
        _token.transferFrom(msg.sender, address(this), TOKEN_AMOUNT);
        _instrumentRegistry.create(msg.sender, instrumentAddress, expiration);
    }

    /**
     * @dev Invoked by FSP to unregister an instrument
     * @param instrumentAddress The address of the instrument contract
     */
    // TODO Add role-based access control for FSP
    function deactivateInstrument(address instrumentAddress) public {
        _token.transfer(msg.sender, TOKEN_AMOUNT);
        _instrumentRegistry.deactivate(instrumentAddress);
    }

    /**
     * @dev Invoked by seller to create new issuance
     * @param instrumentAddress The address of the instrument of which the issuance is created
     * @param sellerParameters The custom parameter of seller
     * @return issuanceId The id of the newly created issuance
     */
    function createIssuance(address instrumentAddress, string memory sellerParameters) public returns (uint256) {
        require(_instrumentRegistry.validate(instrumentAddress), "Invalid instrument");
        lastIssuanceId = lastIssuanceId + 1;
        uint issuanceId = lastIssuanceId;
        Instrument instrument = Instrument(instrumentAddress);
        (string memory updatedProperties, string memory transfers) = instrument.createIssuance(issuanceId, msg.sender, sellerParameters);

        // Create a new property map for the issuance
        _properties.clear();
        _properties.setUintValue('issuanceId', issuanceId);
        _properties.setAddressValue('instrumentAddress', instrumentAddress);
        _properties.setAddressValue('sellerAddress', msg.sender);
        _properties.setUintValue('created', now);
        _properties.setStringValue('properties', updatedProperties);
        // Persist the updated properties
        string memory issuanceData = string(_properties.save());
        _storage.save(StringUtil.uintToString(issuanceId), issuanceData);
        _properties.clear();

        // Post-transferss
        processTransfers(issuanceId, transfers);

        return issuanceId;
    }

    /**
     * @dev Invoked by buyer to engage an issuance
     * @param issuanceId The id of the issuance
     * @param buyerParameters The custom parameters of the engagement
     */
    function engageIssuance(uint256 issuanceId, string memory buyerParameters) public {
        // Retrieve the issuance data
        string memory issuanceData = _storage.lookup(StringUtil.uintToString(issuanceId));
        _properties.clear();
        _properties.load(bytes(issuanceData));
        Instrument instrument = Instrument(_properties.getAddressValue('instrumentAddress'));

        // Retrieve the issuance balance
        string memory properties = _properties.getStringValue('properties');
        string memory balance = _escrow.getIssuanceBalance(issuanceId);

        (string memory updatedProperties, string memory transfers) = instrument.engage(issuanceId, 
            properties, balance, msg.sender, buyerParameters);

        // Update issuance properties
        _properties.setStringValue('properties', updatedProperties);
        issuanceData = string(_properties.save());
        _storage.save(StringUtil.uintToString(issuanceId), issuanceData);
        _properties.clear();

        // Post transferss
        processTransfers(issuanceId, transfers);
    }

    /**
     * @dev Inovked by seller/buyer to transfer Ether to the issuance. The Ether to be transferred
     *      must be deposited in the escrow already, so the transfer is done in the escrow internally.
     * @param issuanceId The id of the issuance to which the Ether is deposited
     * @param amount The amount of Ether to transfer to the issuance
     */
    function deposit(uint256 issuanceId, uint256 amount) public {
        // Retrieve issuance data
        string memory issuanceData = _storage.lookup(StringUtil.uintToString(issuanceId));
        _properties.clear();
        _properties.load(bytes(issuanceData));
        Instrument instrument = Instrument(_properties.getAddressValue('instrumentAddress'));

        // Retrieve the issuance balance
        string memory properties = _properties.getStringValue('properties');
        string memory balance = _escrow.getIssuanceBalance(issuanceId);

        // Complete Ether transfer
        _escrow.transferToIssuance(msg.sender, issuanceId, amount);
        (string memory updatedProperties, string memory transfers) = instrument.processTransfer(issuanceId, 
            properties, balance, msg.sender, amount);

        // Update issuance properties
        _properties.setStringValue('properties', updatedProperties);
        issuanceData = string(_properties.save());
        _storage.save(StringUtil.uintToString(issuanceId), issuanceData);
        _properties.clear();

        // Post-transferss
        processTransfers(issuanceId, transfers);
    }

     /**
     * @dev Inovked by seller/buyer to transfer ERC20 token to the issuance. The token to be transferred
     *      must be deposited in the escrow already, so the transfer is done in the escrow internally.
     * @param issuanceId The id of the issuance to which the token is deposited
     @ @param token_address The address of the token 
     * @param amount The amount of token to transfer to the issuance
     */
    function depositToken(uint256 issuanceId, address token_address, uint256 amount) public {
        // Retrieve issuance data
        string memory issuanceData = _storage.lookup(StringUtil.uintToString(issuanceId));
        _properties.clear();
        _properties.load(bytes(issuanceData));
        Instrument instrument = Instrument(_properties.getAddressValue('instrumentAddress'));

        // Retrieve the issuance balance
        string memory properties = _properties.getStringValue('properties');
        string memory balance = _escrow.getIssuanceBalance(issuanceId);

        // Complete the token transfer
        _escrow.transferTokenToIssuance(msg.sender, issuanceId, ERC20(token_address), amount);
        (string memory updatedProperties, string memory transfers) = instrument.processTokenTransfer(issuanceId, 
           properties, balance, msg.sender, token_address, amount);

        // Update issuance properties
        _properties.setStringValue('properties', updatedProperties);
        issuanceData = string(_properties.save());
        _storage.save(StringUtil.uintToString(issuanceId), issuanceData);
        _properties.clear();

        // Post-transferss
        processTransfers(issuanceId, transfers);
    }

    /**
     * @dev Callback entry for scheduled custom event or entrance for custom operations
     * @param issuanceId The id of the issuance
     * @param event_name Name of custom event, event_name of EventScheduled event
     * @param event_payload Payload of custom event, event_payload of EventScheduled event
     */
    function notify(uint256 issuanceId, string memory event_name, string memory event_payload) public {
        // Retrieve issuance data
        string memory issuanceData = _storage.lookup(StringUtil.uintToString(issuanceId));
        _properties.clear();
        _properties.load(bytes(issuanceData));
        Instrument instrument = Instrument(_properties.getAddressValue('instrumentAddress'));

        // Retrieve the issuance balance
        string memory properties = _properties.getStringValue('properties');
        string memory balance = _escrow.getIssuanceBalance(issuanceId);

        (string memory updatedProperties, string memory transfers) = instrument.processEvent(issuanceId, 
            properties, balance, event_name, event_payload);

        // Update issuance properties
        _properties.setStringValue('properties', updatedProperties);
        issuanceData = string(_properties.save());
        _storage.save(StringUtil.uintToString(issuanceId), issuanceData);
        _properties.clear();

        // Post transfers
        processTransfers(issuanceId, transfers);
    }

    function processTransfers(uint issuanceId, string memory transfers) private {
        if (bytes(transfers).length == 0)  return;
        _transfers.load(bytes(transfers));

        for (uint i = 0; i < _transfers.actions.length; i++) {
            if (_transfers.actions[i].isEther) {
                _escrow.transferFromIssuance(_transfers.actions[i].receiverAddress, issuanceId,
                    _transfers.actions[i].amount);
            } else {
                _escrow.transferTokenFromIssuance(_transfers.actions[i].receiverAddress, issuanceId, 
                    ERC20(_transfers.actions[i].tokenAddress), _transfers.actions[i].amount);
            }
        }
        _transfers.clear();
    }
}