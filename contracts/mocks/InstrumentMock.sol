pragma solidity ^0.5.0;

import "../Instrument.sol";

contract InstrumentMock is Instrument {
    uint256 private var1;
    uint256 private var2;
    uint256 private var3;
    address private var4;
    address private var5;
    address private var6;
    string private var7;
    string private var8;
    string private var9;
    uint256 private var10;
    uint256 private var11;
    uint256 private var12;

    function createIssuance(uint256 issuanceId, address sellerAddress, string memory sellerParameters)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers) {
        var1 = issuanceId;
        var4 = sellerAddress;
        var7 = sellerParameters;
        updatedState = IssuanceStates.Active;
        updatedProperties = var7;
        transfers = var8;
    }

    function engage(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, address buyerAddress, string memory buyerParameters)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers) {
        var1 = issuanceId;
        var4 = buyerAddress;
        var7 = properties;
        var8 = balances;
        var9 = buyerParameters;
        updatedState = state;
        updatedProperties = var7;
        transfers = var8;
    }

    function processDeposit(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, address fromAddress, uint256 amount)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers) {
        var1 = issuanceId;
        var4 = fromAddress;
        var7 = properties;
        var8 = balances;
        var10 = amount;
        updatedState = state;
        updatedProperties = var7;
        transfers = var8;
    }

    function processTokenDeposit(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, address fromAddress, address tokenAddress, uint256 amount)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers) {
        var1 = issuanceId;
        var4 = fromAddress;
        var5 = tokenAddress;
        var7 = properties;
        var8 = balances;
        var10 = amount;
        updatedState = state;
        updatedProperties = var7;
        transfers = var8;
    }

    function processWithdraw(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, address fromAddress, uint256 amount)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers) {
        var1 = issuanceId;
        var4 = fromAddress;
        var7 = properties;
        var8 = balances;
        var10 = amount;
        updatedState = state;
        updatedProperties = var7;
        transfers = var8;
    }

    function processTokenWithdraw(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, address fromAddress, address tokenAddress, uint256 amount)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers) {
        var1 = issuanceId;
        var4 = fromAddress;
        var5 = tokenAddress;
        var7 = properties;
        var8 = balances;
        var10 = amount;
        updatedState = state;
        updatedProperties = var7;
        transfers = var8;
    }

    function processScheduledEvent(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, string memory eventName, string memory eventPayload)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers) {
        var1 = issuanceId;
        var7 = properties;
        var8 = balances;
        var9 = eventName;
        var9 = eventPayload;
        updatedState = state;
        updatedProperties = var7;
        transfers = var8;
    }

    function processCustomEvent(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, string memory eventName, string memory eventPayload)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers) {
        var1 = issuanceId;
        var7 = properties;
        var8 = balances;
        var9 = eventName;
        var9 = eventPayload;
        updatedState = state;
        updatedProperties = var7;
        transfers = var8;
    }

}