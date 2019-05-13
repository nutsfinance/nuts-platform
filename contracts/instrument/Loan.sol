pragma solidity ^0.5.0;

import "../../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

import "../Instrument.sol";

/**
 * The loan contract is a contract that buyer borrows in Ethers by
 * depositing token as collaterals.
 */
contract Loan is Instrument {
    event SomthingHappen(uint num1, uint num2, string str1, string str2, address addr1, address addr2);
    using SafeMath for uint256;

    string constant DEPOSIT_EXPIRED_EVENT = "deposit_expired";
    string constant ENGAGEMENT_EXPIRED_EVENT = "engagement_expired";
    string constant COLLATERAL_EXPIRED_EVENT = "collateral_expired";
    string constant LOAN_EXPIRED_EVENT = "loan_expired";
    string constant GRACE_PERIOD_EXPIRED_EVENT = "grace_period_expired";

    uint constant RATE_DECIMALS = 8;

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
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(sellerAddress != address(0x0), "Seller address must be set.");

        // Parse parameters
        _parameters.clear();
        _parameters.parseParameters(sellerParameters);
        // TODO Give non-required parameter sensible default
        address collateralTokenAddress = _parameters.getAddressOrDefault("collateral-token-address", address(0x0));
        uint collateralAmount = _parameters.getUintOrDefault("collateral-amount", 0);
        uint borrowAmount = _parameters.getUintOrDefault("borrow-amount", 0);
        uint depositDueDays = _parameters.getUintOrDefault("deposit-due-days", 0);
        uint engagementDueDays = _parameters.getUintOrDefault("engagement-due-days", 0);
        uint collateralDueDays = _parameters.getUintOrDefault("collateral-due-days", 0);
        uint tenorDays = _parameters.getUintOrDefault("tenor-days", 0);
        uint interestRate = _parameters.getUintOrDefault("interest-rate", 0);
        uint gracePeriod = _parameters.getUintOrDefault("grace-period", 0);

        // Validate parameters
        require(collateralTokenAddress != address(0x0), "Collateral token address must not be 0");
        require(collateralAmount > 0, "Collateral amount must be greater than 0");
        require(borrowAmount > 0, "Borrow amount must be greater than 0");
        require(depositDueDays > 0, "Deposit due days must be greater than 0");
        require(engagementDueDays > 0, "Engagement due days must be greater than 0");
        require(collateralDueDays > 0, "Collateral due days must be greater than 0");
        // TODO Min and max for tenor days?
        require(tenorDays > 0, "Tenor days must be greater than 0");
        require(tenorDays > collateralDueDays, "Tenor days must be greater than collateral due days");
        // TODO Interest rate range?
        // Grace period is set to > 0 so that loan_expired always happens before grace_period_expired
        require(gracePeriod > 0, "Grace period must be greater than 0");

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
        _properties.setUintValue("interest_rate", interestRate);
        _properties.setUintValue("grace_period", gracePeriod);
        _properties.setUintValue("interest", 0);                // Initialize the interest to pay

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
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(properties).length > 0, "Properties must be set.");
        require(buyerAddress != address(0x0), "Buyer address must be set.");
    
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

        // Set expiration for grace period
        uint gracePeriod = _properties.getUintValue("grace_period");
        emit EventScheduled(issuanceId, now + (loanDueDays + gracePeriod) * 1 days, GRACE_PERIOD_EXPIRED_EVENT, "");

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
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(properties).length > 0, "Properties must be set.");
        require(fromAddress != address(0x0), "Transferer address must be set.");
        require(amount > 0, "Transfer amount must be greater than 0.");

        // Load properties
        _properties.clear();
        _properties.load(bytes(properties));

        // Load balance
        _balances.clear();
        _balances.load(bytes(balance));

        uint etherBalance = _balances.getEtherBalance();
        uint borrowAmount = _properties.getUintValue("borrow_amount");
        emit SomthingHappen(etherBalance, borrowAmount, balance, '', fromAddress, _properties.getAddressValue("seller_address"));
        if (_properties.getAddressValue("seller_address") == fromAddress) {
            // The Ether transfer is from seller
            // This must be deposit
            // Deposit check:
            // 1. Issuance must in Initiated state
            // 2. The Ether balance must not exceed the borrow amount
            require(isIssuanceInState(INITIATED_STATE), "Ether deposit must happen in Initiated state.");
            require(etherBalance <= borrowAmount, "The Ether deposit cannot exceed the borrow amount.");

            // If the Ether balance is equal to the borrow amount, the issuance
            // becomes Engagable
            if (etherBalance == borrowAmount) {
        
                // Change to Engagable state
                updateIssuanceState(issuanceId, ENGAGABLE_STATE);

                // Schedule engagement expiration
                uint engagementDueDays = _properties.getUintValue("engagement_due_days");
                emit EventScheduled(issuanceId, now + engagementDueDays * 1 days, ENGAGEMENT_EXPIRED_EVENT, "");
            }

        } else if (_properties.getAddressValue("buyer_address") == fromAddress) {
            // This Ether transfer is from buyer
            // This must be repay
            // Repay check:
            // 1. Issuance must in Active state
            // 2. Collateral deposit must be done
            // 3. The Ether balance must not exceed the borrow amount
            require(isIssuanceInState(ACTIVE_STATE), "Ether repay must happen in Active state.");
            require(_properties.getBoolOrDefault("collateral_complete", false), "Ether repay must happen after collateral is deposited.");
            require(etherBalance <= borrowAmount, "The Ether repay cannot exceed the borrow amount.");

            // Calculate interest
            uint interest = _properties.getUintValue("interest");
            interest.add(interestByAmountAndDays(amount, _properties.getUintValue("interest_rate"),
                daysBetween(_properties.getUintValue("engage_date"), now)));
            _properties.setUintValue("interest", interest);

        } else {
            revert("Unknown transferer. Only seller or buyer can send Ether to issuance.");
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
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(properties).length > 0, "Properties must be set.");
        require(fromAddress != address(0x0), "Transferer address must be set.");
        require(tokenAddress != address(0x0), "Transferred token address must be set.");
        require(amount > 0, "Transfer amount must be greater than 0.");

        // Note: Token transfer only occurs in colleteral deposit!
        // Collateral check
        // 1. The issuance is in active state
        // 2. The token is from the buyer
        // 3. The token is the collateral token
        // 4. The balance collateral balance is equals to the collateral amount
        // 5. The issuance is still collecting collateral(collateral_complete = false)
        require(isIssuanceInState(ACTIVE_STATE), "Collateral deposit must occur in Active state.");
        require(_properties.getAddressOrDefault("buyer_address", address(0x0)) == fromAddress,
            "Collateral deposit must come from the buyer.");
        require(!_properties.getBoolOrDefault("collateral_complete", false),
            "Collateral deposit must occur during the collateral depoit phase.");
        require(_balances.getTokenBalance(tokenAddress) >= _properties.getUintValue("collateral_amount"),
            "Collateral token balance must not exceed the collateral amount");

        // Load properties
        _properties.clear();
        _properties.load(bytes(properties));

        // Load balance
        _balances.clear();
        _balances.load(bytes(balance));

        // Mark the collateral collection as complete
        _properties.setBoolValue("collateral_complete", true);

        // Transfer Ether to buyer
        // TODO If the deposit is larger than the borrow amount, should we return them now?
        _transfers.clear();
        _transfers.addEtherTransfer(_properties.getAddressValue("buyer_address"),
                _properties.getUintValue("borrow_amount"));
        transfers = string(_transfers.save());
        _transfers.clear();

        // Persist the propertiess
        updatedProperties = string(_properties.save());

        // Clean up
        _properties.clear();
        _balances.clear();
    }

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
        string memory eventName, string memory eventPayload) public returns (string memory updatedProperties, string memory transfers) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(properties).length > 0, "Properties must be set.");
        require(bytes(eventName).length > 0, "Event name must be set.");

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
                _properties.setBoolValue("collateral_complete", false);
                // Change to Delinquent state
                updateIssuanceState(issuanceId, DELINQUENT_STATE);
            }
        } else if (StringUtil.equals(eventName, LOAN_EXPIRED_EVENT)) {
            // If the issuance is already Delinquent(colleteral due), no action
            // Loan due check
            // 1. The issuance is in Active state
            // 2. The Ether balance is equal to the borrow amount
            if (isIssuanceInState(ACTIVE_STATE)
                && _balances.getEtherBalance() == _properties.getUintValue("borrow_amount")) {
                // Change to Complete Engaged state
                updateIssuanceState(issuanceId, COMPLETE_ENGAGED_STATE);

                // Also add transfers
                _transfers.clear();
                release();
                transfers = string(_transfers.save());
                _transfers.clear();
            }
        } else if (StringUtil.equals(eventName, GRACE_PERIOD_EXPIRED_EVENT)) {
            // If the issuance is already Delinquent or COMPLETE_ENGAGED_STATE, no action
            if (isIssuanceInState(ACTIVE_STATE)) {
                _transfers.clear();

                // Default check
                // 1. The Ether balance is smaller than the borrow amount
                if (_balances.getEtherBalance() < _properties.getUintValue("borrow_amount")) {
                    // Change to Delinquent state
                    updateIssuanceState(issuanceId, DELINQUENT_STATE);
                    defaultRelease();
                } else {
                    // Change to Complete Engaged state
                    updateIssuanceState(issuanceId, COMPLETE_ENGAGED_STATE);
                    release();
                }

                transfers = string(_transfers.save());
                _transfers.clear();
            }
        } else {
            revert("Unknown event");
        }

        // Persist the propertiess
        updatedProperties = string(_properties.save());

        // Clean up
        _properties.clear();
    }

    /**
     * @dev Custom event is not supported in loan contract.
     */
    function processCustomEvent(uint256 issuanceId, string memory properties, string memory balance,
        string memory eventName, string memory eventPayload) public returns (string memory updatedProperties, string memory transfers) {
        revert("Custom evnet unsupported.");
    }

    /**
     * @dev Returns the number of days between start and end.
     * @param start Start time
     * @param end End time
     * @return The number of days between start and end
     */
    function daysBetween(uint start, uint end) private pure returns(uint){
        require(start <= end, "start must not be greater than end");
        return end.sub(start).div(1 days);
    }
    
    /**
     * @dev Calculate the interest
     * @param amount The amount to calculate interest
     * @param interestRate The interest rate
     * @param numDays The number of days to calculate interest
     * @return The calculted interest
     */
    function interestByAmountAndDays(uint256 amount, uint256 interestRate, uint256 numDays)
            private pure returns(uint256) {
        // consider the .div(10 ** rateDecimals) part in fixed point multiplying, we have better precision
        // with "amount * (rate * days)" than "amount * rate * days"
        return interestRate.mul(numDays).mul(amount).div(10 ** RATE_DECIMALS);
    }

    /**
     * @dev Return Ether and collateral token
     */
    function release() private {
        uint borrowAmount = _properties.getUintValue("borrow_amount");
        uint collateralAmount = _properties.getUintValue("collateral_amount");
        uint interest = _properties.getUintValue("interest");

        // Transfer Ether back to seller
        _transfers.addEtherTransfer(_properties.getAddressValue("seller_address"),
            borrowAmount);

        // TODO Is this calculation correct? 
        // Interest in token = (Interest in Ether / Borrow amount in Ether) * Collateral amount in token
        uint interestTokenAmount = interest * collateralAmount / borrowAmount;
        uint tokenToSellerAmount = interestTokenAmount > collateralAmount ? collateralAmount : interestTokenAmount;
        uint tokenToBuyerAmount = collateralAmount - tokenToSellerAmount;

        // Transfer collateral token to seller as interest if it's greater than 0(interest rate could be 0)
        if (tokenToSellerAmount > 0) {
            _transfers.addTokenTransfer(_properties.getAddressValue("collateral_token_address"),
            _properties.getAddressValue("seller_address"), 
            tokenToSellerAmount);
        }

        // Transfer collateral token back to buyer if it's greater than 0
        if (tokenToBuyerAmount > 0) {
            _transfers.addTokenTransfer(_properties.getAddressValue("collateral_token_address"),
            _properties.getAddressValue("buyer_address"), 
            tokenToBuyerAmount);
        }
    }

    function defaultRelease() private {
        uint borrowAmount = _properties.getUintValue("borrow_amount");
        uint collateralAmount = _properties.getUintValue("collateral_amount");
        // Full interest on default
        uint interest = interestByAmountAndDays(borrowAmount, _properties.getUintValue("interest_rate"),
                daysBetween(_properties.getUintValue("engage_date"), now));

        // Transfer whatever Ether the issuance has back to seller
        uint etherBalance = _balances.getEtherBalance();
        if (etherBalance > 0) {
            _transfers.addEtherTransfer(_properties.getAddressValue("seller_address"),
                etherBalance);
        }

        // TODO Is this calculation correct? 
        // Interest in token = (Interest in Ether / Borrow amount in Ether) * Collateral amount in token
        uint interestTokenAmount = interest * collateralAmount / borrowAmount;
        uint tokenToSellerAmount = interestTokenAmount > collateralAmount ? collateralAmount : interestTokenAmount;
        uint tokenToBuyerAmount = collateralAmount - tokenToSellerAmount;

        // Transfer collateral token to seller as interest if it's greater than 0(interest rate could be 0)
        if (tokenToSellerAmount > 0) {
            _transfers.addTokenTransfer(_properties.getAddressValue("collateral_token_address"),
            _properties.getAddressValue("seller_address"), 
            tokenToSellerAmount);
        }

        // Transfer collateral token back to buyer if it's greater than 0
        if (tokenToBuyerAmount > 0) {
            _transfers.addTokenTransfer(_properties.getAddressValue("collateral_token_address"),
            _properties.getAddressValue("buyer_address"), 
            tokenToBuyerAmount);
        }
    }
}