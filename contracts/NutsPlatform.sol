pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;

import "./UnifiedStorage.sol";
import "./InstrumentRegistry.sol";
import "./NutsToken.sol";
import "./NutsEscrow.sol";
import "./Instrument.sol";
import "./common/property/Property.sol";
import "./common/payment/TokenTransfer.sol";
import "./access/TimerOracleRole.sol";
import "./access/FspRole.sol";

/**
 * Core contract: The portal of NUTS platform.
 * All external operations are done through the NUTS platform.
 */
contract NutsPlatform is FspRole, TimerOracleRole {
    using Property for Property.Properties;
    using TokenTransfer for TokenTransfer.Transfers;

    event InstrumentCreated(address indexed instrumentAddress, address indexed fspAddress);

    event IssuanceCreated(uint indexed issuanceId, address indexed instrumentAddress,
        address indexed sellerAddress);

    event IssuanceEngaged(uint indexed issuanceId, address indexed instrumentAddress,
        address indexed buyerAddress);

    // The sequence used to generate issuance id
    uint256 private lastIssuanceId = 0;
    UnifiedStorage private _storage;
    InstrumentRegistry private _instrumentRegistry;
    NutsToken private _token;
    NutsEscrow private _escrow;
    uint256 constant TOKEN_AMOUNT = 10;

    // TODO Replace it with protocol buffer message
    Property.Properties private _commonProperties;

    constructor(address unifiedStorageAddress, address instrumentRegistry,
        address nutsTokenAddress, address nutsEscrowAddress) public {
        _storage = UnifiedStorage(unifiedStorageAddress);
        _instrumentRegistry = InstrumentRegistry(instrumentRegistry);
        _token = NutsToken(nutsTokenAddress);
        _escrow = NutsEscrow(nutsEscrowAddress);
    }

    /**
     * @dev Invoked by FSP to register a new instrument.
     * @param instrumentAddress The address of the instrument contract
     * @param expiration The lifetime of the issuance in days. 0 means never expires.
     */
    function createInstrument(address instrumentAddress, uint256 expiration) external onlyFsp {
        _token.transferFrom(msg.sender, address(this), TOKEN_AMOUNT);
        _instrumentRegistry.create(msg.sender, instrumentAddress, expiration);

        emit InstrumentCreated(instrumentAddress, msg.sender);
    }

    /**
     * @dev Invoked by FSP to unregister an instrument
     * @param instrumentAddress The address of the instrument contract
     */
    function deactivateInstrument(address instrumentAddress) public onlyFsp {
        _token.transfer(msg.sender, TOKEN_AMOUNT);
        _instrumentRegistry.deactivate(msg.sender, instrumentAddress);
    }

    /**
     * @dev Invoked by seller to create new issuance
     * @param instrumentAddress The address of the instrument of which the issuance is created
     * @param sellerParameters The custom parameter of seller
     * @return issuanceId The id of the newly created issuance
     */
    function createIssuance(address instrumentAddress, string memory sellerParameters) public returns (uint256) {
        require(instrumentAddress != address(0x0), "Instrument address must be set.");
        require(_instrumentRegistry.validate(instrumentAddress), "Invalid instrument");
        lastIssuanceId = lastIssuanceId + 1;
        uint issuanceId = lastIssuanceId;
        Instrument instrument = Instrument(instrumentAddress);
        (Instrument.IssuanceStates updatedState, string memory updatedProperties, TokenTransfer.Transfers memory transfers)
            = instrument.createIssuance(issuanceId, msg.sender, sellerParameters);

        // Create a new property map for the issuance
        _commonProperties.clear();
        _commonProperties.setUintValue('issuanceId', issuanceId);
        _commonProperties.setAddressValue('instrumentAddress', instrumentAddress);
        _commonProperties.setAddressValue('sellerAddress', msg.sender);
        _commonProperties.setUintValue('created', now);
        _commonProperties.setUintValue('state', uint256(updatedState));

        // Persist common and custom properties
        _storage.setValue(StringUtil.concat(issuanceId, "_common"), string(_commonProperties.save()));
        _storage.setValue(StringUtil.concat(issuanceId, "_custom"), updatedProperties);
        _commonProperties.clear();

        // Post-transferss
        processTransfers(issuanceId, transfers);

        emit IssuanceCreated(issuanceId, instrumentAddress, msg.sender);
        return issuanceId;
    }

    /**
     * @dev Invoked by buyer to engage an issuance
     * @param issuanceId The id of the issuance
     * @param buyerParameters The custom parameters of the engagement
     */
    function engageIssuance(uint256 issuanceId, string memory buyerParameters) public {
        // Validation
        require(issuanceId > 0, "Issuance id must be set.");

        // Retrieve common and custom properties
        string memory commonKey = StringUtil.concat(issuanceId, "_common");
        string memory customKey = StringUtil.concat(issuanceId, "_custom");
        string memory commonPropertiesData = _storage.getValue(commonKey);
        // Validate whether the issuance exists
        require(bytes(commonPropertiesData).length > 0, "Issuance does not exist.");
        string memory customPropertiesData = _storage.getValue(customKey);

        _commonProperties.clear();
        _commonProperties.load(bytes(commonPropertiesData));
        address instrumentAddress = _commonProperties.getAddressValue('instrumentAddress');
        Instrument.IssuanceStates state = Instrument.IssuanceStates(_commonProperties.getUintValue('state'));
        Instrument instrument = Instrument(instrumentAddress);

        // Retrieve the issuance balance
        TokenBalance.Balances memory balances = _escrow.getIssuanceBalance(issuanceId);
        (Instrument.IssuanceStates updatedState, string memory updatedProperties, TokenTransfer.Transfers memory transfers)
            = instrument.engage(issuanceId, state, customPropertiesData, balances, msg.sender, buyerParameters);
        _commonProperties.setUintValue('state', uint256(updatedState));

        // Update issuance properties
        _storage.setValue(commonKey, string(_commonProperties.save()));
        _storage.setValue(customKey, updatedProperties);
        _commonProperties.clear();

        // Post transferss
        processTransfers(issuanceId, transfers);

        emit IssuanceEngaged(issuanceId, instrumentAddress, msg.sender);
    }

    /**
     * @dev Inovked by seller/buyer to transfer Ether to the issuance. The Ether to be transferred
     *      must be deposited in the escrow already, so the transfer is done in the escrow internally.
     * @param issuanceId The id of the issuance to which the Ether is deposited
     * @param amount The amount of Ether, in wei, to transfer to the issuance
     */
    function deposit(uint256 issuanceId, uint256 amount) public {
        // Validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(amount > 0, "Deposit amount must be larger than 0.");

        // Retrieve common and custom properties
        string memory commonKey = StringUtil.concat(issuanceId, "_common");
        string memory customKey = StringUtil.concat(issuanceId, "_custom");
        string memory commonPropertiesData = _storage.getValue(commonKey);
        // Validate whether the issuance exists
        require(bytes(commonPropertiesData).length > 0, "Issuance does not exist.");
        string memory customPropertiesData = _storage.getValue(customKey);

        _commonProperties.clear();
        _commonProperties.load(bytes(commonPropertiesData));
        address instrumentAddress = _commonProperties.getAddressValue('instrumentAddress');
        Instrument instrument = Instrument(instrumentAddress);
        Instrument.IssuanceStates state = Instrument.IssuanceStates(_commonProperties.getUintValue('state'));

        // Complete Ether transfer
        _escrow.transferToIssuance(msg.sender, issuanceId, amount);

        // Process the transfer event
        TokenBalance.Balances memory balances = _escrow.getIssuanceBalance(issuanceId);
        (Instrument.IssuanceStates updatedState, string memory updatedProperties, TokenTransfer.Transfers memory transfers)
            = instrument.processDeposit(issuanceId, state, customPropertiesData, balances, msg.sender, amount);

        // Update issuance properties
        _commonProperties.setUintValue('state', uint256(updatedState));
        _storage.setValue(commonKey, string(_commonProperties.save()));
        _storage.setValue(customKey, updatedProperties);
        _commonProperties.clear();

        // Post-transferss
        processTransfers(issuanceId, transfers);
    }

     /**
     * @dev Inovked by seller/buyer to transfer ERC20 token to the issuance. The token to be transferred
     *      must be deposited in the escrow already, so the transfer is done in the escrow internally.
     * @param issuanceId The id of the issuance to which the token is deposited
     @ @param tokenAddress The address of the token
     * @param amount The amount of token to transfer to the issuance
     */
    function depositToken(uint256 issuanceId, address tokenAddress, uint256 amount) public {
        // Validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(tokenAddress != address(0x0), "Token address must be set.");
        require(amount > 0, "Deposit amount must be larger than 0.");

        // Retrieve common and custom properties
        string memory commonKey = StringUtil.concat(issuanceId, "_common");
        string memory customKey = StringUtil.concat(issuanceId, "_custom");
        string memory commonPropertiesData = _storage.getValue(commonKey);
        // Validate whether the issuance exists
        require(bytes(commonPropertiesData).length > 0, "Issuance does not exist.");
        string memory customPropertiesData = _storage.getValue(customKey);

        _commonProperties.clear();
        _commonProperties.load(bytes(commonPropertiesData));
        address instrumentAddress = _commonProperties.getAddressValue('instrumentAddress');
        Instrument instrument = Instrument(instrumentAddress);
        Instrument.IssuanceStates state = Instrument.IssuanceStates(_commonProperties.getUintValue('state'));

        // Complete the token transfer
        _escrow.transferTokenToIssuance(msg.sender, issuanceId, ERC20(tokenAddress), amount);

        // Process the transfer event
        TokenBalance.Balances memory balances = _escrow.getIssuanceBalance(issuanceId);
        (Instrument.IssuanceStates updatedState, string memory updatedProperties, TokenTransfer.Transfers memory transfers)
            = instrument.processTokenDeposit(issuanceId, state, customPropertiesData, balances, msg.sender, tokenAddress, amount);

        // Update issuance properties
        _commonProperties.setUintValue('state', uint256(updatedState));
        _storage.setValue(commonKey, string(_commonProperties.save()));
        _storage.setValue(customKey, updatedProperties);
        _commonProperties.clear();

        // Post-transferss
        processTransfers(issuanceId, transfers);
    }

    /**
     * @dev Callback entry for scheduled event
     * @param issuanceId The id of the issuance
     * @param timestamp The scheduled time for the event
     * @param eventName Name of custom event, eventName of EventScheduled event
     * @param eventPayload Payload of custom event, eventPayload of EventScheduled event
     */
    function processScheduledEvent(uint256 issuanceId, uint256 timestamp, string memory eventName,
        string memory eventPayload) public onlyTimerOracle {
        // Validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(eventName).length > 0, "Event name must be set.");
        require(timestamp <= now, "The scheduled event is not due now.");

        // Retrieve common and custom properties
        string memory commonKey = StringUtil.concat(issuanceId, "_common");
        string memory customKey = StringUtil.concat(issuanceId, "_custom");
        string memory commonPropertiesData = _storage.getValue(commonKey);
        // Validate whether the issuance exists
        require(bytes(commonPropertiesData).length > 0, "Issuance does not exist.");
        string memory customPropertiesData = _storage.getValue(customKey);

        _commonProperties.clear();
        _commonProperties.load(bytes(commonPropertiesData));
        address instrumentAddress = _commonProperties.getAddressValue('instrumentAddress');
        Instrument instrument = Instrument(instrumentAddress);
        Instrument.IssuanceStates state = Instrument.IssuanceStates(_commonProperties.getUintValue('state'));

        // Retrieve the issuance balance
        TokenBalance.Balances memory balances = _escrow.getIssuanceBalance(issuanceId);

        (Instrument.IssuanceStates updatedState, string memory updatedProperties, TokenTransfer.Transfers memory transfers)
            = instrument.processScheduledEvent(issuanceId, state, customPropertiesData, balances, eventName, eventPayload);

        // Update issuance properties
        _commonProperties.setUintValue('state', uint256(updatedState));
        _storage.setValue(commonKey, string(_commonProperties.save()));
        _storage.setValue(customKey, updatedProperties);
        _commonProperties.clear();

        // Post transfers
        processTransfers(issuanceId, transfers);
    }

    /**
     * @dev Entry to process custom operations
     * @param issuanceId The id of the issuance
     * @param eventName Name of custom event, eventName of EventScheduled event
     * @param eventPayload Payload of custom event, eventPayload of EventScheduled event
     */
    function processCustomEvent(uint256 issuanceId, string memory eventName, string memory eventPayload) public {
        // Validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(eventName).length > 0, "Event name must be set.");

        // Retrieve common and custom properties
        string memory commonKey = StringUtil.concat(issuanceId, "_common");
        string memory customKey = StringUtil.concat(issuanceId, "_custom");
        string memory commonPropertiesData = _storage.getValue(commonKey);
        // Validate whether the issuance exists
        require(bytes(commonPropertiesData).length > 0, "Issuance does not exist.");
        string memory customPropertiesData = _storage.getValue(customKey);

        _commonProperties.clear();
        _commonProperties.load(bytes(commonPropertiesData));
        address instrumentAddress = _commonProperties.getAddressValue('instrumentAddress');
        Instrument instrument = Instrument(instrumentAddress);
        Instrument.IssuanceStates state = Instrument.IssuanceStates(_commonProperties.getUintValue('state'));

        // Retrieve the issuance balance
        TokenBalance.Balances memory balances = _escrow.getIssuanceBalance(issuanceId);

        (Instrument.IssuanceStates updatedState, string memory updatedProperties, TokenTransfer.Transfers memory transfers)
            = instrument.processCustomEvent(issuanceId, state, customPropertiesData, balances, eventName, eventPayload);

        // Update issuance properties
        _commonProperties.setUintValue('state', uint256(updatedState));
        _storage.setValue(commonKey, string(_commonProperties.save()));
        _storage.setValue(customKey, updatedProperties);
        _commonProperties.clear();

        // Post transfers
        processTransfers(issuanceId, transfers);
    }

    /**
     * @dev Complete the transfers actions
     * @param issuanceId The id of the issuance which owns the Ether/token
     * @param transfers The transfer actions
     */
    function processTransfers(uint issuanceId, TokenTransfer.Transfers memory transfers) private {
        // Note: The Escrow performs validation of transfer against the balance,
        // so there is no need to do the validation here.
        for (uint i = 0; i < transfers.actions.length; i++) {
            if (transfers.actions[i].isEther) {
                _escrow.transferFromIssuance(transfers.actions[i].receiverAddress, issuanceId,
                    transfers.actions[i].amount);
            } else {
                _escrow.transferTokenFromIssuance(transfers.actions[i].receiverAddress, issuanceId,
                    ERC20(transfers.actions[i].tokenAddress), transfers.actions[i].amount);
            }
        }
    }
}