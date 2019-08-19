const { BN, expectEvent, shouldFail, time, send, ether } = require('openzeppelin-test-helpers');
const { expect } = require('chai');
const NutsPlatform = artifacts.require("../../contracts/NutsPlatform.sol");
const NutsEscrow = artifacts.require("../../contracts/NutsEscrow.sol");
const NutsToken = artifacts.require("../../contracts/NutsToken.sol");
const Loan = artifacts.require("../../contracts/instrument/Loan.sol");
const ERC20Mintable = artifacts.require("../../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol");
const soltype = require(__dirname + "../../../solidity-js");
const proto = soltype.importTypes(require(__dirname + '/../../messages-js/LoanInfo_pb.js'));
const BigNumber = require('bignumber.js');
const ProtoBufUtils = require(__dirname + "/ProtoBufUtils.js");

const getEventTimestamp = async function(txHash, emitter, eventName) {
    const receipt = await web3.eth.getTransactionReceipt(txHash);
    const logs = emitter.decodeLogs(receipt.logs);
    const event = logs.find(e => e.event == "EventTimeScheduled" && e.args.eventName == eventName);
    return logs.find(e => e.event == "EventTimeScheduled" && e.args.eventName == eventName).args.timestamp.toNumber();
}

contract("NutsPlatform", ([owner, fsp, seller, buyer, buyer2, tokenOwner]) => {
    before("deploy new NUTS platform and loan contracts", async function() {
        // Retrieve the deployed contracts
        this.nutsPlatform = await NutsPlatform.deployed();
        this.nutsToken = await NutsToken.deployed();
        this.nutsEscrow = await NutsEscrow.deployed();
        this.loan = await Loan.deployed();
        console.log("Nuts Platform address: " + this.nutsPlatform.address);
        console.log("Loan contract address: " + this.loan.address);

        // Grant Nuts token to fsp and seller
        await this.nutsToken.setMinterCap(fsp, 100000);
        await this.nutsToken.setMinterCap(seller, 100000);
        await this.nutsToken.setMinterCap(owner, 100000);
        await this.nutsToken.setMinterCap(buyer, 100000);
        await this.nutsToken.setMinterCap(tokenOwner, 100000);
        await this.nutsToken.mint(fsp, 400);
        await this.nutsToken.mint(seller, 400);
        await this.nutsToken.approve(this.nutsPlatform.address, 400, {from: fsp});
        await this.nutsToken.approve(this.nutsPlatform.address, 400, {from: seller});
        await this.nutsPlatform.addFsp(fsp, {from: owner});

        // Create instrument
        let tx = await this.nutsPlatform.createInstrument(this.loan.address, 0, {from: fsp});
        console.log("Create instrument: Gas used = " + tx.receipt.gasUsed);

        // Seller deposits Ether to Escrow
        tx = await this.nutsEscrow.deposit({from: seller, value: ether("200")});
        console.log("Deposit Ether to Escrow: Gas used = " + tx.receipt.gasUsed);
        await this.nutsEscrow.deposit({from: buyer, value: ether("200")});
        await this.nutsEscrow.deposit({from: buyer2, value: ether("200")});
    }),
    beforeEach("deploy new collateral token", async function() {
        // Deploy new collateral token
        this.collateralToken = await ERC20Mintable.new({from : tokenOwner});

        // // Buyer deposits Collateral token to escrow
        await this.collateralToken.mint(buyer, 500000, {from: tokenOwner});
        await this.collateralToken.approve(this.nutsEscrow.address, 500000, {from: buyer});
        let tx = await this.nutsEscrow.depositToken(this.collateralToken.address, 400000, {from: buyer});
        console.log("Deposit token to Escrow: Gas used = " + tx.receipt.gasUsed);
        await this.collateralToken.mint(seller, 500000, {from: tokenOwner});
        await this.collateralToken.approve(this.nutsEscrow.address, 500000, {from: seller});
        await this.nutsEscrow.depositToken(this.collateralToken.address, 400000, {from: seller});

        // Seller create new issuance
        let buffer = ProtoBufUtils.getSellerParameters(proto, this.collateralToken.address, 300000,
        '5', 3, 5, 20, 30, 10000, 5);
        tx = await this.nutsPlatform.createIssuance(this.loan.address, buffer, {from: seller});
        console.log("Create issuance: Gas used = " + tx.receipt.gasUsed);
        this.issuanceId = tx.logs.find(e => e.event == "IssuanceCreated").args.issuanceId.toNumber();
        await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
            issuanceId: new BN(this.issuanceId),
            state: new BN(1)
        });

        // Seller deposit Ether: borrow amount = 5 Ethers
        tx = await this.nutsPlatform.deposit(this.issuanceId, ether('5'), {from: seller});
        console.log("Deposit Ether to issuance: Gas used = " + tx.receipt.gasUsed);
        this.engagementExpiredTimestamp = await getEventTimestamp(tx.receipt.transactionHash, Loan, "engagement_expired");
        await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
            issuanceId: new BN(this.issuanceId),
            state: new BN(2)
        });
        expect(await this.nutsEscrow.balanceOfIssuance(this.issuanceId)).be.bignumber.equal(ether('5'));

        // Buyer engages the issuance
        tx = await this.nutsPlatform.engageIssuance(this.issuanceId, [], {from: buyer});
        this.loanExpiredTimestamp = await getEventTimestamp(tx.receipt.transactionHash, Loan, "loan_expired");
        this.gracePeriodExpiredTimestamp = await getEventTimestamp(tx.receipt.transactionHash, Loan, "grace_period_expired");
        console.log("Engage issuance: Gas used = " + tx.receipt.gasUsed);
        await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
            issuanceId: new BN(this.issuanceId),
            state: new BN(3)
        });

        // Buyer deposits collateral
        // Buyer deposit the collateral
        tx = await this.nutsPlatform.depositToken(this.issuanceId, this.collateralToken.address, 300000, {from: buyer});
        console.log("Deposit token to issuance: Gas used = " + tx.receipt.gasUsed);
    }),
    context("Issuance Repay", async function() {
        it("should repay and complete the issuance before loan due", async function() {
            const prevIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const prevIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const prevSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const prevSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const prevBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const prevBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});
            expect(prevIssuanceEther).be.bignumber.equal('0');
            expect(prevIssuanceToken).be.bignumber.equal('300000');

            // Tenor days = 30, grace period = 5
            await time.increase(20 * 24 * 3600);
            // Pay in full in 20 days
            await this.nutsPlatform.deposit(this.issuanceId, ether('5'), {from: buyer});
            await time.increase(10 * 24 * 3600 + 100);
            // Scheduled event: loan_expired
            tx = await this.nutsPlatform.processScheduledEvent(this.issuanceId, this.loanExpiredTimestamp, "loan_expired", []);
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(this.issuanceId),
                state: new BN(6)
            });

            const curIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const curIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const curSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const curSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const curBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const curBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});

            // The issuance balance should be zero
            expect(curIssuanceEther).be.bignumber.equal('0');
            expect(curIssuanceToken).be.bignumber.equal('0');
            // The Ether is returned to seller
            expect(curSellerEther.sub(prevSellerEther)).be.bignumber.equal(ether('5'));
            expect(prevBuyerEther.sub(curBuyerEther)).be.bignumber.equal(ether('5'));
            // Interest
            expect(curSellerToken.sub(prevSellerToken)).be.bignumber.equal('600');;
            expect(curBuyerToken.sub(prevBuyerToken)).be.bignumber.equal('299400');
        }),
        it("should repay and complete the issuance in grace period", async function() {
            const prevIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const prevIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const prevSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const prevSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const prevBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const prevBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});
            expect(prevIssuanceEther).be.bignumber.equal('0');
            expect(prevIssuanceToken).be.bignumber.equal('300000');

            // Tenor days = 30, grace period = 5
            await time.increase(30 * 24 * 3600);
            // Scheduled event: loan_expired
            tx = await this.nutsPlatform.processScheduledEvent(this.issuanceId, this.loanExpiredTimestamp, "loan_expired", []);
            // Pay in full in 32 days
            await time.increase(2 * 24 * 3600);
            await this.nutsPlatform.deposit(this.issuanceId, ether('5'), {from: buyer});
            await time.increase(3 * 24 * 3600 + 100);
            // Scheduled event: grace_period_expired
            tx = await this.nutsPlatform.processScheduledEvent(this.issuanceId, this.gracePeriodExpiredTimestamp, "grace_period_expired", []);
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(this.issuanceId),
                state: new BN(6)
            });

            const curIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const curIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const curSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const curSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const curBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const curBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});

            // The issuance balance should be zero
            expect(curIssuanceEther).be.bignumber.equal('0');
            expect(curIssuanceToken).be.bignumber.equal('0');
            // The Ether is returned to seller
            expect(curSellerEther.sub(prevSellerEther)).be.bignumber.equal(ether('5'));
            expect(prevBuyerEther.sub(curBuyerEther)).be.bignumber.equal(ether('5'));
            // Interest
            expect(curSellerToken.sub(prevSellerToken)).be.bignumber.equal('960');;
            expect(curBuyerToken.sub(prevBuyerToken)).be.bignumber.equal('299040');
        }),
        it("should repay multiple times and complete the issuance in grace period", async function() {
            const prevIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const prevIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const prevSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const prevSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const prevBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const prevBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});
            expect(prevIssuanceEther).be.bignumber.equal('0');
            expect(prevIssuanceToken).be.bignumber.equal('300000');

            // Tenor days = 30, grace period = 5
            await time.increase(5 * 24 * 3600);
            await this.nutsPlatform.deposit(this.issuanceId, ether('2'), {from: buyer});
            await time.increase(15 * 24 * 3600);
            await this.nutsPlatform.deposit(this.issuanceId, ether('1'), {from: buyer});
            await time.increase(10 * 24 * 3600);
            // Scheduled event: loan_expired
            tx = await this.nutsPlatform.processScheduledEvent(this.issuanceId, this.loanExpiredTimestamp, "loan_expired", []);
            // Pay in full in 32 days
            await time.increase(2 * 24 * 3600);
            await this.nutsPlatform.deposit(this.issuanceId, ether('2'), {from: buyer});
            await time.increase(3 * 24 * 3600 + 100);
            // Scheduled event: grace_period_expired
            tx = await this.nutsPlatform.processScheduledEvent(this.issuanceId, this.gracePeriodExpiredTimestamp, "grace_period_expired", []);
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(this.issuanceId),
                state: new BN(6)
            });

            const curIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const curIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const curSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const curSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const curBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const curBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});

            // The issuance balance should be zero
            expect(curIssuanceEther).be.bignumber.equal('0');
            expect(curIssuanceToken).be.bignumber.equal('0');
            // The Ether is returned to seller
            expect(curSellerEther.sub(prevSellerEther)).be.bignumber.equal(ether('5'));
            expect(prevBuyerEther.sub(curBuyerEther)).be.bignumber.equal(ether('5'));
            // Interest
            expect(curSellerToken.sub(prevSellerToken)).be.bignumber.equal('564');;
            expect(curBuyerToken.sub(prevBuyerToken)).be.bignumber.equal('299436');
        }),
        it("should default if no payment is made", async function() {
            const prevIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const prevIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const prevSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const prevSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const prevBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const prevBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});
            expect(prevIssuanceEther).be.bignumber.equal('0');
            expect(prevIssuanceToken).be.bignumber.equal('300000');

            // Tenor days = 30, grace period = 5
            await time.increase(30 * 24 * 3600);
            // Scheduled event: loan_expired
            tx = await this.nutsPlatform.processScheduledEvent(this.issuanceId, this.loanExpiredTimestamp, "loan_expired", []);
            await time.increase(5 * 24 * 3600);
            // Scheduled event: grace_period_expired
            tx = await this.nutsPlatform.processScheduledEvent(this.issuanceId, this.gracePeriodExpiredTimestamp, "grace_period_expired", []);
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(this.issuanceId),
                state: new BN(7)
            });

            const curIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const curIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const curSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const curSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const curBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const curBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});

            // The issuance balance should be zero
            expect(curIssuanceEther).be.bignumber.equal('0');
            expect(curIssuanceToken).be.bignumber.equal('0');
            // No Ether is returned to seller
            expect(curSellerEther.sub(prevSellerEther)).be.bignumber.equal(ether('0'));
            expect(prevBuyerEther.sub(curBuyerEther)).be.bignumber.equal(ether('0'));
            // Interest
            expect(curSellerToken.sub(prevSellerToken)).be.bignumber.equal('1050');;
            expect(curBuyerToken.sub(prevBuyerToken)).be.bignumber.equal('298950');
        }),
        it("should default if not enough payment is made", async function() {
            const prevIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const prevIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const prevSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const prevSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const prevBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const prevBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});
            expect(prevIssuanceEther).be.bignumber.equal('0');
            expect(prevIssuanceToken).be.bignumber.equal('300000');

            // Tenor days = 30, grace period = 5
            await time.increase(30 * 24 * 3600);
            // Scheduled event: loan_expired
            tx = await this.nutsPlatform.processScheduledEvent(this.issuanceId, this.loanExpiredTimestamp, "loan_expired", []);
            // Pay in full in 32 days
            await time.increase(2 * 24 * 3600);
            await this.nutsPlatform.deposit(this.issuanceId, ether('4'), {from: buyer});
            await time.increase(3 * 24 * 3600 + 100);
            // Scheduled event: grace_period_expired
            tx = await this.nutsPlatform.processScheduledEvent(this.issuanceId, this.gracePeriodExpiredTimestamp, "grace_period_expired", []);
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(this.issuanceId),
                state: new BN(7)
            });

            const curIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const curIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const curSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const curSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const curBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const curBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});

            // The issuance balance should be zero
            expect(curIssuanceEther).be.bignumber.equal('0');
            expect(curIssuanceToken).be.bignumber.equal('0');
            // The Ether is returned to seller
            expect(curSellerEther.sub(prevSellerEther)).be.bignumber.equal(ether('4'));
            expect(prevBuyerEther.sub(curBuyerEther)).be.bignumber.equal(ether('4'));
            // Interest
            expect(curSellerToken.sub(prevSellerToken)).be.bignumber.equal('1050');;
            expect(curBuyerToken.sub(prevBuyerToken)).be.bignumber.equal('298950');
        }),
        it("should fail to deposit more Ether than borrow amount", async function() {
            // Tenor days = 30, grace period = 5
            await time.increase(10 * 24 * 3600);
            await this.nutsPlatform.deposit(this.issuanceId, ether('4'), {from: buyer});
            await time.increase(12 * 24 * 3600);
            await shouldFail.reverting.withMessage(
                this.nutsPlatform.deposit(this.issuanceId, ether('8'), {from: buyer}),
                "The Ether repay cannot exceed the borrow amount.");
        }),
        it("should fail to receive any token", async function() {
            await shouldFail.reverting.withMessage(
                this.nutsPlatform.depositToken(this.issuanceId, this.collateralToken.address, 100000, {from: seller}),
                "Collateral deposit must come from the buyer."
            );
            await shouldFail.reverting.withMessage(
                this.nutsPlatform.depositToken(this.issuanceId, this.collateralToken.address, 100000, {from: buyer}),
                "Collateral deposit must occur during the collateral depoit phase."
            );
        }),
        it("should fail to accept Ether except buyer", async function() {
            await shouldFail.reverting.withMessage(
                this.nutsPlatform.deposit(this.issuanceId, ether('8'), {from: seller}),
                "Ether deposit must happen in Initiated state.");
            await shouldFail.reverting.withMessage(
                this.nutsPlatform.deposit(this.issuanceId, ether('8'), {from: buyer2}),
                "Unknown transferer. Only seller or buyer can send Ether to issuance.");
        })
    })
});
