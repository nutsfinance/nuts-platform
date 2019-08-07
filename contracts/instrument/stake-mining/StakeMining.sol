pragma solidity ^0.5.0;

import "../../lib/math/SafeMath.sol";
import "../../lib/util/StringUtil.sol";
import "../../Instrument.sol";
import "./StakeMiningInfo.sol";

/**
 * @title A stake mining financial instrument.
 */
contract StakeMining is Instrument {
    using SafeMath for uint256;

    uint constant PERCENTAGE_DECIMALS = 4;

    /**
     * @dev Create a new stake mininig issuance
     * @param issuanceId The id of the issuance
     * @param sellerAddress The address of the seller who creates this issuance
     * @param sellerParameters The custom parameters to the newly created issuance
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function createIssuance(uint256 issuanceId, address sellerAddress, string memory sellerParameters)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory /** transfers */) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(sellerAddress != address(0x0), "Seller address must be set.");

        // Parse parameters
        StakeMiningParameters.Data memory parameters = StakeMiningParameters.decode(bytes(sellerParameters));

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
        emit EventScheduled(issuanceId, now + parameters.depositDueDays * 1 days, DEPOSIT_EXPIRED_EVENT, "");

        // Change to Initiated state
        updatedState = IssuanceStates.Initiated;

        // Persist the propertiess
        updatedProperties = string(loanProperties.encode());
    }

    /**
     * @dev A buyer engages to the issuance
     * @param issuanceId The id of the issuance
     * @param properties The current properties of the issuance
     * @param buyerAddress The address of the buyer who engages in the issuance
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function engage(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory /** balances */, address buyerAddress, string memory /**buyerParameters */)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory /** transfers */) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(properties).length > 0, "Properties must be set.");
        require(buyerAddress != address(0x0), "Buyer address must be set.");
        require(state == IssuanceStates.Engageable, "Issuance must be in the Engagable state");

        // Load properties
        LoanProperties.Data memory loanProperties = LoanProperties.decode(bytes(properties));
        loanProperties.buyerAddress = buyerAddress;
        loanProperties.engageDate = now;

        // Set expiration for collateral
        emit EventScheduled(issuanceId, now + loanProperties.collateralDueDays * 1 days, COLLATERAL_EXPIRED_EVENT, "");

        // Set expiration for loan
        emit EventScheduled(issuanceId, now + loanProperties.tenorDays * 1 days, LOAN_EXPIRED_EVENT, "");

        // Set expiration for grace period
        emit EventScheduled(issuanceId, now + (loanProperties.tenorDays + loanProperties.gracePeriod) * 1 days, GRACE_PERIOD_EXPIRED_EVENT, "");

        // Change to Active state
        updatedState = IssuanceStates.Active;

        // Persist the propertiess
        updatedProperties = string(loanProperties.encode());
    }

    /**
     * @dev Buyer/Seller has made an Ether transfer to the issuance
     * @param issuanceId The id of the issuance
     * @param properties The current properties of the issuance
     * @param balances The current balance of the issuance
     * @param fromAddress The address of the Ether sender
     * @param amount The amount of Ether transfered
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processDeposit(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, address fromAddress, uint256 amount)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory /** transfers */) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(properties).length > 0, "Properties must be set.");
        require(fromAddress != address(0x0), "Transferer address must be set.");
        require(amount > 0, "Transfer amount must be greater than 0.");

        // Load properties
        LoanProperties.Data memory loanProperties = LoanProperties.decode(bytes(properties));

        // Load balance
        Balances.Data memory loanBalances = Balances.decode(bytes(balances));

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

                // Schedule engagement expiration
                emit EventScheduled(issuanceId, now + loanProperties.engagementDueDays * 1 days, ENGAGEMENT_EXPIRED_EVENT, "");
            }

        } else if (loanProperties.buyerAddress == fromAddress) {
            // This Ether transfer is from buyer
            // This must be repay
            // Repay check:
            // 1. Issuance must in Active state
            // 2. Collateral deposit must be done
            // 3. The Ether balance must not exceed the borrow amount
            require(state == IssuanceStates.Active, "Ether repay must happen in Active state.");
            require(!loanProperties.collateralComplete, "Ether repay must happen after collateral is deposited.");
            require(etherBalance <= loanProperties.borrowAmount, "The Ether repay cannot exceed the borrow amount.");

            // Calculate interest
            loanProperties.interest = loanProperties.interest.add(interestByAmountAndDays(amount, loanProperties.interestRate,
                daysBetween(loanProperties.engageDate, now)));

        } else {
            revert("Unknown transferer. Only seller or buyer can send Ether to issuance.");
        }

        // Persist the propertiess
        updatedProperties = string(loanProperties.encode());
    }

    /**
     * @dev Buyer/Seller has made an ERC20 token transfer to the issuance
     * @param issuanceId The id of the issuance
     * @param properties The current properties of the issuance
     * @param balances The current balance of the issuance
     * @param fromAddress The address of the ERC20 token sender
     * @param tokenAddress The address of the ERC20 token
     * @param amount The amount of ERC20 token transfered
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processTokenDeposit(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, address fromAddress, address tokenAddress, uint256 amount)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(properties).length > 0, "Properties must be set.");
        require(fromAddress != address(0x0), "Transferer address must be set.");
        require(tokenAddress != address(0x0), "Transferred token address must be set.");
        require(amount > 0, "Transfer amount must be greater than 0.");

        // Load properties
        LoanProperties.Data memory loanProperties = LoanProperties.decode(bytes(properties));

        // Load balance
        Balances.Data memory loanBalances = Balances.decode(bytes(balances));

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
            transfers = string(tokenTransfers.encode());
        }

        // Persist the propertiess
        updatedProperties = string(loanProperties.encode());
    }

    /**
     * @dev Process scheduled event
     * @param issuanceId The id of the issuance
     * @param properties The current properties of the issuance
     * @param balances The current balance of the issuance
     * @param eventName Name of the custom event, eventName of EventScheduled event
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processScheduledEvent(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, string memory eventName, string memory /** eventPayload */)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(properties).length > 0, "Properties must be set.");
        require(bytes(eventName).length > 0, "Event name must be set.");

        // Load properties
        LoanProperties.Data memory loanProperties = LoanProperties.decode(bytes(properties));

        // Load balance
        Balances.Data memory loanBalances = Balances.decode(bytes(balances));

        updatedState = state;       // In case there is no state change.
        // Check for deposit_expired event
        if (StringUtil.equals(eventName, DEPOSIT_EXPIRED_EVENT)) {
            // Check whether the issuance is still in Initiated state
            if (state == IssuanceStates.Initiated) {
                // Change to Unfunded state
                updatedState = IssuanceStates.Unfunded;
                // If there is any deposit, return to the seller
                Transfers.Data memory tokenTransfers = release(loanProperties, loanBalances);
                transfers = string(tokenTransfers.encode());
            }
        } else if (StringUtil.equals(eventName, ENGAGEMENT_EXPIRED_EVENT)) {
            // Check whether the issuance is still in Engagable state
            if (state == IssuanceStates.Engageable) {
                // Change to Complete Not Engaged state
                updatedState = IssuanceStates.CompleteNotEngaged;
                // Return the Ether depost to seller
                Transfers.Data memory tokenTransfers = release(loanProperties, loanBalances);
                transfers = string(tokenTransfers.encode());
            }
        } else if (StringUtil.equals(eventName, COLLATERAL_EXPIRED_EVENT)) {
            // Check whether the issuance is still in Active state
            // and the collateral is not complete
            if (state == IssuanceStates.Active
                    && !loanProperties.collateralComplete) {
                // Change to Delinquent state
                updatedState = IssuanceStates.Delinquent;
                // Return Ethers to seller and collateral to buyer
                Transfers.Data memory tokenTransfers = release(loanProperties, loanBalances);
                transfers = string(tokenTransfers.encode());
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
                // Also add transfers
                Transfers.Data memory tokenTransfers = release(loanProperties, loanBalances);
                transfers = string(tokenTransfers.encode());
            }
        } else if (StringUtil.equals(eventName, GRACE_PERIOD_EXPIRED_EVENT)) {
            // If the issuance is already Delinquent or COMPLETE_ENGAGED_STATE, no action
            if (state == IssuanceStates.Active) {
                // Default check
                // 1. The Ether balance is smaller than the borrow amount
                if (getEtherBalance(loanBalances) < loanProperties.borrowAmount) {
                    // Change to Delinquent state
                    updatedState = IssuanceStates.Delinquent;
                    Transfers.Data memory tokenTransfers = defaultRelease(loanProperties, loanBalances);
                    transfers = string(tokenTransfers.encode());
                } else {
                    // Change to Complete Engaged state
                    updatedState = IssuanceStates.CompleteEngaged;
                    // Also add transfers
                    Transfers.Data memory tokenTransfers = release(loanProperties, loanBalances);
                    transfers = string(tokenTransfers.encode());
                }
            }
        } else {
            revert("Unknown event");
        }

        // Persist the propertiess
        updatedProperties = string(loanProperties.encode());
    }

    /**
     * User-driven ETH withdraw is not supported in loan contract.
     */
    function processWithdraw(uint256 /** issuanceId */, IssuanceStates /** state */, string memory /** properties */,
        string memory /** balances */, address /** fromAddress */, uint256 /** amount */)
        public returns (IssuanceStates /** updatedState */, string memory /** updatedProperties */, string memory /** transfers */) {
        revert("User ETH withdraw unsupported");
    }

    /**
     * User-driven ERC20 token withdraw is not supported in loan contract.
     */
    function processTokenWithdraw(uint256 /** issuanceId */, IssuanceStates /** state */, string memory /** properties */,
        string memory /** balances */, address /** fromAddress */, address /** tokenAddress */, uint256 /** amount */)
        public returns (IssuanceStates /** updatedState */, string memory /** updatedProperties */, string memory /** transfers */) {
        revert("User ERC20 token withdraw unsupported");
    }

    /**
     * @dev Custom event is not supported in loan contract.
     */
    function processCustomEvent(uint256 /** issuanceId */, IssuanceStates /** state */, string memory /** properties */,
        string memory /** balances */, string memory /** eventName */, string memory /** eventPayload */)
        public returns (IssuanceStates /** updatedState */, string memory /** updatedProperties */, string memory /** transfers */) {
        revert("Custom evnet unsupported.");
    }
}
