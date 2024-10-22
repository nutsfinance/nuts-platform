const { BN, expectEvent, shouldFail, time, ether } = require('openzeppelin-test-helpers');
const { expect } = require('chai');
const NutsPlatform = artifacts.require("../../contracts/NutsPlatform.sol");
const NutsEscrow = artifacts.require("../../contracts/NutsEscrow.sol");
const NutsToken = artifacts.require("../../contracts/NutsToken.sol");
const Loan = artifacts.require("../../contracts/instrument/Loan.sol");
const ERC20Mintable = artifacts.require("../../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol");
const soltype = require(__dirname + "../../../solidity-js");
const ProtoBufUtils = require(__dirname + "/ProtoBufUtils.js");
const proto = soltype.importTypes(require(__dirname + '/../../messages-js/LoanInfo_pb.js'));
const BigNumber = require('bignumber.js');

const getEventTimestamp = async function(txHash, emitter, eventName) {
    const receipt = await web3.eth.getTransactionReceipt(txHash);
    const logs = emitter.decodeLogs(receipt.logs);
    // console.log(logs);
    const event = logs.find(e => e.event == "EventTimeScheduled" && e.args.eventName == eventName);
    // console.log(event);
    // console.log(event.args);
    // console.log(event.args.timestamp);
    return logs.find(e => e.event == "EventTimeScheduled" && e.args.eventName == eventName).args.timestamp.toNumber();
}

