pragma solidity ^0.5.0;

/**
 *  @title Financial instrument interface
 */
contract Instrument {

    event EventScheduled(string indexed issuance_id, string indexed event_name, 
        uint256 timestamp, string event_payload);

    /**
     *  Create a new issuance of the financial instrument
     */
    function createIssuance(uint256 issuance_id, string calldata state) 
        external returns (string memory);

    /**
     * A buyer engages to the issuance
     */    
    function engage(uint256 issuance_id, string calldata state, 
        uint256 engagement_id) external returns (string memory);

    /**
     * Buyer/Seller has made a transfer of Ether to the issuance
     */ 
    function processTransfer(uint256 issuance_id, string calldata state,
        address from, uint256 amount) external returns (string memory);

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