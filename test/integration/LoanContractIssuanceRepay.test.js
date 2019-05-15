const { BN, expectEvent, shouldFail, time, send, ether } = require('openzeppelin-test-helpers');
const { expect } = require('chai');
const NutsPlatform = artifacts.require("../../contracts/NutsPlatform.sol");
const NutsEscrow = artifacts.require("../../contracts/NutsEscrow.sol");
const NutsToken = artifacts.require("../../contracts/NutsToken.sol");
const Loan = artifacts.require("../../contracts/instrument/Loan.sol");
const ERC20Mintable = artifacts.require("../../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol");

const getEventTimestamp = async function(txHash, emitter, eventName) {
    const receipt = await web3.eth.getTransactionReceipt(txHash);
    const logs = emitter.decodeLogs(receipt.logs);
    const event = logs.find(e => e.event == "EventScheduled" && e.args.eventName == eventName);
    return logs.find(e => e.event == "EventScheduled" && e.args.eventName == eventName).args.timestamp.toNumber();
}

contract("NutsPlatform", ([owner, fsp, seller, buyer, buyer2, tokenOwner]) => {
    before("deploy new NUTS platform and loan contracts", async function() {
        // Retrieve the deployed contracts
        this.nutsPlatform = await NutsPlatform.deployed();
        this.nutsToken = await NutsToken.deployed();
        this.nutsEscrow = await NutsEscrow.deployed();
        this.loan = await Loan.deployed();

        // Grant Nuts token to fsp and seller
        await this.nutsToken.mint(fsp, 400);
        await this.nutsToken.mint(seller, 400);
        await this.nutsToken.approve(this.nutsPlatform.address, 400, {from: fsp});
        await this.nutsToken.approve(this.nutsPlatform.address, 400, {from: seller});
        await this.nutsPlatform.addFsp(fsp, {from: owner});

        // Create instrument 
        await this.nutsPlatform.createInstrument(this.loan.address, 0, {from: fsp});

        // Seller deposits Ether to Escrow
        await this.nutsEscrow.deposit({from: seller, value: ether("20")});
        await this.nutsEscrow.deposit({from: buyer, value: ether("20")});
        await this.nutsEscrow.deposit({from: buyer2, value: ether("20")});
    }),
    beforeEach("deploy new collateral token", async function() {
        // Deploy new collateral token
        this.collateralToken = await ERC20Mintable.new({from : tokenOwner});
        
        // // Buyer deposits Collateral token to escrow
        await this.collateralToken.mint(buyer, 50, {from: tokenOwner});
        await this.collateralToken.approve(this.nutsEscrow.address, 50, {from: buyer});
        await this.nutsEscrow.depositToken(this.collateralToken.address, 40, {from: buyer});
        await this.collateralToken.mint(seller, 50, {from: tokenOwner});
        await this.collateralToken.approve(this.nutsEscrow.address, 50, {from: seller});
        await this.nutsEscrow.depositToken(this.collateralToken.address, 40, {from: seller});

        // Seller create new issuance
        let tx = await this.nutsPlatform.createIssuance(this.loan.address,
            `collateral-token-address=${this.collateralToken.address}&collateral-amount=30&` + 
            `borrow-amount=5&deposit-due-days=3&engagement-due-days=20&collateral-due-days=5&` +
            `tenor-days=30&interest-rate=10000&grace-period=5`, {from: seller});
        this.issuanceId = tx.logs.find(e => e.event == "IssuanceCreated").args.issuanceId.toNumber();
        await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
            issuanceId: new BN(this.issuanceId),
            state: "Initiated"
        });

        // Seller deposit Ether: borrow amount = 5
        tx = await this.nutsPlatform.deposit(this.issuanceId, 5, {from: seller});
        this.engagementExpiredTimestamp = await getEventTimestamp(tx.receipt.transactionHash, Loan, "engagement_expired");
        await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
            issuanceId: new BN(this.issuanceId),
            state: "Engageable"
        });
        expect(await this.nutsEscrow.balanceOfIssuance(this.issuanceId)).be.bignumber.equal('5');
    }),
    context("Issuance Repay", async function() {
        it("should repay and complete the issuance", async function() {

        })
    })
});