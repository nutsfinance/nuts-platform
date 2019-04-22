pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "../contracts/common/payment/Balance.sol";

contract TestBalance {
    using Balance for Balance.Balances;

    Balance.Balances private _balances;
    Balance.Balances private _balances2;

    function testShouldSetAndGetBalance() public {
        _balances.clear();
        _balances.setEtherBalance(100);
        _balances.setTokenBalance(0x31b2D5618d36A85E4B5714fE4b4a1aE08d6ca27b, 200);
        _balances.setTokenBalance(0x5b76c94Af501cDEB14338e245af26c7b551AcE29, 300);
        _balances.setTokenBalance(0x655d3828c419606e673a33cDda87CA2848f031f0, 400);
        Assert.equal(_balances.getEtherBalance(), 100, "Should have the same Ether balance");
        Assert.equal(_balances.getTokenBalance(0x31b2D5618d36A85E4B5714fE4b4a1aE08d6ca27b), 200, "Should have the same token balance");
        Assert.equal(_balances.getTokenBalance(0x5b76c94Af501cDEB14338e245af26c7b551AcE29), 300, "Should have the same token balance");
        Assert.equal(_balances.getTokenBalance(0x655d3828c419606e673a33cDda87CA2848f031f0), 400, "Should have the same token balance");
    }

    function testShouldSaveAndLoadBalance() public {
        _balances.clear();
        _balances2.clear();
        _balances.setEtherBalance(100);
        _balances.setTokenBalance(0x31b2D5618d36A85E4B5714fE4b4a1aE08d6ca27b, 200);
        _balances.setTokenBalance(0x5b76c94Af501cDEB14338e245af26c7b551AcE29, 300);
        _balances.setTokenBalance(0x655d3828c419606e673a33cDda87CA2848f031f0, 400);

        _balances2.load(_balances.save());
        Assert.equal(_balances2.getEtherBalance(), 100, "Should have the same Ether balance");
        Assert.equal(_balances2.getTokenBalance(0x31b2D5618d36A85E4B5714fE4b4a1aE08d6ca27b), 200, "Should have the same token balance");
        Assert.equal(_balances2.getTokenBalance(0x5b76c94Af501cDEB14338e245af26c7b551AcE29), 300, "Should have the same token balance");
        Assert.equal(_balances2.getTokenBalance(0x655d3828c419606e673a33cDda87CA2848f031f0), 400, "Should have the same token balance");
    }
}