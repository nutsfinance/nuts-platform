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
     * @dev The event used to schedule contract events in specific time.
     * @param issuanceId The id of the issuance
     * @param timestamp When the issuance is notified
     * @param eventName The name of the custom event
     * @param eventPayload The payload the custom event
     */
    event EventScheduled(uint indexed issuanceId, uint256 timestamp,
        string indexed eventName, string eventPayload);

    /**
     * @dev The event reporting the issuance properties change
     * @param issuanceId The id of the issuance
     * @param properties The current issuance properties
     */
    event StateUpdated(uint indexed issuanceId, string indexed properties);

    /**
     * @dev Create a new issuance of the financial instrument
     * @param issuanceId The id of the issuance
     * @param sellerAddress The address of the seller who creates this issuance
     * @param sellerParameters The custom parameters to the newly created issuance
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function createIssuance(uint256 issuanceId, address sellerAddress, string memory sellerParameters)
        public returns (string memory updatedProperties, string memory transfers);

    /**
     * @dev A buyer engages to the issuance
     * @param issuanceId The id of the issuance
     * @param properties The current properties of the issuance
     * @param balance The current balance of the issuance
     * @param buyerAddress The address of the buyer who engages in the issuance
     * @param buyerParameters The custom parameters to the new engagement
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function engage(uint256 issuanceId, string memory properties, string memory balance, address buyerAddress,
        string memory buyerParameters) public returns (string memory updatedProperties, string memory transfers);

    /**
     * @dev Buyer/Seller has made an Ether transfer to the issuance
     * @param issuanceId The id of the issuance
     * @param properties The current properties of the issuance
     * @param balance The current balance of the issuance
     * @param fromAddress The address of the Ether sender
     * @param amount The amount of Ether transfered
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processTransfer(uint256 issuanceId, string memory properties, string memory balance,
        address fromAddress, uint256 amount) public returns (string memory updatedProperties, string memory transfers);

    /**
     * @dev Buyer/Seller has made an ERC20 token transfer to the issuance
     * @param issuanceId The id of the issuance
     * @param properties The current properties of the issuance
     * @param balance The current balance of the issuance
     * @param fromAddress The address of the ERC20 token sender
     * @param tokenAddress The address of the ERC20 token
     * @param amount The amount of ERC20 token transfered
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processTokenTransfer(uint256 issuanceId, string memory properties, string memory balance,
        address fromAddress, address tokenAddress, uint256 amount)
        public returns (string memory updatedProperties, string memory transfers);

    /**
     * @dev Process scheduled event
     * @param issuanceId The id of the issuance
     * @param properties The current properties of the issuance
     * @param balance The current balance of the issuance
     * @param eventName Name of the custom event, eventName of EventScheduled event
     * @param eventPayload Payload of the custom event, eventPayload of EventScheduled event
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processScheduledEvent(uint256 issuanceId, string memory properties, string memory balance,
        string memory eventName, string memory eventPayload) public returns (string memory updatedProperties, string memory transfers);

    /**
     * @dev Process customer event
     * @param issuanceId The id of the issuance
     * @param properties The current properties of the issuance
     * @param balance The current balance of the issuance
     * @param eventName Name of the custom event, eventName of EventScheduled event
     * @param eventPayload Payload of the custom event, eventPayload of EventScheduled event
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processCustomEvent(uint256 issuanceId, string memory properties, string memory balance,
        string memory eventName, string memory eventPayload) public returns (string memory updatedProperties, string memory transfers);

    /**
     *
     *  Internal utility functions for instruments
     *
     */
    // Current properties of the issuance
    Property.Properties internal _properties;
    // Custom parameters
    Property.Properties internal _parameters;
    // Current balance of the issuance
    Balance.Balances internal _balances;
    // Transfer transferss to take
    Transfer.Transfers internal _transfers;

    // Issuance state constants
    string constant INITIATED_STATE = "Initiated";
    string constant ENGAGABLE_STATE = "Engagable";
    string constant ACTIVE_STATE = "Active";
    string constant UNFUNDED_STATE = "Unfunded";
    string constant COMPLETE_NOT_ENGAGED_STATE = "Complete Not Engaged";
    string constant COMPLETE_ENGAGED_STATE = "Complete Engaged";
    string constant DELINQUENT_STATE = "Delinquent";

    /**
     * @dev Check whether the issuance is currently in a state
     * @param state The state to check
     * @return True is the issuance is in this state
     */
    function isIssuanceInState(string memory state) internal view returns (bool) {
        return StringUtil.equals(_properties.getStringValue("state"), state);
    }

    /**
     * @dev Updates the state of the issuance.
     * @param issuanceId The issuance id
     * @param state The updated issuance state
     */
    function updateIssuanceState(uint issuanceId, string memory state) internal {
        _properties.setStringValue("state", state);
        emit StateUpdated(issuanceId, state);
    }
}