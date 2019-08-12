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

    /**
     * @dev The event reporting the issuance properties change
     * @param issuanceId The id of the issuance
     * @param oldState The previous issuance state
     * @param newState The current issuance state
     */
    event IssuanceStateUpdated(uint256 indexed issuanceId, Instrument.IssuanceStates oldState,
        Instrument.IssuanceStates newState);

    // The sequence used to generate issuance id
    UnifiedStorage private _storage;
    InstrumentRegistry private _instrumentRegistry;
    NutsToken private _token;
    NutsEscrow private _escrow;
    uint256 constant TOKEN_AMOUNT = 10;
    string constant LAST_ISSUANCE_ID_KEY = "lastIssuanceId";

    constructor(address unifiedStorageAddress, address instrumentRegistryAddress,
        address nutsTokenAddress, address nutsEscrowAddress) public {
        _storage = UnifiedStorage(unifiedStorageAddress);
        _instrumentRegistry = InstrumentRegistry(instrumentRegistryAddress);
        _token = NutsToken(nutsTokenAddress);
        _escrow = NutsEscrow(nutsEscrowAddress);

        // Validations
        // require(_storage.isWhitelistAdmin(address(this)), "NutsPlatform: Not admin of UnifiedStorage.");
        // require(_instrumentRegistry.isWhitelistAdmin(address(this)), "NutsPlatform: Not admin of InstrumentRegistry.");
        // require(_escrow.isWhitelistAdmin(address(this)), "NutsPlatform: Not admin of NutsEscrow.");
    }

    /**
     * @dev Invoked by FSP to register a new instrument.
     * @param instrumentAddress The address of the instrument contract
     * @param expiration The lifetime of the issuance in days. 0 means never expires.
     */
    function createInstrument(address instrumentAddress, uint256 expiration) external onlyFsp {
        // Validations
        require(instrumentAddress != address(0x0), "NutsPlatform: Instrument address must be set.");

        _token.transferFrom(msg.sender, address(this), TOKEN_AMOUNT);
        _instrumentRegistry.create(msg.sender, instrumentAddress, expiration);

        emit InstrumentCreated(instrumentAddress, msg.sender);
    }

    /**
     * @dev Invoked by FSP to unregister an instrument
     * @param instrumentAddress The address of the instrument contract
     */
    function deactivateInstrument(address instrumentAddress) public onlyFsp {
        // Validations
        require(instrumentAddress != address(0x0), "NutsPlatform: Instrument address must be set.");

        _token.transfer(msg.sender, TOKEN_AMOUNT);
        _instrumentRegistry.deactivate(msg.sender, instrumentAddress);
    }

    /**
     * @dev Invoked by seller to create new issuance
     * @param instrumentAddress The address of the instrument of which the issuance is created
     * @param sellerParameters The custom parameter of seller
     * @return issuanceId The id of the newly created issuance
     */
    function createIssuance(address instrumentAddress, bytes memory sellerParameters) public returns (uint256) {
        // Validations
        require(instrumentAddress != address(0x0), "NutsPlatform: Instrument address must be set.");
        require(_instrumentRegistry.validate(instrumentAddress), "NutsPlatform: Invalid instrument");

        // Get the issuance id
        uint issuanceId = _storage.getUint(LAST_ISSUANCE_ID_KEY);
        _storage.setUint(LAST_ISSUANCE_ID_KEY, issuanceId + 1);
        Instrument instrument = Instrument(instrumentAddress);
        // Create a new UnifiedStorage instance for this issuance.
        // Nuts Platform has admin role by default.
        UnifiedStorage issuanceStorage = new UnifiedStorage();
        // Grant a temporary writer role to the instrument.
        issuanceStorage.addWriter(instrumentAddress);
        (Instrument.IssuanceStates updatedState, bytes memory transfers) = instrument.createIssuance(issuanceId,
            issuanceStorage, msg.sender, sellerParameters);
        // Revoke writer role afterward
        issuanceStorage.removeWriter(instrumentAddress);

        // Create a new property map for the issuance
        CommonProperties.Data memory commonProperties = CommonProperties.Data(issuanceId, instrumentAddress,
            msg.sender, address(issuanceStorage), now, uint256(updatedState));

        // Persist common  properties
        saveIssuanceProperties(issuanceId, commonProperties, updatedState);

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
    function engageIssuance(uint256 issuanceId, bytes memory buyerParameters) public {
        // Validation
        require(issuanceId > 0, "NutsPlatform: Issuance id must be set.");

        // Retrieve issuance common properties
        CommonProperties.Data memory commonProperties = getIssuanceProperties(issuanceId);
        // Retrieve the issuance balance
        bytes memory balances = _escrow.getIssuanceBalances(issuanceId);
        Instrument instrument = Instrument(commonProperties.instrumentAddress);
        UnifiedStorage issuanceStorage = UnifiedStorage(commonProperties.storageAddress);
        // Grant a temporary writer role to the instrument.
        issuanceStorage.addWriter(commonProperties.instrumentAddress);
        (Instrument.IssuanceStates updatedState, bytes memory transfers) = instrument.engage(issuanceId,
            Instrument.IssuanceStates(commonProperties.state), issuanceStorage,
            balances, msg.sender, buyerParameters);
        // Revoke writer role afterward
        issuanceStorage.removeWriter(commonProperties.instrumentAddress);

        // Persist common  properties
        saveIssuanceProperties(issuanceId, commonProperties, updatedState);

        // Post transferss
        processTransfers(issuanceId, transfers);

        emit IssuanceEngaged(issuanceId, commonProperties.instrumentAddress, msg.sender);
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
        require(issuanceId > 0, "NutsPlatform: Issuance id must be set.");
        require(amount > 0, "NutsPlatform: Deposit amount must be larger than 0.");

        // Retrieve issuance common properties
        CommonProperties.Data memory commonProperties = getIssuanceProperties(issuanceId);

        // Complete Ether transfer
        _escrow.transferToIssuance(msg.sender, issuanceId, amount);

        // Process the transfer event
        bytes memory balances = _escrow.getIssuanceBalances(issuanceId);
        Instrument instrument = Instrument(commonProperties.instrumentAddress);
        UnifiedStorage issuanceStorage = UnifiedStorage(commonProperties.storageAddress);
        // Grant a temporary writer role to the instrument.
        issuanceStorage.addWriter(commonProperties.instrumentAddress);
        (Instrument.IssuanceStates updatedState, bytes memory transfers) = instrument.processDeposit(issuanceId,
            Instrument.IssuanceStates(commonProperties.state), issuanceStorage,
            balances, msg.sender, amount);
        // Revoke writer role afterward
        issuanceStorage.removeWriter(commonProperties.instrumentAddress);

        // Persist common  properties
        saveIssuanceProperties(issuanceId, commonProperties, updatedState);

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
        require(issuanceId > 0, "NutsPlatform: Issuance id must be set.");
        require(tokenAddress != address(0x0), "NutsPlatform: Token address must be set.");
        require(amount > 0, "NutsPlatform: Deposit amount must be larger than 0.");

        // Retrieve issuance common properties
        CommonProperties.Data memory commonProperties = getIssuanceProperties(issuanceId);

        // Complete the token transfer
        _escrow.transferTokenToIssuance(msg.sender, issuanceId, ERC20(tokenAddress), amount);

        // Process the transfer event
        bytes memory balances = _escrow.getIssuanceBalances(issuanceId);
        Instrument instrument = Instrument(commonProperties.instrumentAddress);
        UnifiedStorage issuanceStorage = UnifiedStorage(commonProperties.storageAddress);
        // Grant a temporary writer role to the instrument.
        issuanceStorage.addWriter(commonProperties.instrumentAddress);
        (Instrument.IssuanceStates updatedState, bytes memory transfers) = instrument.processTokenDeposit(issuanceId,
            Instrument.IssuanceStates(commonProperties.state), issuanceStorage,
            balances, msg.sender, tokenAddress, amount);
        // Revoke writer role afterward
        issuanceStorage.removeWriter(commonProperties.instrumentAddress);

        // Persist common  properties
        saveIssuanceProperties(issuanceId, commonProperties, updatedState);

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
        require(issuanceId > 0, "NutsPlatform: Issuance id must be set.");
        require(amount > 0, "NutsPlatform: Deposit amount must be larger than 0.");

        // Retrieve issuance common properties
        CommonProperties.Data memory commonProperties = getIssuanceProperties(issuanceId);

        // Complete Ether transfer
        _escrow.transferFromIssuance(msg.sender, issuanceId, amount);

        // Process the transfer event
        bytes memory balances = _escrow.getIssuanceBalances(issuanceId);
        Instrument instrument = Instrument(commonProperties.instrumentAddress);
        UnifiedStorage issuanceStorage = UnifiedStorage(commonProperties.storageAddress);
        // Grant a temporary writer role to the instrument.
        issuanceStorage.addWriter(commonProperties.instrumentAddress);
        (Instrument.IssuanceStates updatedState, bytes memory transfers) = instrument.processWithdraw(issuanceId,
            Instrument.IssuanceStates(commonProperties.state), issuanceStorage,
            balances, msg.sender, amount);
        // Revoke writer role afterward
        issuanceStorage.removeWriter(commonProperties.instrumentAddress);

        // Persist common  properties
        saveIssuanceProperties(issuanceId, commonProperties, updatedState);

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
        require(issuanceId > 0, "NutsPlatform: Issuance id must be set.");
        require(tokenAddress != address(0x0), "NutsPlatform: Token address must be set.");
        require(amount > 0, "NutsPlatform: Deposit amount must be larger than 0.");

        // Retrieve issuance common properties
        CommonProperties.Data memory commonProperties = getIssuanceProperties(issuanceId);

        // Complete the token transfer
        _escrow.transferTokenFromIssuance(msg.sender, issuanceId, ERC20(tokenAddress), amount);

        // Process the transfer event
        bytes memory balances = _escrow.getIssuanceBalances(issuanceId);
        Instrument instrument = Instrument(commonProperties.instrumentAddress);
        UnifiedStorage issuanceStorage = UnifiedStorage(commonProperties.storageAddress);
        // Grant a temporary writer role to the instrument.
        issuanceStorage.addWriter(commonProperties.instrumentAddress);
        (Instrument.IssuanceStates updatedState, bytes memory transfers) = instrument.processTokenWithdraw(issuanceId,
            Instrument.IssuanceStates(commonProperties.state), issuanceStorage,
            balances, msg.sender, tokenAddress, amount);
        // Revoke writer role afterward
        issuanceStorage.removeWriter(commonProperties.instrumentAddress);

        // Persist common  properties
        saveIssuanceProperties(issuanceId, commonProperties, updatedState);

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
        bytes memory eventPayload) public onlyTimerOracle {
        // Validation
        require(issuanceId > 0, "NutsPlatform: Issuance id must be set.");
        require(bytes(eventName).length > 0, "NutsPlatform: Event name must be set.");
        require(timestamp <= now, "NutsPlatform: The scheduled event is not due now.");

        // Retrieve issuance common properties
        CommonProperties.Data memory commonProperties = getIssuanceProperties(issuanceId);

        // Retrieve the issuance balance
        bytes memory balances = _escrow.getIssuanceBalances(issuanceId);
        Instrument instrument = Instrument(commonProperties.instrumentAddress);
        UnifiedStorage issuanceStorage = UnifiedStorage(commonProperties.storageAddress);
        // Grant a temporary writer role to the instrument.
        issuanceStorage.addWriter(commonProperties.instrumentAddress);
        (Instrument.IssuanceStates updatedState, bytes memory transfers) = instrument.processScheduledEvent(issuanceId,
            Instrument.IssuanceStates(commonProperties.state), issuanceStorage,
            balances, eventName, eventPayload);
        // Revoke writer role afterward
        issuanceStorage.removeWriter(commonProperties.instrumentAddress);

        // Persist common  properties
        saveIssuanceProperties(issuanceId, commonProperties, updatedState);

        // Post transfers
        processTransfers(issuanceId, transfers);
    }

    /**
     * @dev Entry to process custom operations
     * @param issuanceId The id of the issuance
     * @param eventName Name of custom event, eventName of EventScheduled event
     * @param eventPayload Payload of custom event, eventPayload of EventScheduled event
     */
    function processCustomEvent(uint256 issuanceId, string memory eventName, bytes memory eventPayload) public {
        // Validation
        require(issuanceId > 0, "NutsPlatform: Issuance id must be set.");
        require(bytes(eventName).length > 0, "NutsPlatform: Event name must be set.");

        // Retrieve issuance common properties
        CommonProperties.Data memory commonProperties = getIssuanceProperties(issuanceId);

        // Retrieve the issuance balance
        bytes memory balances = _escrow.getIssuanceBalances(issuanceId);
        Instrument instrument = Instrument(commonProperties.instrumentAddress);
        UnifiedStorage issuanceStorage = UnifiedStorage(commonProperties.storageAddress);
        // Grant a temporary writer role to the instrument.
        issuanceStorage.addWriter(commonProperties.instrumentAddress);
        (Instrument.IssuanceStates updatedState, bytes memory transfers) = instrument.processCustomEvent(issuanceId,
            Instrument.IssuanceStates(commonProperties.state), issuanceStorage,
            balances, eventName, eventPayload);
        // Revoke writer role afterward
        issuanceStorage.removeWriter(commonProperties.instrumentAddress);

        // Persist common  properties
        saveIssuanceProperties(issuanceId, commonProperties, updatedState);

        // Post transfers
        processTransfers(issuanceId, transfers);
    }

    /**
     * @dev Gets issuance common properties from unified storage.
     */
    function getIssuanceProperties(uint256 issuanceId) private view returns (CommonProperties.Data memory commonProperties) {
        // Retrieve common and custom properties
        bytes memory commonPropertiesData = _storage.getBytes(getIssuanceCommonDataKey(issuanceId));
        // Validate whether the issuance exists
        require(bytes(commonPropertiesData).length > 0, "NutsPlatform: Issuance does not exist.");
        commonProperties = CommonProperties.decode(commonPropertiesData);
    }

    /**
     * @dev Updates issuance common properties to unified storage.
     */
    function saveIssuanceProperties(uint256 issuanceId, CommonProperties.Data memory commonProperties,
        Instrument.IssuanceStates updatedState) private {
        // Update issuance properties
        Instrument.IssuanceStates prevState = Instrument.IssuanceStates(commonProperties.state);
        if (updatedState != Instrument.IssuanceStates.Unmodified && updatedState != prevState) {
            commonProperties.state = uint(updatedState);
            emit IssuanceStateUpdated(issuanceId, prevState, updatedState);
        }
        _storage.setBytes(getIssuanceCommonDataKey(issuanceId), CommonProperties.encode(commonProperties));
    }

    function getIssuanceCommonDataKey(uint256 issuanceId) private pure returns (string memory) {
        return StringUtil.concat(issuanceId, "_common");
    }

    /**
     * @dev Complete the transfers actions
     * @param issuanceId The id of the issuance which owns the Ether/token
     * @param transfers The transfer actions
     */
    function processTransfers(uint issuanceId, bytes memory transfers) private {
      Transfers.Data memory transferData = Transfers.decode(transfers);
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
