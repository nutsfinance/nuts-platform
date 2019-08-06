pragma solidity ^0.5.0;

import "./access/TimerOracleRole.sol";
import "./access/FspRole.sol";
import "./Instrument.sol";
import "./InstrumentRegistry.sol";
import "./NutsToken.sol";
import "./NutsEscrow.sol";
import "./IssuanceInfo.sol";
import "./TokenTransfer.sol";
import "./UnifiedStorage.sol";
import "./lib/util/StringUtil.sol";

/**
 * Core contract: The portal of NUTS platform.
 * All external operations are done through the NUTS platform.
 */
contract NutsPlatform is FspRole, TimerOracleRole {
    using CommonProperties for CommonProperties.Data;
    using Transfers for Transfers.Data;

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
        (Instrument.IssuanceStates updatedState, string memory updatedProperties,
            string memory transfers) = instrument.createIssuance(issuanceId,
            msg.sender, sellerParameters);

        // Create a new property map for the issuance
        CommonProperties.Data memory commonProperties = CommonProperties.Data(issuanceId, instrumentAddress,
            msg.sender, now, uint256(updatedState));

        // Persist common and custom properties
        saveIssuanceData(issuanceId, commonProperties, updatedProperties);

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
        (CommonProperties.Data memory commonProperties,
            string memory customPropertiesData) = loadIssuanceData(issuanceId);

        // Retrieve the issuance balance
        string memory balances = _escrow.getIssuanceBalances(issuanceId);
        Instrument instrument = Instrument(commonProperties.instrumentAddress);
        (Instrument.IssuanceStates updatedState, string memory updatedProperties,
            string memory transfers) = instrument.engage(issuanceId,
            Instrument.IssuanceStates(commonProperties.state),
            customPropertiesData, balances, msg.sender, buyerParameters);

        // Update issuance properties
        commonProperties.state = uint256(updatedState);
        saveIssuanceData(issuanceId, commonProperties, updatedProperties);

        // Post transferss
        processTransfers(issuanceId, transfers);

        emit IssuanceEngaged(issuanceId, address(commonProperties.instrumentAddress), msg.sender);
    }

    /**
     * @dev Inovked by seller/buyer to transfer Ether to the issuance. The Ether to be transferred
     *      must be deposited in the escrow already, so the transfer is done in the escrow internally.
     * Note: Instrument.processDeposit() is invoked AFTER the deposit is done so that balances show the balance
     * after the deposit.
     * Note: Instrument might revert the transfer in Instrument.processDeposit() if transfer is not supported.
     * @param issuanceId The id of the issuance to which the Ether is deposited
     * @param amount The amount of Ether, in wei, to transfer to the issuance
     */
    function deposit(uint256 issuanceId, uint256 amount) public {
        // Validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(amount > 0, "Deposit amount must be larger than 0.");

        // Retrieve common and custom properties
        (CommonProperties.Data memory commonProperties,
            string memory customPropertiesData) = loadIssuanceData(issuanceId);

        // Complete Ether transfer
        _escrow.transferToIssuance(msg.sender, issuanceId, amount);

        // Process the transfer event
        string memory balances = _escrow.getIssuanceBalances(issuanceId);
        Instrument instrument = Instrument(commonProperties.instrumentAddress);
        (Instrument.IssuanceStates updatedState, string memory updatedProperties,
            string memory transfers) = instrument.processDeposit(issuanceId,
            Instrument.IssuanceStates(commonProperties.state), customPropertiesData,
            balances, msg.sender, amount);

        // Update issuance properties
        commonProperties.state = uint256(updatedState);
        saveIssuanceData(issuanceId, commonProperties, updatedProperties);

        // Post-transferss
        processTransfers(issuanceId, transfers);
    }

     /**
     * @dev Inovked by seller/buyer to transfer ERC20 token to the issuance. The token to be transferred
     *      must be deposited in the escrow already, so the transfer is done in the escrow internally.
     * Note: Instrument.processTokenDeposit() is invoked AFTER the deposit is done so that balances show the balance
     * after the deposit.
     * Note: Instrument might revert the transfer in Instrument.processTokenDeposit() if transfer is not supported.
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
        (CommonProperties.Data memory commonProperties,
            string memory customPropertiesData) = loadIssuanceData(issuanceId);

        // Complete the token transfer
        _escrow.transferTokenToIssuance(msg.sender, issuanceId, ERC20(tokenAddress), amount);

        // Process the transfer event
        string memory balances = _escrow.getIssuanceBalances(issuanceId);
        Instrument instrument = Instrument(commonProperties.instrumentAddress);
        (Instrument.IssuanceStates updatedState, string memory updatedProperties,
            string memory transfers) = instrument.processTokenDeposit(issuanceId,
            Instrument.IssuanceStates(commonProperties.state), customPropertiesData,
            balances, msg.sender, tokenAddress, amount);

        // Update issuance properties
        commonProperties.state = uint256(updatedState);
        saveIssuanceData(issuanceId, commonProperties, updatedProperties);

        // Post-transferss
        processTransfers(issuanceId, transfers);
    }

    /**
     * @dev Inovked by seller/buyer to withdraw Ether from the issuance.
     * Note: Instrument.processWithdraw() is invoked AFTER the withdraw is done so that balances show the balance
     * after the withdraw.
     * Note: Instrument might revert the withdraw in Instrument.processWithdraw() if withdraw is not supported.
     * @param issuanceId The id of the issuance to which the Ether is deposited
     * @param amount The amount of Ether, in wei, to withdraw from the issuance
     */
    function withdraw(uint256 issuanceId, uint256 amount) public {
        // Validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(amount > 0, "Deposit amount must be larger than 0.");

        // Retrieve common and custom properties
        (CommonProperties.Data memory commonProperties,
            string memory customPropertiesData) = loadIssuanceData(issuanceId);

        // Complete Ether transfer
        _escrow.transferFromIssuance(msg.sender, issuanceId, amount);

        // Process the transfer event
        string memory balances = _escrow.getIssuanceBalances(issuanceId);
        Instrument instrument = Instrument(commonProperties.instrumentAddress);
        (Instrument.IssuanceStates updatedState, string memory updatedProperties,
            string memory transfers) = instrument.processWithdraw(issuanceId,
            Instrument.IssuanceStates(commonProperties.state), customPropertiesData,
            balances, msg.sender, amount);

        // Update issuance properties
        commonProperties.state = uint256(updatedState);
        saveIssuanceData(issuanceId, commonProperties, updatedProperties);

        // Post-transferss
        processTransfers(issuanceId, transfers);
    }

     /**
     * @dev Inovked by seller/buyer to withdraw ERC20 token from the issuance.
     * Note: Instrument.processTokenWithdraw() is invoked AFTER the withdraw is done so that balances show the balance
     * after the withdraw.
     * Note: Instrument might revert the withdraw in Instrument.processTokenWithdraw() if withdraw is not supported.
     * @param issuanceId The id of the issuance from which the token is withdrawn
     @ @param tokenAddress The address of the token
     * @param amount The amount of token to transfer to the issuance
     */
    function withdrawToken(uint256 issuanceId, address tokenAddress, uint256 amount) public {
        // Validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(tokenAddress != address(0x0), "Token address must be set.");
        require(amount > 0, "Deposit amount must be larger than 0.");

        // Retrieve common and custom properties
        (CommonProperties.Data memory commonProperties,
            string memory customPropertiesData) = loadIssuanceData(issuanceId);

        // Complete the token transfer
        _escrow.transferTokenFromIssuance(msg.sender, issuanceId, ERC20(tokenAddress), amount);

        // Process the transfer event
        string memory balances = _escrow.getIssuanceBalances(issuanceId);
        Instrument instrument = Instrument(commonProperties.instrumentAddress);
        (Instrument.IssuanceStates updatedState, string memory updatedProperties,
            string memory transfers) = instrument.processTokenWithdraw(issuanceId,
            Instrument.IssuanceStates(commonProperties.state), customPropertiesData,
            balances, msg.sender, tokenAddress, amount);

        // Update issuance properties
        commonProperties.state = uint256(updatedState);
        saveIssuanceData(issuanceId, commonProperties, updatedProperties);

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
        (CommonProperties.Data memory commonProperties,
            string memory customPropertiesData) = loadIssuanceData(issuanceId);

        // Retrieve the issuance balance
        string memory balances = _escrow.getIssuanceBalances(issuanceId);
        Instrument instrument = Instrument(commonProperties.instrumentAddress);
        (Instrument.IssuanceStates updatedState, string memory updatedProperties,
            string memory transfers) = instrument.processScheduledEvent(issuanceId,
            Instrument.IssuanceStates(commonProperties.state), customPropertiesData,
            balances, eventName, eventPayload);

        // Update issuance properties
        commonProperties.state = uint256(updatedState);
        saveIssuanceData(issuanceId, commonProperties, updatedProperties);

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

        (CommonProperties.Data memory commonProperties,
            string memory customPropertiesData) = loadIssuanceData(issuanceId);

        // Retrieve the issuance balance
        string memory balances = _escrow.getIssuanceBalances(issuanceId);
        Instrument instrument = Instrument(commonProperties.instrumentAddress);
        (Instrument.IssuanceStates updatedState, string memory updatedProperties,
            string memory transfers) = instrument.processCustomEvent(issuanceId,
            Instrument.IssuanceStates(commonProperties.state), customPropertiesData,
            balances, eventName, eventPayload);

        // Update the issuance data
        commonProperties.state = uint256(updatedState);
        saveIssuanceData(issuanceId, commonProperties, updatedProperties);

        // Post transfers
        processTransfers(issuanceId, transfers);
    }

    function loadIssuanceData(uint256 issuanceId) private view returns (CommonProperties.Data memory commonProperties,
        string memory customPropertiesData) {
        // Retrieve common and custom properties
        string memory commonPropertiesData = _storage.getValue(getIssuanceCommonDataKey(issuanceId));
        // Validate whether the issuance exists
        require(bytes(commonPropertiesData).length > 0, "Issuance does not exist.");
        commonProperties = CommonProperties.decode(bytes(commonPropertiesData));
        customPropertiesData = _storage.getValue(getIssuanceCustomDataKey(issuanceId));
    }

    function saveIssuanceData(uint256 issuanceId, CommonProperties.Data memory commonProperties,
        string memory customPropertiesData) private {
                // Update issuance properties
        _storage.setValue(getIssuanceCommonDataKey(issuanceId), string(commonProperties.encode()));
        _storage.setValue(getIssuanceCustomDataKey(issuanceId), customPropertiesData);
    }

    function getIssuanceCommonDataKey(uint256 issuanceId) private pure returns (string memory) {
        return StringUtil.concat(issuanceId, "_common");
    }

    function getIssuanceCustomDataKey(uint256 issuanceId) private pure returns (string memory) {
        return StringUtil.concat(issuanceId, "_custom");
    }

    /**
     * @dev Complete the transfers actions
     * @param issuanceId The id of the issuance which owns the Ether/token
     * @param transfers The transfer actions
     */
    function processTransfers(uint issuanceId, string memory transfers) private {
      Transfers.Data memory transferData = Transfers.decode(bytes(transfers));
      // Note: The Escrow performs validation of transfer against the balance,
      // so there is no need to do the validation here.
      for (uint i = 0; i < transferData.actions.length; i++) {
          if (transferData.actions[i].isEther) {
              _escrow.transferFromIssuance(transferData.actions[i].receiverAddress, issuanceId,
                  transferData.actions[i].amount);
          } else {
              _escrow.transferTokenFromIssuance(transferData.actions[i].receiverAddress, issuanceId,
                  ERC20(transferData.actions[i].tokenAddress), transferData.actions[i].amount);
          }
      }
    }
}
