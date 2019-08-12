pragma solidity ^0.5.0;

import "../../lib/math/SafeMath.sol";
import "../../lib/util/StringUtil.sol";
import "../../Instrument.sol";
import "./LoanInfo.sol";
import "../../TokenBalance.sol";
import "../../TokenTransfer.sol";
import "../../UnifiedStorage.sol";

/**
 * The loan contract is a contract that buyer borrows in Ethers by
 * depositing token as collaterals.
 */
contract Loan is Instrument {
    using SafeMath for uint256;
    using SellerParameters for SellerParameters.Data;
    using LoanProperties for LoanProperties.Data;
    using Balances for Balances.Data;
    using Transfers for Transfers.Data;

    // Scheduled event list
    string constant DEPOSIT_EXPIRED_EVENT = "deposit_expired";
    string constant ENGAGEMENT_EXPIRED_EVENT = "engagement_expired";
    string constant COLLATERAL_EXPIRED_EVENT = "collateral_expired";
    string constant LOAN_EXPIRED_EVENT = "loan_expired";
    string constant GRACE_PERIOD_EXPIRED_EVENT = "grace_period_expired";

    uint constant INTEREST_RATE_DECIMALS = 8;
    string constant PROPERTIES_KEY = "properties";

    /**
     * @dev Create a new issuance of the financial instrument
     * @param issuanceId The id of the issuance
     * @param unifiedStorage The storage contract created for this issuance
     * @param sellerAddress The address of the seller who creates this issuance
     * @param sellerParameters The custom parameters to the newly created issuance
     * @return transfers The transfers to perform after the invocation
     */
    function createIssuance(uint256 issuanceId, UnifiedStorage unifiedStorage, address sellerAddress, bytes memory sellerParameters)
        public returns (IssuanceStates updatedState, bytes memory /** transfers */) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(sellerAddress != address(0x0), "Seller address must be set.");

        // Parse parameters
        SellerParameters.Data memory parameters = SellerParameters.decode(sellerParameters);

        // Validate parameters
        require(parameters.collateralTokenAddress != address(0x0), "Collateral token address must not be 0");
        require(parameters.collateralTokenAmount > 0, "Collateral amount must be greater than 0");
        require(parameters.borrowAmount > 0, "Borrow amount must be greater than 0");
        require(parameters.depositDueDays > 0, "Deposit due days must be greater than 0");
        require(parameters.collateralDueDays > 0, "Collateral due days must be greater than 0");
        require(parameters.engagementDueDays > 0, "Engagement due days must be greater than 0");
        // TODO Min and max for tenor days?
        require(parameters.tenorDays > 0, "Tenor days must be greater than 0");
        require(parameters.tenorDays > parameters.collateralDueDays, "Tenor days must be greater than collateral due days");
        // TODO Interest rate range?
        // Grace period is set to > 0 so that loan_expired always happens before grace_period_expired
        require(parameters.gracePeriod > 0, "Grace period must be greater than 0");

        // Set propertiess
        LoanProperties.Data memory loanProperties = LoanProperties.Data({
          sellerAddress: sellerAddress,
          startDate: now,
          collateralTokenAddress: parameters.collateralTokenAddress,
          collateralTokenAmount: parameters.collateralTokenAmount,
          borrowAmount: parameters.borrowAmount,
          collateralDueDays: parameters.collateralDueDays,
          engagementDueDays: parameters.engagementDueDays,
          tenorDays: parameters.tenorDays,
          interestRate: parameters.interestRate,
          gracePeriod: parameters.gracePeriod,
          collateralComplete: false,
          interest: 0,
          buyerAddress: address(0x0),
          engageDate: 0
        });

        // Set expiration for deposit
        emit EventTimeScheduled(issuanceId, now + parameters.depositDueDays * 1 days, DEPOSIT_EXPIRED_EVENT, "");

        // Change to Initiated state
        updatedState = IssuanceStates.Initiated;
        emit IssuanceStateUpdated(issuanceId, IssuanceStates.Initiated);
        // Persist the propertiess
        unifiedStorage.setBytes(PROPERTIES_KEY, LoanProperties.encode(loanProperties));
    }

    /**
     * @dev A buyer engages to the issuance
     * @param issuanceId The id of the issuance
     * @param unifiedStorage The storage contract created for this issuance
     * @param buyerAddress The address of the buyer who engages in the issuance
     * @return transfers The transfers to perform after the invocation
     */
    function engage(uint256 issuanceId, IssuanceStates state, UnifiedStorage unifiedStorage,
        bytes memory /** balances */, address buyerAddress, bytes memory /**buyerParameters */)
        public returns (IssuanceStates updatedState, bytes memory /** transfers */) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(buyerAddress != address(0x0), "Buyer address must be set.");
        require(state == IssuanceStates.Engageable, "Issuance must be in the Engagable state");
        bytes memory properties = unifiedStorage.getBytes(PROPERTIES_KEY);
        require(bytes(properties).length > 0, "Properties must be set.");

        // Load properties
        LoanProperties.Data memory loanProperties = LoanProperties.decode(properties);
        loanProperties.buyerAddress = buyerAddress;
        loanProperties.engageDate = now;

        // Set expiration for collateral
        emit EventTimeScheduled(issuanceId,
            now + loanProperties.collateralDueDays * 1 days, COLLATERAL_EXPIRED_EVENT, "");

        // Set expiration for loan
        emit EventTimeScheduled(issuanceId,
            now + loanProperties.tenorDays * 1 days, LOAN_EXPIRED_EVENT, "");

        // Set expiration for grace period
        emit EventTimeScheduled(issuanceId,
            now + (loanProperties.tenorDays + loanProperties.gracePeriod) * 1 days, GRACE_PERIOD_EXPIRED_EVENT, "");

        // Change to Active state
        updatedState = IssuanceStates.Active;
        emit IssuanceStateUpdated(issuanceId, IssuanceStates.Active);
        // Persist the propertiess
        unifiedStorage.setBytes(PROPERTIES_KEY, LoanProperties.encode(loanProperties));
    }

    /**
     * @dev Buyer/Seller has made an Ether transfer to the issuance
     * @param issuanceId The id of the issuance
     * @param unifiedStorage The storage contract created for this issuance
     * @param balances The current balance of the issuance
     * @param fromAddress The address of the Ether sender
     * @param amount The amount of Ether transfered
     * @return transfers The transfers to perform after the invocation
     */
    function processDeposit(uint256 issuanceId, IssuanceStates state, UnifiedStorage unifiedStorage,
        bytes memory balances, address fromAddress, uint256 amount)
        public returns (IssuanceStates updatedState, bytes memory /** transfers */) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(fromAddress != address(0x0), "Transferer address must be set.");
        require(amount > 0, "Transfer amount must be greater than 0.");
        bytes memory properties = unifiedStorage.getBytes(PROPERTIES_KEY);
        require(bytes(properties).length > 0, "Properties must be set.");

        // Load properties
        LoanProperties.Data memory loanProperties = LoanProperties.decode(properties);

        // Load balance
        Balances.Data memory loanBalances = Balances.decode(balances);

        uint etherBalance = getEtherBalance(loanBalances);
        updatedState = state;       // In case there is no state change.
        if (loanProperties.sellerAddress == fromAddress) {
            // The Ether transfer is from seller
            // This must be deposit
            // Deposit check:
            // 1. Issuance must in Initiated state
            // 2. The Ether balance must not exceed the borrow amount
            require(state == IssuanceStates.Initiated, "Ether deposit must happen in Initiated state.");
            require(etherBalance <= loanProperties.borrowAmount, "The Ether deposit cannot exceed the borrow amount.");

            // If the Ether balance is equal to the borrow amount, the issuance
            // becomes Engagable
            if (etherBalance == loanProperties.borrowAmount) {

                // Change to Engagable state
                updatedState = IssuanceStates.Engageable;
                emit IssuanceStateUpdated(issuanceId, IssuanceStates.Engageable);
                // Schedule engagement expiration
                emit EventTimeScheduled(issuanceId, now + loanProperties.engagementDueDays * 1 days, ENGAGEMENT_EXPIRED_EVENT, "");
            }

        } else if (loanProperties.buyerAddress == fromAddress) {
            // This Ether transfer is from buyer
            // This must be repay
            // Repay check:
            // 1. Issuance must in Active state
            // 2. Collateral deposit must be done
            // 3. The Ether balance must not exceed the borrow amount
            require(state == IssuanceStates.Active, "Ether repay must happen in Active state.");
            require(loanProperties.collateralComplete, "Ether repay must happen after collateral is deposited.");
            require(etherBalance <= loanProperties.borrowAmount, "The Ether repay cannot exceed the borrow amount.");

            // Calculate interest
            loanProperties.interest = loanProperties.interest.add(interestByAmountAndDays(amount, loanProperties.interestRate,
                daysBetween(loanProperties.engageDate, now)));

            // Persist the properties
            unifiedStorage.setBytes(PROPERTIES_KEY, LoanProperties.encode(loanProperties));

        } else {
            revert("Unknown transferer. Only seller or buyer can send Ether to issuance.");
        }
    }

    /**
     * @dev Buyer/Seller has made an ERC20 token transfer to the issuance
     * @param issuanceId The id of the issuance
     * @param unifiedStorage The storage contract created for this issuance
     * @param balances The current balance of the issuance
     * @param fromAddress The address of the ERC20 token sender
     * @param tokenAddress The address of the ERC20 token
     * @param amount The amount of ERC20 token transfered
     * @return transfers The transfers to perform after the invocation
     */
    function processTokenDeposit(uint256 issuanceId, IssuanceStates state, UnifiedStorage unifiedStorage,
        bytes memory balances, address fromAddress, address tokenAddress, uint256 amount)
        public returns (IssuanceStates updatedState, bytes memory transfers) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(fromAddress != address(0x0), "Transferer address must be set.");
        require(tokenAddress != address(0x0), "Transferred token address must be set.");
        require(amount > 0, "Transfer amount must be greater than 0.");
        bytes memory properties = unifiedStorage.getBytes(PROPERTIES_KEY);
        require(bytes(properties).length > 0, "Properties must be set.");

        // Load properties
        LoanProperties.Data memory loanProperties = LoanProperties.decode(properties);

        // Load balance
        Balances.Data memory loanBalances = Balances.decode(balances);

        // Note: Token transfer only occurs in colleteral deposit!
        // Collateral check
        // 1. The issuance is in active state
        // 2. The token is from the buyer
        // 3. The token is the collateral token
        // 4. The balance collateral balance is equals to the collateral amount
        // 5. The issuance is still collecting collateral(collateral_complete = false)
        require(state == IssuanceStates.Active, "Collateral deposit must occur in Active state.");
        require(loanProperties.buyerAddress == fromAddress,
            "Collateral deposit must come from the buyer.");
        require(!loanProperties.collateralComplete,
            "Collateral deposit must occur during the collateral depoit phase.");
        uint tokenBalance = getTokenBalance(loanBalances, tokenAddress);
        require(tokenBalance <= loanProperties.collateralTokenAmount,
            "Collateral token balance must not exceed the collateral amount");

        updatedState = state;       // In case there is no state change.
        if (tokenBalance == loanProperties.collateralTokenAmount) {
            // Mark the collateral collection as complete
            loanProperties.collateralComplete = true;
            // Transfer Ether to buyer

            Transfers.Data memory tokenTransfers = Transfers.Data(new Transfer.Data[](1));
            tokenTransfers.actions[0] = Transfer.Data({
                isEther: true,
                tokenAddress: address(0x0),
                receiverAddress: loanProperties.buyerAddress,
                amount: loanProperties.borrowAmount
            });
            transfers = Transfers.encode(tokenTransfers);

            // Persist the properties
            unifiedStorage.setBytes(PROPERTIES_KEY, LoanProperties.encode(loanProperties));
        }
    }

    /**
     * @dev Process scheduled event
     * @param issuanceId The id of the issuance
     * @param unifiedStorage The storage contract created for this issuance
     * @param balances The current balance of the issuance
     * @param eventName Name of the custom event, eventName of EventScheduled event
     * @return transfers The transfers to perform after the invocation
     */
    function processScheduledEvent(uint256 issuanceId, IssuanceStates state, UnifiedStorage unifiedStorage,
        bytes memory balances, string memory eventName, bytes memory /** eventPayload */)
        public returns (IssuanceStates updatedState, bytes memory transfers) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(eventName).length > 0, "Event name must be set.");
        bytes memory properties = unifiedStorage.getBytes(PROPERTIES_KEY);
        require(properties.length > 0, "Properties must be set.");

        // Load properties
        LoanProperties.Data memory loanProperties = LoanProperties.decode(properties);

        // Load balance
        Balances.Data memory loanBalances = Balances.decode(balances);

        updatedState = state;       // In case there is no state change.
        // Check for deposit_expired event
        if (StringUtil.equals(eventName, DEPOSIT_EXPIRED_EVENT)) {
            // Check whether the issuance is still in Initiated state
            if (state == IssuanceStates.Initiated) {
                // Change to Unfunded state
                updatedState = IssuanceStates.Unfunded;
                emit IssuanceStateUpdated(issuanceId, IssuanceStates.Unfunded);
                // If there is any deposit, return to the seller
                Transfers.Data memory tokenTransfers = release(loanProperties, loanBalances);
                transfers = Transfers.encode(tokenTransfers);
            }
        } else if (StringUtil.equals(eventName, ENGAGEMENT_EXPIRED_EVENT)) {
            // Check whether the issuance is still in Engagable state
            if (state == IssuanceStates.Engageable) {
                // Change to Complete Not Engaged state
                updatedState = IssuanceStates.CompleteNotEngaged;
                emit IssuanceStateUpdated(issuanceId, IssuanceStates.CompleteNotEngaged);
                // Return the Ether depost to seller
                Transfers.Data memory tokenTransfers = release(loanProperties, loanBalances);
                transfers = Transfers.encode(tokenTransfers);
            }
        } else if (StringUtil.equals(eventName, COLLATERAL_EXPIRED_EVENT)) {
            // Check whether the issuance is still in Active state
            // and the collateral is not complete
            if (state == IssuanceStates.Active
                    && !loanProperties.collateralComplete) {
                // Change to Delinquent state
                updatedState = IssuanceStates.Delinquent;
                emit IssuanceStateUpdated(issuanceId, IssuanceStates.Delinquent);
                // Return Ethers to seller and collateral to buyer
                Transfers.Data memory tokenTransfers = release(loanProperties, loanBalances);
                transfers = Transfers.encode(tokenTransfers);
            }
        } else if (StringUtil.equals(eventName, LOAN_EXPIRED_EVENT)) {
            // If the issuance is already Delinquent(colleteral due), no action
            // Loan due check
            // 1. The issuance is in Active state
            // 2. The Ether balance is equal to the borrow amount
            if (state == IssuanceStates.Active
                && getEtherBalance(loanBalances) == loanProperties.borrowAmount) {
                // Change to Complete Engaged state
                updatedState = IssuanceStates.CompleteEngaged;
                emit IssuanceStateUpdated(issuanceId, IssuanceStates.CompleteEngaged);
                // Also add transfers
                Transfers.Data memory tokenTransfers = release(loanProperties, loanBalances);
                transfers = Transfers.encode(tokenTransfers);
            }
        } else if (StringUtil.equals(eventName, GRACE_PERIOD_EXPIRED_EVENT)) {
            // If the issuance is already Delinquent or COMPLETE_ENGAGED_STATE, no action
            if (state == IssuanceStates.Active) {
                // Default check
                // 1. The Ether balance is smaller than the borrow amount
                if (getEtherBalance(loanBalances) < loanProperties.borrowAmount) {
                    // Change to Delinquent state
                    updatedState = IssuanceStates.Delinquent;
                    emit IssuanceStateUpdated(issuanceId, IssuanceStates.Delinquent);
                    Transfers.Data memory tokenTransfers = defaultRelease(loanProperties, loanBalances);
                    transfers = Transfers.encode(tokenTransfers);
                } else {
                    // Change to Complete Engaged state
                    updatedState = IssuanceStates.CompleteEngaged;
                    emit IssuanceStateUpdated(issuanceId, IssuanceStates.CompleteEngaged);
                    // Also add transfers
                    Transfers.Data memory tokenTransfers = release(loanProperties, loanBalances);
                    transfers = Transfers.encode(tokenTransfers);
                }
            }
        } else {
            revert("Unknown event");
        }

        // There is no update in the loan properties
    }

    /**
     * User-driven ETH withdraw is not supported in loan contract.
     */
    function processWithdraw(uint256 /** issuanceId */, IssuanceStates /** state */, UnifiedStorage /** unifiedStorage */,
        bytes memory /** balances */, address /** toAddress */, uint256 /** amount */)
        public returns (IssuanceStates /** updatedState */, bytes memory /** transfers */) {
        revert("User ETH withdraw unsupported");
    }

    /**
     * User-driven ERC20 token withdraw is not supported in loan contract.
     */
    function processTokenWithdraw(uint256 /** issuanceId */, IssuanceStates /** state */, UnifiedStorage /** unifiedStorage */,
        bytes memory /** balances */, address /** toAddress */, address /** tokenAddress */, uint256 /** amount */)
        public returns (IssuanceStates /** updatedState */, bytes memory /** transfers */) {
        revert("User ERC20 token withdraw unsupported");
    }

    /**
     * @dev Custom event is not supported in loan contract.
     */
    function processCustomEvent(uint256 /** issuanceId */, IssuanceStates /** state */, UnifiedStorage /** unifiedStorage */,
        bytes memory /** balances */, string memory /** eventName */, bytes memory /** eventPayload */)
        public returns (IssuanceStates /** updatedState */, bytes memory /** transfers */) {
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
        return interestRate.mul(numDays).mul(amount).div(10 ** INTEREST_RATE_DECIMALS);
    }

    /**
     * @dev Return Ether and collateral token
     */
    function release(LoanProperties.Data memory loanProperties, Balances.Data memory loanBalances)
        private pure returns (Transfers.Data memory transfers) {

        // Use Ether balance instead of borrow amount, as the balance might be
        // smaller than the borrow amount(deposit_expired or engagement_expired)
        uint borrowAmount = getEtherBalance(loanBalances);
        // The only case borrow amount = 0 is, there is no deposit in deposit_expired
        // If the buyer fails to repay any Ether, it's handled by defaultRelease()
        if (borrowAmount == 0)  {
            return Transfers.Data(new Transfer.Data[](0));
        }

        // Use token balance instead of collateral amount, as the balance might be
        // smaller than the collateral amount(collateral_expired)
        uint collateralAmount = getTokenBalance(loanBalances, loanProperties.collateralTokenAddress);

        // TODO Is this calculation correct?
        // Interest in token = (Interest in Ether / Borrow amount in Ether) * Collateral amount in token
        // In case of deposit_expired or engagement_expired or collateral_expired, interest = 0
        // so there should be no error
        uint interestTokenAmount = loanProperties.interest * collateralAmount / borrowAmount;
        uint tokenToSellerAmount = interestTokenAmount > collateralAmount ? collateralAmount : interestTokenAmount;
        uint tokenToBuyerAmount = collateralAmount - tokenToSellerAmount;
        uint transferCount = 1;
        uint transferIndex = 0;
        if (tokenToSellerAmount > 0) {
            transferCount++;
        }
        if (tokenToBuyerAmount > 0) {
            transferCount++;
        }
        transfers = Transfers.Data(new Transfer.Data[](transferCount));
        // Transfer Ether back to seller
        // In all case, we want to send all Ether back to seller
        transfers.actions[transferIndex++] = Transfer.Data({
            isEther: true,
            tokenAddress: address(0x0),
            receiverAddress: loanProperties.sellerAddress,
            amount: borrowAmount
        });

        // Transfer collateral token to seller as interest if it's greater than 0(interest rate could be 0)
        if (tokenToSellerAmount > 0) {
            transfers.actions[transferIndex++] = Transfer.Data({
                isEther: false,
                tokenAddress: loanProperties.collateralTokenAddress,
                receiverAddress: loanProperties.sellerAddress,
                amount: tokenToSellerAmount
            });
        }

        // Transfer collateral token back to buyer if it's greater than 0
        if (tokenToBuyerAmount > 0) {
            transfers.actions[transferIndex++] = Transfer.Data({
                isEther: false,
                tokenAddress: loanProperties.collateralTokenAddress,
                receiverAddress: loanProperties.buyerAddress,
                amount: tokenToBuyerAmount
            });
        }
    }

    function defaultRelease(LoanProperties.Data memory loanProperties, Balances.Data memory loanBalances)
        private view returns (Transfers.Data memory transfers) {
        // Full interest on default
        uint interest = interestByAmountAndDays(loanProperties.borrowAmount, loanProperties.interestRate,
                daysBetween(loanProperties.engageDate, now));

        // Transfer whatever Ether the issuance has back to seller
        uint etherBalance = getEtherBalance(loanBalances);

        // TODO Is this calculation correct?
        // Interest in token = (Interest in Ether / Borrow amount in Ether) * Collateral amount in token
        uint interestTokenAmount = interest * loanProperties.collateralTokenAmount / loanProperties.borrowAmount;
        uint tokenToSellerAmount = interestTokenAmount > loanProperties.collateralTokenAmount ?
            loanProperties.collateralTokenAmount : interestTokenAmount;
        uint tokenToBuyerAmount = loanProperties.collateralTokenAmount - tokenToSellerAmount;

        uint transferCount = 0;
        uint transferIndex = 0;
        if (etherBalance > 0) {
            transferCount++;
        }
        if (tokenToSellerAmount > 0) {
            transferCount++;
        }
        if (tokenToBuyerAmount > 0) {
            transferCount++;
        }
        transfers = Transfers.Data(new Transfer.Data[](transferCount));
        if (etherBalance > 0) {
            transfers.actions[transferIndex++] = Transfer.Data({
                isEther: true,
                tokenAddress: address(0x0),
                receiverAddress: loanProperties.sellerAddress,
                amount: etherBalance
            });
        }

        // Transfer collateral token to seller as interest if it's greater than 0(interest rate could be 0)
        if (tokenToSellerAmount > 0) {
            transfers.actions[transferIndex++] = Transfer.Data({
                isEther: false,
                tokenAddress: loanProperties.collateralTokenAddress,
                receiverAddress: loanProperties.sellerAddress,
                amount: tokenToSellerAmount
            });
        }

        // Transfer collateral token back to buyer if it's greater than 0
        if (tokenToBuyerAmount > 0) {
            transfers.actions[transferIndex++] = Transfer.Data({
                isEther: false,
                tokenAddress: loanProperties.collateralTokenAddress,
                receiverAddress: loanProperties.buyerAddress,
                amount: tokenToBuyerAmount
            });
        }
    }

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
