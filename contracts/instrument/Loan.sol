pragma solidity ^0.5.0;

import "../Instrument.sol";

/**
 * The loan contract is a contract that buyer borrows in Ethers by
 * depositing token as collaterals.
 */
contract Loan is Instrument {

    /**
     * @dev Create a new issuance of the financial instrument
     * @param issuanceId The id of the issuance
     * @param sellerAddress The address of the seller who creates this issuance
     * @param sellerParameters The custom parameters to the newly created issuance
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function createIssuance(uint256 issuanceId, address sellerAddress, string memory sellerParameters) 
        public returns (string memory updatedProperties, string memory transfers) {
        // Parse parameters
        _parameters.clear();
        _parameters.parseParameters(sellerParameters);
        address collateralTokenAddress = _parameters.getAddressValue("collateral-token-address");
        uint collateralAmount = _parameters.getUintValue("collateral-amount");
        uint borrowAmount = _parameters.getUintValue("borrow-amount");
        uint depositDueDays = _parameters.getUintValue("deposit-due-days");
        uint collateralDueDays = _parameters.getUintValue("collateral-due-days");
        uint tenorDays = _parameters.getUintValue("tenor-days");
        uint interestRate = _parameters.getUintValue("interest-rate");

        // Set propertiess
        _properties.clear();
        _properties.setAddressValue("seller_address", sellerAddress);
        _properties.setAddressValue("collateral_token_address", collateralTokenAddress);
        _properties.setUintValue("collateral_amount", collateralAmount);
        _properties.setUintValue("borrow_amount", borrowAmount);
        _properties.setUintValue("start_date", now);
        _properties.setUintValue("collateral_due_days", now + collateralDueDays);
        _properties.setUintValue("tenor_days", tenorDays);
        _properties.setUintValue("interest_rate", interestRate);

        // Set expiration for deposit
        emit EventScheduled(issuanceId, now + depositDueDays * 1 days, "deposit_expired", "");

        // Set expiration for issuance
        emit EventScheduled(issuanceId, now + tenorDays * 1 days, "issuance_expired", "");

        // Change to Initiated state
        updateIssuanceState(issuanceId, INITIATED_STATE);

        // Persist the propertiess
        updatedProperties = string(_properties.save());

        // Clean up
        _parameters.clear();
        _properties.clear();
    }

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
        string memory buyerParameters) public returns (string memory updatedProperties, string memory transfers) {
        // Load properties
        _properties.clear();
        _properties.load(bytes(properties));

        require(isIssuanceInState(ENGAGABLE_STATE), "Issuance must be in the Engagable properties");

        _properties.setAddressValue("buyer_address", buyerAddress);
        _properties.setUintValue("engage_date", now);

        // Set expiration for collateral
        uint collateralDueDays = _properties.getUintValue("collateral_due_days");
        emit EventScheduled(issuanceId, now + collateralDueDays * 1 days, "collateral_expired", "");

        // Change to Active state
        updateIssuanceState(issuanceId, ACTIVE_STATE);

        // Persist the propertiess
        updatedProperties = string(_properties.save());

        // Clean up
        _properties.clear();
    }

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
        address fromAddress, uint256 amount) public returns (string memory updatedProperties, string memory transfers) {
        // Load properties
        _properties.clear();
        _properties.load(bytes(properties));

        // Load balance
        _balances.clear();
        _balances.load(bytes(balance));

        // Check it's from the seller or the buyer
        if (_properties.getAddressValue("seller_address") == fromAddress) {
            // The Ether transfer is from the seller, this should be the deposit
            // Check whether the Ether balance is larger than the borrow amount
            if ( isIssuanceInState(INITIATED_STATE)
                && _balances.getEtherBalance() >= _properties.getUintValue("borrow_amount")) {
                
                // Change to Engagable state
                updateIssuanceState(issuanceId, ENGAGABLE_STATE);
            }
        } else if (_properties.getAddressOrDefault("buyer_address", address(0x0)) == fromAddress) {
            // The Ether transfer is from the buyer, this should be the repay
            // If it's in Active state, repay is complete, and collateral is complete
            if ( isIssuanceInState(ACTIVE_STATE)
                && _balances.getEtherBalance() >= _properties.getUintValue("borrow_amount")
                && _properties.getBoolOrDefault("collateral_complete", false)) {
                
                // Change to Complete Engaged state
                updateIssuanceState(issuanceId, COMPLETE_ENGAGED_STATE);

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
                transfers = string(_transfers.save());
                _transfers.clear();
            }
        }

        // Persist the propertiess
        updatedProperties = string(_properties.save());

        // Clean up
        _properties.clear();
        _balances.clear();
    }

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
        public returns (string memory updatedProperties, string memory transfers) {
        // Load properties
        _properties.clear();
        _properties.load(bytes(properties));

        // Load balance
        _balances.clear();
        _balances.load(bytes(balance));

        // Check whether the transfer is from the buyer
        if (_properties.getAddressOrDefault("buyer_address", address(0x0)) == fromAddress) {
            // Collateral; check whether the colleteral is complete
            if ( isIssuanceInState(INITIATED_STATE)
                && _properties.getAddressValue("collateral_token_address") == tokenAddress
                && _balances.getEtherBalance() >= _properties.getUintValue("borrow_amount")
                && !_properties.getBoolOrDefault("collateral_complete", false)) {

                _properties.setBoolValue("collateral_complete", true);

                // Change to Active state
                updateIssuanceState(issuanceId, ACTIVE_STATE);

                // Transfer Ether to buyer
                _transfers.clear();
                _transfers.addEtherTransfer(_properties.getAddressValue("buyer_address"),
                     _properties.getUintValue("borrow_amount"));
                transfers = string(_transfers.save());
                _transfers.clear();
            }
        }

        // Persist the propertiess
        updatedProperties = string(_properties.save());

        // Clean up
        _properties.clear();
        _balances.clear();
    }

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
    function processEvent(uint256 issuanceId, string memory properties, string memory balance, 
        string memory eventName, string memory eventPayload) public returns (string memory updatedProperties, string memory transfers) {
        
        // Load properties
        _properties.clear();
        _properties.load(bytes(properties));

        // Check for deposit_expired event
        if (StringUtil.equals(eventName, "deposit_expired")) {
            // Check whether the issuance is still in Initiated state
            if (isIssuanceInState(INITIATED_STATE)) {
                
                // Change to Unfunded state
                updateIssuanceState(issuanceId, UNFUNDED_STATE);
            }
        } else if (StringUtil.equals(eventName, "collateral_expired")) {
            // Check whether the issuance is still in Active state
            // and the collateral is not complete
            if (isIssuanceInState(ACTIVE_STATE)
                && !_properties.getBoolOrDefault("collateral_complete", false)) {
                
                // Change to Delinquent state
                updateIssuanceState(issuanceId, DELINQUENT_STATE);
            }
        } else if (StringUtil.equals(eventName, "issuance_expired")) {
            // Check whether the issuance is still active
            if (isIssuanceInState(ACTIVE_STATE)) {

                // Change to Delinquent state
                updateIssuanceState(issuanceId, DELINQUENT_STATE);
            }
        }

        // Persist the propertiess
        updatedProperties = string(_properties.save());

        // Clean up
        _properties.clear();
    }
    
}