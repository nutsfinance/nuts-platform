pragma solidity ^0.5.0;

import "./TokenBalance.sol";

/**
 * @title Base contract for financial instrument
 * All instrument contract must extend this contract.
 */
contract Instrument {

    enum IssuanceStates {
        Initiated, Engageable, Active, Unfunded, CompleteNotEngaged, CompleteEngaged, Delinquent
    }

    /**
     * @dev The event used to schedule contract events in specific time.
     * @param issuanceId The id of the issuance
     * @param timestamp When the issuance should be notified
     * @param eventName The name of the custom event
     * @param eventPayload The payload the custom event
     */
    event EventScheduled(uint256 indexed issuanceId, uint256 timestamp, string eventName, string eventPayload);

    /**
     * @dev The event reporting the issuance properties change
     * @param issuanceId The id of the issuance
     * @param state The current issuance state
     */
    event IssuanceStateUpdated(uint256 indexed issuanceId, string state);

    /**
     * @dev Create a new issuance of the financial instrument
     * @param issuanceId The id of the issuance
     * @param sellerAddress The address of the seller who creates this issuance
     * @param sellerParameters The custom parameters to the newly created issuance
     * @return updatedState The new state of the issuance.
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function createIssuance(uint256 issuanceId, address sellerAddress, string memory sellerParameters)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers);

    /**
     * @dev A buyer engages to the issuance
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param properties The current properties of the issuance
     * @param balances The current balance of the issuance
     * @param buyerAddress The address of the buyer who engages in the issuance
     * @param buyerParameters The custom parameters to the new engagement
     * @return updatedState The new state of the issuance.
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function engage(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, address buyerAddress, string memory buyerParameters)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers);

    /**
     * @dev Buyer/Seller has made an Ether deposit to the issuance.
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param properties The current properties of the issuance
     * @param balances The current balance of the issuance (after the deposit)
     * @param fromAddress The address of the Ether sender
     * @param amount The amount of Ether transfered
     * @return updatedState The new state of the issuance.
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processDeposit(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, address fromAddress, uint256 amount)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers);

    /**
     * @dev Buyer/Seller has made an ERC20 token deposit to the issuance
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param properties The current properties of the issuance
     * @param balances The current balance of the issuance (after the deposit)
     * @param fromAddress The address of the ERC20 token sender
     * @param tokenAddress The address of the ERC20 token
     * @param amount The amount of ERC20 token transfered
     * @return updatedState The new state of the issuance.
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processTokenDeposit(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, address fromAddress, address tokenAddress, uint256 amount)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers);

    /**
     * @dev Buyer/Seller has made an Ether withdraw from the issuance
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param properties The current properties of the issuance
     * @param balances The current balance of the issuance (after the withdraw)
     * @param fromAddress The address of the Ether sender
     * @param amount The amount of Ether transfered
     * @return updatedState The new state of the issuance.
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processWithdraw(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, address fromAddress, uint256 amount)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers);

    /**
     * @dev Buyer/Seller has made an ERC20 token withdraw from the issuance
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param properties The current properties of the issuance
     * @param balances The current balance of the issuance (after the withdraw)
     * @param fromAddress The address of the ERC20 token sender
     * @param tokenAddress The address of the ERC20 token
     * @param amount The amount of ERC20 token transfered
     * @return updatedState The new state of the issuance.
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processTokenWithdraw(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, address fromAddress, address tokenAddress, uint256 amount)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers);

    /**
     * @dev Process scheduled event
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param properties The current properties of the issuance
     * @param balances The current balance of the issuance (after the withdraw)
     * @param eventName Name of the custom event, eventName of EventScheduled event
     * @param eventPayload Payload of the custom event, eventPayload of EventScheduled event
     * @return updatedState The new state of the issuance.
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processScheduledEvent(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, string memory eventName, string memory eventPayload)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers);

    /**
     * @dev Process customer event
     * @param issuanceId The id of the issuance
     * @param state The current state of the issuance
     * @param properties The current properties of the issuance
     * @param balances The current balance of the issuance
     * @param eventName Name of the custom event, eventName of EventScheduled event
     * @param eventPayload Payload of the custom event, eventPayload of EventScheduled event
     * @return updatedState The new state of the issuance.
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processCustomEvent(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, string memory eventName, string memory eventPayload)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers);

    /**********************************************
     * Utility methods
     ***********************************************/
    /**
     * @dev Get ETH balance. Note that we assume that there is at most one ETH balance entry.
     */
    function getEtherBalance(Balances.Data memory balances) internal pure returns (uint256) {
        for (uint i = 0; i < balances.entries.length; i++) {
            if (balances.entries[i].isEther) {
                return balances.entries[i].amount;
            }
        }

        return 0;
    }

    /**
     * @dev Get ERC20 token balance. Note that we assume that there is at most one balance entry per token.
     */
    function getTokenBalance(Balances.Data memory balances, address tokenAddress) internal pure returns (uint256) {
        for (uint i = 0; i < balances.entries.length; i++) {
            if (!balances.entries[i].isEther && balances.entries[i].tokenAddress == tokenAddress) {
                return balances.entries[i].amount;
            }
        }

        return 0;
    }
}
