pragma solidity ^0.5.0;

/**
 * @title Financial instrument interface
 * All instrument contract must implement this interface.
 */
contract Instrument {

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
     * @return state The updated issuance state
     */
    function createIssuance(uint256 issuance_id, address seller_address, string calldata seller_data) 
        external returns (string memory state);

    /**
     * @dev A buyer engages to the issuance
     * @param issuance_id The id of the issuance
     * @param state The current state of the issuance
     * @param buyer_address The address of the buyer who engages in the issuance
     * @param buyer_data The custom parameters to the new engagement
     * @return new_state The updated issuance state
     */    
    function engage(uint256 issuance_id, string calldata state, address buyer_address, 
        string calldata buyer_data) external returns (string memory new_state);

    /**
     * Buyer/Seller has made a transfer of Ether to the issuance
     */ 
    function processTransfer(uint256 issuance_id, string calldata state,
        address from, uint256 amount) external returns (string memory updated_state, string memory action);

    /**
     * Buyer/Seller has made a transfer of ERC20 token to the issuance
     */ 
    function processTokenTransfer(uint256 issuance_id, string calldata state,
        address from, address token, uint256 amount) external returns (string memory);

    /**
     * Process customer event
     */ 
    function processEvent(uint256 issuance_id, string calldata state,
        string calldata event_name, string calldata event_payload) external returns (string memory);
}