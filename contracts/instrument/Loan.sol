pragma solidity ^0.5.0;

import "../Instrument.sol";

/**
 * The loan contract is a contract that buyer borrows in Ethers by
 * depositing token as collaterals.
 */
contract Loan is Instrument {

    /**
     * @dev Create a new issuance of the financial instrument
     * @param issuance_id The id of the issuance
     * @param seller_address The address of the seller who creates this issuance
     * @param seller_data The custom parameters to the newly created issuance
     * @return updated_state The updated issuance state
     * @return action The action to perform after the invocation
     */
    function createIssuance(uint256 issuance_id, address seller_address, string memory seller_data) 
        public returns (string memory updated_state, string memory action) {
        // Parse parameters
        _parameters.clear();
        _parameters.parseParameters(seller_data);
        address collateral_token = _parameters.getAddressValue("CollateralToken");
        uint collateral_amount = _parameters.getUintValue("CollateralAmount");
        uint borrow_amount = _parameters.getUintValue("BorrowAmount");
        uint deposit_due_days = _parameters.getUintValue("DepositDueDays");
        uint collateral_due_days = _parameters.getUintValue("CollateralDueDays");
        uint tenor_days = _parameters.getUintValue("TenorDays");
        uint interest_rate = _parameters.getUintValue("InterestRate");

        // Set states
        _properties.clear();
        _properties.setAddressValue("seller_address", seller_address);
        _properties.setAddressValue("collateral_token_address", collateral_token);
        _properties.setUintValue("collateral_amount", collateral_amount);
        _properties.setUintValue("borrow_amount", borrow_amount);
        _properties.setUintValue("start_date", now);
        _properties.setUintValue("collateral_due_days", now + collateral_due_days);
        _properties.setUintValue("tenor_days", tenor_days);
        _properties.setUintValue("interest_rate", interest_rate);
        _properties.setStringValue("state", "Initiated");

        // Set expiration for deposit
        emit EventScheduled(issuance_id, now + deposit_due_days * 1 days, "deposit_expired", "");

        // Set expiration for issuance
        emit EventScheduled(issuance_id, now + tenor_days * 1 days, "issuance_expired", "");

        // Emit state updated event
        emit StateUpdated(issuance_id, "Initiated");

        // Persist the states
        updated_state = string(_properties.save());

        // Clean up
        _parameters.clear();
        _properties.clear();
    }

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
    function engage(uint256 issuance_id, string memory state, string memory balance, address buyer_address, 
        string memory buyer_data) public returns (string memory updated_state, string memory action) {
        // Load properties
        _properties.clear();
        _properties.load(bytes(state));

        require(StringUtil.equals(_properties.getStringValue("state"), "Engagable"), "Issuance must be in the Engagable state");

        _properties.setAddressValue("buyer_address", buyer_address);
        _properties.setUintValue("engage_date", now);
        _properties.setStringValue("state", "Active");

        // Set expiration for collateral
        uint collateral_due_days = _properties.getUintValue("collateral_due_days");
        emit EventScheduled(issuance_id, now + collateral_due_days * 1 days, "collateral_expired", "");

        // Emit state updated event
        emit StateUpdated(issuance_id, "Active");

        // Persist the states
        updated_state = string(_properties.save());

        // Clean up
        _properties.clear();
    }

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
    function processTransfer(uint256 issuance_id, string memory state, string memory balance,
        address from_address, uint256 amount) public returns (string memory updated_state, string memory action) {
        // Load properties
        _properties.clear();
        _properties.load(bytes(state));

        // Load balance
        _balances.clear();
        _balances.load(bytes(balance));

        // Check it's from the seller or the buyer
        if (_properties.getAddressValue("seller_address") == from_address) {
            // The Ether transfer is from the seller, this should be the deposit
            // Check whether the Ether balance is larger than the borrow amount
            if ( StringUtil.equals(_properties.getStringValue("state"), "Initiated")
                && _balances.getEtherBalance() >= _properties.getUintValue("borrow_amount")) {
                // Change to Enagagble state
                _properties.setStringValue("state", "Engagable");

                // Emit state updated event
                emit StateUpdated(issuance_id, "Engagable");
            }
        } else if (_properties.getAddressOrDefault("buyer_address", address(0x0)) == from_address) {
            // The Ether transfer is from the buyer, this should be the repay
            // If it's in Active state, repay is complete, and collateral is complete
            if ( StringUtil.equals(_properties.getStringValue("state"), "Active")
                && _balances.getEtherBalance() >= _properties.getUintValue("borrow_amount")
                && _properties.getBoolOrDefault("collateral_complete", false)) {
                
                // Change to Completed Engaged state
                _properties.setStringValue("state", "Completed Engaged");

                // Emit state updated event
                emit StateUpdated(issuance_id, "Completed Engaged");

                // Also add transfers
                _transfers.clear();
                // Transfer Ethers back to seller
                _transfers.addEtherTransfer(_properties.getAddressValue("seller_address"),
                     _properties.getUintValue("borrow_amount"));
                // Transfer collateral token back to buyer
                _transfers.addTokenTransfer(_properties.getAddressValue("collateral_token_address"),
                    _properties.getAddressValue("buyer_address"), 
                    _properties.getUintValue("collateral_amount"));
                // TODO If the Ether balance is more than the borrow amount, return to buyer?
                // ToDO If the token balance is more than the collateral amount, return to seller?
                action = string(_transfers.save());
                _transfers.clear();
            }
        }

        // Persist the states
        updated_state = string(_properties.save());

        // Clean up
        _properties.clear();
        _balances.clear();
    }

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
    function processTokenTransfer(uint256 issuance_id, string memory state, string memory balance,
        address from_address, address token_address, uint256 amount) 
        public returns (string memory updated_state, string memory action) {
        // Load properties
        _properties.clear();
        _properties.load(bytes(state));

        // Load balance
        _balances.clear();
        _balances.load(bytes(balance));

        // Check whether the transfer is from the buyer
        if (_properties.getAddressOrDefault("buyer_address", address(0x0)) == from_address) {
            // Collateral; check whether the colleteral is complete
            if ( StringUtil.equals(_properties.getStringValue("state"), "Initiated")
                && _properties.getAddressValue("collateral_token_address") == token_address
                && _balances.getEtherBalance() >= _properties.getUintValue("borrow_amount")
                && !_properties.getBoolOrDefault("collateral_complete", false)) {

                _properties.setBoolValue("collateral_complete", true);

                // Change to Active state
                _properties.setStringValue("state", "Active");

                // Emit state updated event
                emit StateUpdated(issuance_id, "Active");

                // Transfer Ether to buyer
                _transfers.clear();
                _transfers.addEtherTransfer(_properties.getAddressValue("buyer_address"),
                     _properties.getUintValue("borrow_amount"));
                action = string(_transfers.save());
                _transfers.clear();
            }
        }

        // Persist the states
        updated_state = string(_properties.save());

        // Clean up
        _properties.clear();
        _balances.clear();
    }

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
    function processEvent(uint256 issuance_id, string memory state, string memory balance, 
        string memory event_name, string memory event_payload) public returns (string memory updated_state, string memory action) {
        
        // Load properties
        _properties.clear();
        _properties.load(bytes(state));

        // Check for deposit_expired event
        if (StringUtil.equals(event_name, "deposit_expired")) {
            // Check whether the issuance is still in Initiated state
            if (StringUtil.equals(_properties.getStringValue("state"), "Initiated")) {
                // Changed to unfunded state
                _properties.setStringValue("state", "Unfunded");

                // Emit state updated event
                emit StateUpdated(issuance_id, "Unfunded");
            }
        } else if (StringUtil.equals(event_name, "collateral_expired")) {
            // Check whether the issuance is still in Active state
            // and the collateral is not complete
            if (StringUtil.equals(_properties.getStringValue("state"), "Active")
                && !_properties.getBoolOrDefault("collateral_complete", false)) {
                _properties.setStringValue("state", "Delinquent");

                // Emit state updated event
                emit StateUpdated(issuance_id, "Delinquent");
            }
        } else if (StringUtil.equals(event_name, "issuance_expired")) {
            // Check whether the issuance is still active
            if (StringUtil.equals(_properties.getStringValue("state"), "Active")) {
                _properties.setStringValue("state", "Delinquent");

                // Emit state updated event
                emit StateUpdated(issuance_id, "Delinquent");
            }
        }

        // Persist the states
        updated_state = string(_properties.save());

        // Clean up
        _properties.clear();
    }
    
}