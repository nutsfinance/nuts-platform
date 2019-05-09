pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "../contracts/instrument/Loan.sol";
import "../contracts/common/property/Property.sol";
import "../contracts/common/payment/Balance.sol";
import "../contracts/common/payment/Transfer.sol";

contract TestLoan {
    using Property for Property.Properties;
    using Balance for Balance.Balances;
    using Transfer for Transfer.Transfers;

    Property.Properties private _properties;
    Balance.Balances private _balances;
    Transfer.Transfers private _transfers;

    /**
     * Test cases for Initiated state
     */
    function testShouldTransitionFromInitiatedToUnfunded() public {
        Loan loan = new Loan();
        _properties.clear();
        _properties.setStringValue("state", Loan.INITIATED_STATE);
        
    }
}