contract("NutsPlatform", ([owner, fsp, seller, buyer, tokenOwner]) => {
    before("deploy new NUTS platform and loan contracts", async function() {
        // Retrieve the deployed contracts
        this.nutsPlatform = await NutsPlatform.deployed();
        this.nutsToken = await NutsToken.deployed();
        this.nutsEscrow = await NutsEscrow.deployed();
        this.loan = await Loan.deployed();

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
        await this.nutsPlatform.createInstrument(this.loan.address, 0, {from: fsp});

        // Seller deposits Ether to Escrow
        await this.nutsEscrow.deposit({from: seller, value: ether("20")});
    }),
    beforeEach("deploy new collateral token", async function() {
        // Deploy new collateral token
        this.collateralToken = await ERC20Mintable.new({from : tokenOwner});

        // // Buyer deposits Collateral token to escrow
        await this.collateralToken.mint(buyer, 500000, {from: tokenOwner});
        await this.collateralToken.approve(this.nutsEscrow.address, 500000, {from: buyer});
        await this.nutsEscrow.depositToken(this.collateralToken.address, 400000, {from: buyer});
    }),
    context("Issuance creation", async function() {
        it("should be able to create issuance and deposit Ether", async function() {
            // Create issuance
            let buffer = ProtoBufUtils.getSellerParameters(proto, this.collateralToken.address, 300000,
            '5', 3, 5, 20, 30, 10000, 5);
            let tx = await this.nutsPlatform.createIssuance(this.loan.address, buffer, {from: seller});

            const issuanceId = tx.logs.find(e => e.event == "IssuanceCreated").args.issuanceId.toNumber();
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(issuanceId),
                state: new BN(1)
            });

            // Seller deposit Ether: borrow amount = 5 Ether
            tx = await this.nutsPlatform.deposit(issuanceId, ether('5'), {from: seller});

            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(issuanceId),
                state: new BN(2)
            });

            expect(await this.nutsEscrow.balanceOfIssuance(issuanceId)).be.bignumber.equal(ether('5'));
        }),
        it("should fail to create issuance with invalid parameters", async function() {
            console.log("Send a zero collateral token address");
            // Send a zero collateral token address
            let buffer = ProtoBufUtils.getSellerParameters(proto, 0, 300000, '5', 3, 20, 5, 30, 10000, 5);
            await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
                buffer), "Collateral token address must not be 0");

            console.log("Send a zero collateral amount");
            buffer = ProtoBufUtils.getSellerParameters(proto, this.loan.address, 0, '5', 3, 20, 5, 30, 10000, 5);
            // Send a zero collateral amount
            await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
                buffer), "Collateral amount must be greater than 0");

            console.log("Send a zero borrow amount");
            buffer = ProtoBufUtils.getSellerParameters(proto, this.collateralToken.address, 300000, '0', 3, 20, 5, 30, 10000, 5);

            // Send a zero borrow amount
            await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
                buffer), "Borrow amount must be greater than 0");

            console.log("Send a zero deposit due days");
            buffer = ProtoBufUtils.getSellerParameters(proto, this.collateralToken.address, 300000, '5', 0, 20, 5, 30, 10000, 5);
            // Send a zero deposit due days
            await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
                buffer), "Deposit due days must be greater than 0");

            console.log("Send a zero collateral due days");
            buffer = ProtoBufUtils.getSellerParameters(proto, this.collateralToken.address, 300000, '5', 3, 0, 5, 30, 10000, 5);
            // Send a zero collateral due days
            await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
                buffer), "Collateral due days must be greater than 0");

            console.log("Send a zero engagement due days");
            buffer = ProtoBufUtils.getSellerParameters(proto, this.collateralToken.address, 300000, '5', 3, 20, 0, 30, 10000, 5);
            // Send a zero engagement due days
            await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
                buffer), "Engagement due days must be greater than 0");

            console.log("Send a zero tenor days");
            buffer = ProtoBufUtils.getSellerParameters(proto, this.collateralToken.address, 300000, '5', 3, 20, 5, 0, 10000, 5);
            // Send a zero tenor days
            await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
                buffer), "Tenor days must be greater than 0");

            console.log("Send a tenor days smaller than or equal to collateral days");
            buffer = ProtoBufUtils.getSellerParameters(proto, this.collateralToken.address, 300000, '5', 3, 20, 5, 1, 10000, 5);
            // Send a tenor days smaller than or equal to collateral days
            await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
                buffer), "Tenor days must be greater than collateral due days");

            console.log("Send a zero grace period");
            buffer = ProtoBufUtils.getSellerParameters(proto, this.collateralToken.address, 300000, '5', 3, 20, 5, 30, 10000, 0);
            // Send a zero grace period
            await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
                buffer), "Grace period must be greater than 0");

        }),
        it("should become unfunded if deposit is overdue", async function() {
            // Create issuance
            let buffer = ProtoBufUtils.getSellerParameters(proto, this.collateralToken.address, 300000,
            '5', 3, 5, 20, 30, 10000, 5);
            let tx = await this.nutsPlatform.createIssuance(this.loan.address, buffer, {from: seller});
            const issuanceId = tx.logs.find(e => e.event == "IssuanceCreated").args.issuanceId.toNumber();
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(issuanceId),
                state: new BN(1)
            });
            const timestamp = await getEventTimestamp(tx.receipt.transactionHash, Loan, "deposit_expired");
            // console.log(timestamp);
            // console.log((await time.latest()).toNumber());

            await shouldFail.reverting.withMessage(this.nutsPlatform.processScheduledEvent(issuanceId, timestamp, "deposit_expired", [])
                , "The scheduled event is not due now.");

            // Move the timestamp
            await time.increase(5 * 24 * 3600 + 100);
            // Scheduled event: deposit_expired
            tx = await this.nutsPlatform.processScheduledEvent(issuanceId, timestamp, "deposit_expired", []);
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(issuanceId),
                state: new BN(4)
            });
        }),
        it("should become unfunded and return deposit if deposit is overdue", async function() {
            // Create issuance
            let buffer = ProtoBufUtils.getSellerParameters(proto, this.collateralToken.address, 300000,
            '5', 3, 5, 20, 30, 10000, 5);
            let tx = await this.nutsPlatform.createIssuance(this.loan.address, buffer, {from: seller});
            const issuanceId = tx.logs.find(e => e.event == "IssuanceCreated").args.issuanceId.toNumber();
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(issuanceId),
                state: new BN(1)
            });
            const timestamp = await getEventTimestamp(tx.receipt.transactionHash, Loan, "deposit_expired");
            // console.log(timestamp);
            // console.log((await time.latest()).toNumber());

            // Seller deposit insufficient Ether: borrow amount = 5
            const prevBalance = new BN(await this.nutsEscrow.balanceOf({from: seller}));
            tx = await this.nutsPlatform.deposit(issuanceId, ether('2'), {from: seller});
            const currentBalance = new BN(await this.nutsEscrow.balanceOf({from: seller}));
            await shouldFail.reverting.withMessage(this.nutsPlatform.processScheduledEvent(issuanceId, timestamp, "deposit_expired", [])
                , "The scheduled event is not due now.");
            // console.log(prevBalance);
            // console.log(currentBalance);
            expect(prevBalance.sub(currentBalance)).be.bignumber.equal(ether('2'));

            // Move the timestamp
            await time.increase(5 * 24 * 3600 + 100);
            // Scheduled event: deposit_expired
            tx = await this.nutsPlatform.processScheduledEvent(issuanceId, timestamp, "deposit_expired", []);
            const nextBalance = new BN(await this.nutsEscrow.balanceOf({from: seller}));
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(issuanceId),
                state: new BN(4)
            });
            // console.log(nextBalance);
            expect(prevBalance).be.bignumber.equal(nextBalance);
            expect(nextBalance.sub(currentBalance)).be.bignumber.equal(ether('2'));
        }),
        it("should fail to deposit more Ether than borrow amount", async function() {
            // Create issuance
            let buffer = ProtoBufUtils.getSellerParameters(proto, this.collateralToken.address, 300000,
            '5', 3, 5, 20, 30, 10000, 5);
            let tx = await this.nutsPlatform.createIssuance(this.loan.address, buffer, {from: seller});
            const issuanceId = tx.logs.find(e => e.event == "IssuanceCreated").args.issuanceId.toNumber();
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(issuanceId),
                state: new BN(1)
            });

            await shouldFail.reverting.withMessage(this.nutsPlatform.deposit(issuanceId, ether('8'), {from: seller})
                , "The Ether deposit cannot exceed the borrow amount.");
            await this.nutsPlatform.deposit(issuanceId, ether('3'), {from: seller});
            await shouldFail.reverting.withMessage(this.nutsPlatform.deposit(issuanceId, ether('3'), {from: seller})
                , "The Ether deposit cannot exceed the borrow amount.");
            tx = await this.nutsPlatform.deposit(issuanceId, ether('2'), {from: seller});
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(issuanceId),
                state: new BN(2)
            });
        }),
        it("should fail to accept Ether deposit other than seller", async function() {
            // Create issuance
            let buffer = ProtoBufUtils.getSellerParameters(proto, this.collateralToken.address, 300000,
            '5', 3, 5, 20, 30, 10000, 5);
            let tx = await this.nutsPlatform.createIssuance(this.loan.address, buffer, {from: seller});
            const issuanceId = tx.logs.find(e => e.event == "IssuanceCreated").args.issuanceId.toNumber();
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(issuanceId),
                state: new BN(1)
            });
            await this.nutsEscrow.deposit({from: owner, value: ether("20")});
            await shouldFail.reverting.withMessage(this.nutsPlatform.deposit(issuanceId, ether('2'), {from: owner})
                , "Unknown transferer. Only seller or buyer can send Ether to issuance.");
            await shouldFail.reverting.withMessage(this.nutsPlatform.deposit(issuanceId, ether('5'), {from: owner})
                , "Unknown transferer. Only seller or buyer can send Ether to issuance.");
            await this.nutsEscrow.deposit({from: fsp, value: ether("20")});
            await shouldFail.reverting.withMessage(this.nutsPlatform.deposit(issuanceId, ether('2'), {from: fsp})
                , "Unknown transferer. Only seller or buyer can send Ether to issuance.");
            await shouldFail.reverting.withMessage(this.nutsPlatform.deposit(issuanceId, ether('5'), {from: fsp})
                , "Unknown transferer. Only seller or buyer can send Ether to issuance.");
        }),
        it("should fail to deposit any token", async function() {
            // Create issuance
            let buffer = ProtoBufUtils.getSellerParameters(proto, this.collateralToken.address, 300000,
            '5', 3, 5, 20, 30, 10000, 5);
            let tx = await this.nutsPlatform.createIssuance(this.loan.address, buffer, {from: seller});
            const issuanceId = tx.logs.find(e => e.event == "IssuanceCreated").args.issuanceId.toNumber();
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(issuanceId),
                state: new BN(1)
            });

            await this.collateralToken.mint(seller, 500000, {from: tokenOwner});
            await this.collateralToken.approve(this.nutsEscrow.address, 500000, {from: seller});
            await this.nutsEscrow.depositToken(this.collateralToken.address, 500000, {from: seller});
            await shouldFail.reverting.withMessage(this.nutsPlatform.depositToken(issuanceId, this.collateralToken.address, 200000, {from: seller})
                , "Collateral deposit must occur in Active state.");
            await this.collateralToken.mint(fsp, 500000, {from: tokenOwner});
            await this.collateralToken.approve(this.nutsEscrow.address, 500000, {from: fsp});
            await this.nutsEscrow.depositToken(this.collateralToken.address, 500000, {from: fsp});
            await shouldFail.reverting.withMessage(this.nutsPlatform.depositToken(issuanceId, this.collateralToken.address, 200000, {from: fsp})
                , "Collateral deposit must occur in Active state.");

            // Seller deposit Ether: borrow amount = 5 Ether
            tx = await this.nutsPlatform.deposit(issuanceId, ether('5'), {from: seller});
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(issuanceId),
                state: new BN(2)
            });

            await shouldFail.reverting.withMessage(this.nutsPlatform.depositToken(issuanceId, this.collateralToken.address, 200000, {from: seller})
                , "Collateral deposit must occur in Active state.");
            await shouldFail.reverting.withMessage(this.nutsPlatform.depositToken(issuanceId, this.collateralToken.address, 200000, {from: fsp})
                , "Collateral deposit must occur in Active state.");
        })
    })
});
