pragma solidity ^0.5.0;

import "../storage/StorageInterface.sol";

/**
 * @title Base contract for financial instrument
 * All instrument contract must extend this contract.
 */
interface Instrument {

    // The states of an instrument.
    enum IssuanceStates {
        // The default value, which means that instrument will keep its original state.
        // This is useful if the instrument developers forget to set updated state.
        // Therefore, it's not a valid issuance state.
        Unmodified,
        // The issuance is initiated. It should be the starting state.
        Initiated,
        // The issuance is ready for engagement
        Engageable,
        // The issuance is active
        Active,
        // The issuance fails to meet the requirements make it engageable.
        // Unfunded is a terminating state.
        Unfunded,
        // The issuance is due with no engagement.
        // CompleteNotEngaged is a terminating state.
        CompleteNotEngaged,
        // The issuance is completed with active engagements.
        // ComplateEngaged is a terminating state.
        CompleteEngaged,
        // The issuance fails to meet the requirements to make it CompleteEngaged.
        // Deliquent is a terminating state.
        Delinquent
    }

    /**
     * @dev The event used to schedule contract events after specific time.
     * @param issuanceId The id of the issuance
     * @param timestamp After when the issuance should be notified
     * @param eventName The name of the custom event
     * @param eventPayload The payload the custom event
     */
    event EventTimeScheduled(uint256 indexed issuanceId, uint256 timestamp, string eventName, bytes eventPayload);

    /**
     * @dev The event used to schedule contract events after specific block.
     * @param issuanceId The id of the issuance
     * @param blockNumber After which block the issuance should be notified
     * @param eventName The name of the custom event
     * @param eventPayload The payload the custom event
     */
    event EventBlockScheduled(uint256 indexed issuanceId, uint256 blockNumber, string eventName, bytes eventPayload);

    /**
     * @dev The event used to schedule contract events after specific block.
     * @param issuanceId The id of the issuance
     * @param state The updated issuannce state
     */
    event IssuanceStateUpdated(uint256 indexed issuanceId, IssuanceStates state);

    /**
     * @dev Create a new issuance of the financial instrument
     * @param issuanceId The id of the issuance
     * @param issuanceStorage The storage contract created for this issuance
     * @param sellerAddress The address of the seller who creates this issuance
     * @param sellerParameters The custom parameters to the newly created issuance
     * @return updatedState The new state of the issuance.
     * @return transfers The transfers to perform after the invocation
     */
    function createIssuance(uint256 issuanceId, StorageInterface issuanceStorage, address sellerAddress, bytes calldata sellerParameters)
        external returns (IssuanceStates updatedState, bytes memory transfers);

    /**
     * @dev A buyer engages to the issuance
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param issuanceStorage The storage contract created for this issuance
     * @param balances The current balance of the issuance
     * @param buyerAddress The address of the buyer who engages in the issuance
     * @param buyerParameters The custom parameters to the new engagement
     * @return updatedState The new state of the issuance.
     * @return transfers The transfers to perform after the invocation
     */
    function engage(uint256 issuanceId, IssuanceStates state, StorageInterface issuanceStorage,
        bytes calldata balances, address buyerAddress, bytes calldata buyerParameters)
        external returns (IssuanceStates updatedState, bytes memory transfers);

    /**
     * @dev Buyer/Seller has made an Ether deposit to the issuance.
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param issuanceStorage The storage contract created for this issuance
     * @param balances The current balance of the issuance (after the deposit)
     * @param fromAddress The address of the Ether sender
     * @param amount The amount of Ether transfered
     * @return updatedState The new state of the issuance.
     * @return transfers The transfers to perform after the invocation
     */
    function processDeposit(uint256 issuanceId, IssuanceStates state, StorageInterface issuanceStorage,
        bytes calldata balances, address fromAddress, uint256 amount)
        external returns (IssuanceStates updatedState, bytes memory transfers);

    /**
     * @dev Buyer/Seller has made an ERC20 token deposit to the issuance
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param issuanceStorage The storage contract created for this issuance
     * @param balances The current balance of the issuance (after the deposit)
     * @param fromAddress The address of the ERC20 token sender
     * @param tokenAddress The address of the ERC20 token
     * @param amount The amount of ERC20 token transfered
     * @return updatedState The new state of the issuance.
     * @return transfers The transfers to perform after the invocation
     */
    function processTokenDeposit(uint256 issuanceId, IssuanceStates state, StorageInterface issuanceStorage,
        bytes calldata balances, address fromAddress, address tokenAddress, uint256 amount)
        external returns (IssuanceStates updatedState, bytes memory transfers);

    /**
     * @dev Buyer/Seller has made an Ether withdraw from the issuance
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param issuanceStorage The storage contract created for this issuance
     * @param balances The current balance of the issuance (after the withdraw)
     * @param toAddress The address of the Ether receiver
     * @param amount The amount of Ether transfered
     * @return updatedState The new state of the issuance.
     * @return transfers The transfers to perform after the invocation
     */
    function processWithdraw(uint256 issuanceId, IssuanceStates state, StorageInterface issuanceStorage,
        bytes calldata balances, address toAddress, uint256 amount)
        external returns (IssuanceStates updatedState, bytes memory transfers);

    /**
     * @dev Buyer/Seller has made an ERC20 token withdraw from the issuance
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param issuanceStorage The storage contract created for this issuance
     * @param balances The current balance of the issuance (after the withdraw)
     * @param toAddress The address of the ERC20 token receiver
     * @param tokenAddress The address of the ERC20 token
     * @param amount The amount of ERC20 token transfered
     * @return updatedState The new state of the issuance.
     * @return transfers The transfers to perform after the invocation
     */
    function processTokenWithdraw(uint256 issuanceId, IssuanceStates state, StorageInterface issuanceStorage,
        bytes calldata balances, address toAddress, address tokenAddress, uint256 amount)
        external returns (IssuanceStates updatedState, bytes memory transfers);

    /**
     * @dev Process scheduled event
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param issuanceStorage The storage contract created for this issuance
     * @param balances The current balance of the issuance (after the withdraw)
     * @param eventName Name of the custom event, eventName of EventScheduled event
     * @param eventPayload Payload of the custom event, eventPayload of EventScheduled event
     * @return updatedState The new state of the issuance.
     * @return transfers The transfers to perform after the invocation
     */
    function processScheduledEvent(uint256 issuanceId, IssuanceStates state, StorageInterface issuanceStorage,
        bytes calldata balances, string calldata eventName, bytes calldata eventPayload)
        external returns (IssuanceStates updatedState, bytes memory transfers);

    /**
     * @dev Process customer event
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param issuanceStorage The storage contract created for this issuance
     * @param balances The current balance of the issuance
     * @param eventName Name of the custom event, eventName of EventScheduled event
     * @param eventPayload Payload of the custom event, eventPayload of EventScheduled event
     * @return updatedState The new state of the issuance.
     * @return transfers The transfers to perform after the invocation
     */
    function processCustomEvent(uint256 issuanceId, IssuanceStates state, StorageInterface issuanceStorage,
        bytes calldata balances, string calldata eventName, bytes calldata eventPayload)
        external returns (IssuanceStates updatedState, bytes memory transfers);
}
