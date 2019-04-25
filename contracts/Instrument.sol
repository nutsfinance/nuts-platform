pragma solidity ^0.5.0;

import "./common/property/Property.sol";
import "./common/payment/Balance.sol";
import "./common/payment/Transfer.sol";

/**
 * @title Base contract for financial instrument
 * All instrument contract must extend this contract.
 */
contract Instrument {
    using Property for Property.Properties;
    using Balance for Balance.Balances;
    using Transfer for Transfer.Transfers;

    /**
     *
     *  Public APIs for Instruments
     *
     */

    /**
     * @dev An event used to schedule contract events in specific time.
     * @param issuanceId The id of the issuance
     * @param timestamp When the issuance is notified
     * @param eventName The name of the custom event
     * @param eventPayload The payload the custom event
     */
    event EventScheduled(uint indexed issuanceId, uint256 timestamp, 
        string indexed eventName, string eventPayload);

    /**
     * @dev An event reporting the issuance state change
     * @param issuanceId The id of the issuance
     * @param state The current issuance state
     */
    event StateUpdated(uint indexed issuanceId, string indexed state);

    /**
     * @dev Create a new issuance of the financial instrument
     * @param issuanceId The id of the issuance
     * @param sellerAddress The address of the seller who creates this issuance
     * @param sellerData The custom parameters to the newly created issuance
     * @return updatedState The updated issuance state
     * @return action The action to perform after the invocation
     */
    function createIssuance(uint256 issuanceId, address sellerAddress, string memory sellerData) 
        public returns (string memory updatedState, string memory action);

    /**
     * @dev A buyer engages to the issuance
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param balance The current balance of the issuance
     * @param buyerAddress The address of the buyer who engages in the issuance
     * @param buyerData The custom parameters to the new engagement
     * @return updatedState The updated issuance state
     * @return action The action to perform after the invocation
     */    
    function engage(uint256 issuanceId, string memory state, string memory balance, address buyerAddress, 
        string memory buyerData) public returns (string memory updatedState, string memory action);

    /**
     * @dev Buyer/Seller has made an Ether transfer to the issuance
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param balance The current balance of the issuance
     * @param fromAddress The address of the Ether sender
     * @param amount The amount of Ether transfered
     * @return updatedState The updated issuance state
     * @return action The action to perform after the invocation
     */ 
    function processTransfer(uint256 issuanceId, string memory state, string memory balance,
        address fromAddress, uint256 amount) public returns (string memory updatedState, string memory action);

    /**
     * @dev Buyer/Seller has made an ERC20 token transfer to the issuance
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param balance The current balance of the issuance
     * @param fromAddress The address of the ERC20 token sender
     * @param tokenAddress The address of the ERC20 token
     * @param amount The amount of ERC20 token transfered
     * @return updatedState The updated issuance state
     * @return action The action to perform after the invocation
     */ 
    function processTokenTransfer(uint256 issuanceId, string memory state, string memory balance,
        address fromAddress, address tokenAddress, uint256 amount) 
        public returns (string memory updatedState, string memory action);

    /**
     * @dev Process customer event
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param balance The current balance of the issuance
     * @param eventName Name of the custom event, eventName of EventScheduled event
     * @param eventPayload Payload of the custom event, eventPayload of EventScheduled event
     * @return updatedState The updated issuance state
     * @return action The action to perform after the invocation
     */ 
    function processEvent(uint256 issuanceId, string memory state, string memory balance, 
        string memory eventName, string memory eventPayload) public returns (string memory updatedState, string memory action);

    /**
     *
     *  Internal utility functions for instruments
     *
     */
    // Current state of the issuance
    Property.Properties internal _properties;
    // Custom parameters
    Property.Properties internal _parameters;
    // Current balance of the issuance
    Balance.Balances internal _balances;
    // Transfer actions to take
    Transfer.Transfers internal _transfers;

    
}