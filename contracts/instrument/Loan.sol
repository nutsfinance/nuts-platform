pragma solidity ^0.5.0;

import "../Instrument.sol";

/**
 * The loan contract is a contract that buyer borrows in Ethers by
 * depositing token as collaterals.
 */
contract Loan is Instrument {
    string constant DEPOSIT_EXPIRED_EVENT = "deposit_expired";
    string constant ENGAGEMENT_EXPIRED_EVENT = "engagement_expired";
    string constant COLLATERAL_EXPIRED_EVENT = "collateral_expired";
    string constant LOAN_EXPIRED_EVENT = "loan_expired";

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
        uint engagementDueDays = _parameters.getUintValue("engagement-due-days");
        uint collateralDueDays = _parameters.getUintValue("collateral-due-days");
        uint tenorDays = _parameters.getUintValue("tenor-days");

        // Validate parameters
        require(collateralTokenAddress != address(0x0), "Collateral token address must not be 0");
        require(collateralAmount > 0, "Collateral amount must be greater than 0");
        require(borrowAmount > 0, "Borrow amount must be greater than 0");
        require(depositDueDays > 0, "Deposit due days must be greater than 0");
        require(engagementDueDays > 0, "Engagement due days must be greater than 0");
        require(collateralDueDays > 0, "Collateral due days must be greater than 0");
        require(tenorDays > 0, "Tenor days must be greater than 0");
        require(tenorDays > collateralDueDays, "Tenor days must be greater than collateral due days");

        // Set propertiess
        _properties.clear();
        _properties.setAddressValue("seller_address", sellerAddress);
        _properties.setUintValue("start_date", now);
        _properties.setAddressValue("collateral_token_address", collateralTokenAddress);
        _properties.setUintValue("collateral_amount", collateralAmount);
        _properties.setUintValue("borrow_amount", borrowAmount);
        _properties.setUintValue("engagement_due_days", engagementDueDays);
        _properties.setUintValue("collateral_due_days", collateralDueDays);
        _properties.setUintValue("tenor_days", tenorDays);

        // Set expiration for deposit
        emit EventScheduled(issuanceId, now + depositDueDays * 1 days, DEPOSIT_EXPIRED_EVENT, "");

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
        emit EventScheduled(issuanceId, now + collateralDueDays * 1 days, COLLATERAL_EXPIRED_EVENT, "");

        // Set expiration for loan
        uint loanDueDays = _properties.getUintValue("tenor_days");
        emit EventScheduled(issuanceId, now + loanDueDays * 1 days, LOAN_EXPIRED_EVENT, "");

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

        // Deposit check
        // 1. The issuance is in initiated state
        // 2. The Ether transfer is from seller
        // 3. The ether balance is larger then or equal to the borrow amount
        if ( isIssuanceInState(INITIATED_STATE)
            && _properties.getAddressValue("seller_address") == fromAddress
            && _balances.getEtherBalance() >= _properties.getUintValue("borrow_amount")) {
            
            // Change to Engagable state
            updateIssuanceState(issuanceId, ENGAGABLE_STATE);

            // Schedule engagement expiration
            uint engagementDueDays = _properties.getUintValue("engagement_due_days");
            emit EventScheduled(issuanceId, now + engagementDueDays * 1 days, ENGAGEMENT_EXPIRED_EVENT, "");
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

        // Collateral check
        // 1. The issuance is in active state
        // 2. The token is from the buyer
        // 3. The token is the collateral token
        // 4. The balance collateral balance is equals to or larger than the collateral amount
        // 5. The issuance is still collecting collateral(collateral_complete = false)
        if ( isIssuanceInState(ACTIVE_STATE)
            && _properties.getAddressOrDefault("buyer_address", address(0x0)) == fromAddress
            && _properties.getAddressValue("collateral_token_address") == tokenAddress
            && _balances.getTokenBalance(tokenAddress) >= _properties.getUintValue("collateral_amount")
            && !_properties.getBoolOrDefault("collateral_complete", false)) {

            // Mark the collateral collection as complete
            _properties.setBoolValue("collateral_complete", true);

            // Transfer Ether to buyer
            // TODO If the deposit is larger than the borrow amount, should we return them now?
            _transfers.clear();
            _transfers.addEtherTransfer(_properties.getAddressValue("buyer_address"),
                    _properties.getUintValue("borrow_amount"));
            transfers = string(_transfers.save());
            _transfers.clear();
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
        if (StringUtil.equals(eventName, DEPOSIT_EXPIRED_EVENT)) {
            // Check whether the issuance is still in Initiated state
            if (isIssuanceInState(INITIATED_STATE)) {
                // Change to Unfunded state
                updateIssuanceState(issuanceId, UNFUNDED_STATE);
            }
        } else if (StringUtil.equals(eventName, ENGAGEMENT_EXPIRED_EVENT)) {
            // Check whether the issuance is still in Engagable state
            if (isIssuanceInState(ENGAGABLE_STATE)) {
                // Change to Unfunded state
                updateIssuanceState(issuanceId, COMPLETE_NOT_ENGAGED_STATE);
            }
        } else if (StringUtil.equals(eventName, COLLATERAL_EXPIRED_EVENT)) {
            // Check whether the issuance is still in Active state
            // and the collateral is not complete
            if (isIssuanceInState(ACTIVE_STATE)
                && !_properties.getBoolOrDefault("collateral_complete", false)) {
                
                // Change to Delinquent state
                updateIssuanceState(issuanceId, DELINQUENT_STATE);
            }
        } else if (StringUtil.equals(eventName, LOAN_EXPIRED_EVENT)) {
            // Check whether the issuance is still active
            // If the issuance is Complete Engaged or Delinquent, no action
            if (isIssuanceInState(ACTIVE_STATE)) {

                // Check repay
                // 1. The Ether balance is equal to or bigger than the borrow amount
                // 2. The colleteral collection is complete
                if ( _balances.getEtherBalance() >= _properties.getUintValue("borrow_amount")
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
                } else {
                    // Change to Delinquent state
                    updateIssuanceState(issuanceId, DELINQUENT_STATE);
                }
            }
        }

        // Persist the propertiess
        updatedProperties = string(_properties.save());

        // Clean up
        _properties.clear();
    }
    
}