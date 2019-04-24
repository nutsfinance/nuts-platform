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
     * @param issuance_id The id of the issuance
     * @param timestamp When the issuance is notified
     * @param event_name The name of the custom event
     * @param event_payload The payload the custom event
     */
    event EventScheduled(string indexed issuance_id, uint256 timestamp, 
        string indexed event_name, string event_payload);

    /**
     * @dev Create a new issuance of the financial instrument
     * @param issuance_id The id of the issuance
     * @param seller_address The address of the seller who creates this issuance
     * @param seller_data The custom parameters to the newly created issuance
     * @return updated_state The updated issuance state
     * @return action The action to perform after the invocation
     */
    function createIssuance(uint256 issuance_id, address seller_address, string calldata seller_data) 
        external returns (string memory updated_state, string memory action);

    /**
     * @dev A buyer engages to the issuance
     * @param issuance_id The id of the issuance
     * @param state The current state of the issuance
     * @param balance The current balance of the issuance
     * @param buyer_address The address of the buyer who engages in the issuance
     * @param buyer_data The custom parameters to the new engagement
     * @return updated_state The updated issuance state
     * @return action The action to perform after the invocation
     */    
    function engage(uint256 issuance_id, string calldata state, string calldata balance, address buyer_address, 
        string calldata buyer_data) external returns (string memory updated_state, string memory action);

    /**
     * @dev Buyer/Seller has made an Ether transfer to the issuance
     * @param issuance_id The id of the issuance
     * @param state The current state of the issuance
     * @param balance The current balance of the issuance
     * @param from_address The address of the Ether sender
     * @param amount The amount of Ether transfered
     * @return updated_state The updated issuance state
     * @return action The action to perform after the invocation
     */ 
    function processTransfer(uint256 issuance_id, string calldata state, string calldata balance,
        address from_address, uint256 amount) external returns (string memory updated_state, string memory action);

    /**
     * @dev Buyer/Seller has made an ERC20 token transfer to the issuance
     * @param issuance_id The id of the issuance
     * @param state The current state of the issuance
     * @param balance The current balance of the issuance
     * @param from_address The address of the ERC20 token sender
     * @param token_address The address of the ERC20 token
     * @param amount The amount of ERC20 token transfered
     * @return updated_state The updated issuance state
     * @return action The action to perform after the invocation
     */ 
    function processTokenTransfer(uint256 issuance_id, string calldata state, string calldata balance,
        address from_address, address token_address, uint256 amount) 
        external returns (string memory updated_address, string memory action);

    /**
     * @dev Process customer event
     * @param issuance_id The id of the issuance
     * @param state The current state of the issuance
     * @param balance The current balance of the issuance
     * @param event_name Name of the custom event, event_name of EventScheduled event
     * @param event_payload Payload of the custom event, event_payload of EventScheduled event
     * @return updated_state The updated issuance state
     * @return action The action to perform after the invocation
     */ 
    function processEvent(uint256 issuance_id, string calldata state, string calldata balance, 
        string calldata event_name, string calldata event_payload) external returns (string memory updated_state, string memory action);

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