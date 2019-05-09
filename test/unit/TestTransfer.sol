pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "../../contracts/common/payment/Transfer.sol";

contract TestTransfer {
    using Transfer for Transfer.Transfers;

    Transfer.Transfers private _transfers;
    Transfer.Transfers private _transfers2;

    function testShouldSetAndGetTransfers() public {
        _transfers.clear();
        _transfers.addEtherTransfer(0x31b2D5618d36A85E4B5714fE4b4a1aE08d6ca27b, 100);
        _transfers.addEtherTransfer(0x655d3828c419606e673a33cDda87CA2848f031f0, 300);
        _transfers.addTokenTransfer(0x5b76c94Af501cDEB14338e245af26c7b551AcE29, 0x655d3828c419606e673a33cDda87CA2848f031f0, 500);
        _transfers.addTokenTransfer(0x31b2D5618d36A85E4B5714fE4b4a1aE08d6ca27b, 0x5b76c94Af501cDEB14338e245af26c7b551AcE29, 700);

        Assert.equal(_transfers.getEtherTransfer(0x31b2D5618d36A85E4B5714fE4b4a1aE08d6ca27b), 100, "Transfer amount should be the same");
        Assert.equal(_transfers.getEtherTransfer(0x655d3828c419606e673a33cDda87CA2848f031f0), 300, "Transfer amount should be the same");

        (address r1, uint a1) = _transfers.getTokenTransfer(0x5b76c94Af501cDEB14338e245af26c7b551AcE29);
        Assert.equal(r1, 0x655d3828c419606e673a33cDda87CA2848f031f0, "Transfer address should be the same");
        Assert.equal(a1, 500, "Transfer amount should be the same.");
        (address r2, uint a2) = _transfers.getTokenTransfer(0x31b2D5618d36A85E4B5714fE4b4a1aE08d6ca27b);
        Assert.equal(r2, 0x5b76c94Af501cDEB14338e245af26c7b551AcE29, "Transfer address should be the same");
        Assert.equal(a2, 700, "Transfer amount should be the same.");
    }

    function testShouldSaveAndLoadTransfers() public {
        _transfers.clear();
        _transfers2.clear();
        _transfers.addEtherTransfer(0x31b2D5618d36A85E4B5714fE4b4a1aE08d6ca27b, 100);
        _transfers.addEtherTransfer(0x655d3828c419606e673a33cDda87CA2848f031f0, 300);
        _transfers.addTokenTransfer(0x5b76c94Af501cDEB14338e245af26c7b551AcE29, 0x655d3828c419606e673a33cDda87CA2848f031f0, 500);
        _transfers.addTokenTransfer(0x31b2D5618d36A85E4B5714fE4b4a1aE08d6ca27b, 0x5b76c94Af501cDEB14338e245af26c7b551AcE29, 700);

        _transfers2.load(_transfers.save());
        Assert.equal(_transfers2.getEtherTransfer(0x31b2D5618d36A85E4B5714fE4b4a1aE08d6ca27b), 100, "Transfer amount should be the same");
        Assert.equal(_transfers2.getEtherTransfer(0x655d3828c419606e673a33cDda87CA2848f031f0), 300, "Transfer amount should be the same");

        (address r1, uint a1) = _transfers2.getTokenTransfer(0x5b76c94Af501cDEB14338e245af26c7b551AcE29);
        Assert.equal(r1, 0x655d3828c419606e673a33cDda87CA2848f031f0, "Transfer address should be the same");
        Assert.equal(a1, 500, "Transfer amount should be the same.");
        (address r2, uint a2) = _transfers2.getTokenTransfer(0x31b2D5618d36A85E4B5714fE4b4a1aE08d6ca27b);
        Assert.equal(r2, 0x5b76c94Af501cDEB14338e245af26c7b551AcE29, "Transfer address should be the same");
        Assert.equal(a2, 700, "Transfer amount should be the same.");
    }
}