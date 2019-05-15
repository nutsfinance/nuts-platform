const { BN, constants, expectEvent, shouldFail, time, send, ether } = require('openzeppelin-test-helpers');
const { ZERO_ADDRESS } = constants;
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
    context("Issuance engagement", async function() {
        it("should engage the issuance and deposit collateral", async function() {
            const prevIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const prevIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const prevSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const prevSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const prevBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const prevBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});
            
            // Engage the issuance
            let tx = await this.nutsPlatform.engageIssuance(this.issuanceId, "", {from: buyer});
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(this.issuanceId),
                state: "Active"
            });
            
            const curIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const curIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const curSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const curSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const curBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const curBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});
            // Expect no change in balance
            expect(curIssuanceEther).be.bignumber.equal(prevIssuanceEther);
            expect(curIssuanceToken).be.bignumber.equal(prevIssuanceToken);
            expect(curSellerEther).be.bignumber.equal(prevSellerEther);
            expect(curSellerToken).be.bignumber.equal(prevSellerToken);
            expect(curBuyerEther).be.bignumber.equal(prevBuyerEther);
            expect(curBuyerToken).be.bignumber.equal(prevBuyerToken);

            // Buyer deposit the collateral
            await this.nutsPlatform.depositToken(this.issuanceId, this.collateralToken.address, 30, {from: buyer});
            const nextIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const nextIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const nextSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const nextSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const nextBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const nextBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});

            // Expect 5 Ether(borrow amount) has transferred from issuance to buyer
            expect(curIssuanceEther.sub(nextIssuanceEther)).be.bignumber.equal('5');
            expect(nextBuyerEther.sub(curBuyerEther)).be.bignumber.equal('5');
            expect(nextSellerEther).be.bignumber.equal(curSellerEther);
            // Expect 30 token(collateral) has transferred from buyer to issuance
            expect(nextIssuanceToken.sub(curIssuanceToken)).be.bignumber.equal('30');
            expect(curBuyerToken.sub(nextBuyerToken)).be.bignumber.equal('30');
            expect(curSellerToken).be.bignumber.equal(nextSellerToken);
        }),
        it("should engage the issuance and deposit collateral in multiple rounds", async function() {
            const prevIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const prevIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const prevSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const prevSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const prevBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const prevBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});
            
            // Engage the issuance
            let tx = await this.nutsPlatform.engageIssuance(this.issuanceId, "", {from: buyer});
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(this.issuanceId),
                state: "Active"
            });
            
            const curIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const curIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const curSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const curSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const curBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const curBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});
            // Expect no change in balance
            expect(curIssuanceEther).be.bignumber.equal(prevIssuanceEther);
            expect(curIssuanceToken).be.bignumber.equal(prevIssuanceToken);
            expect(curSellerEther).be.bignumber.equal(prevSellerEther);
            expect(curSellerToken).be.bignumber.equal(prevSellerToken);
            expect(curBuyerEther).be.bignumber.equal(prevBuyerEther);
            expect(curBuyerToken).be.bignumber.equal(prevBuyerToken);

            // Buyer deposit the collateral
            await this.nutsPlatform.depositToken(this.issuanceId, this.collateralToken.address, 5, {from: buyer});
            await this.nutsPlatform.depositToken(this.issuanceId, this.collateralToken.address, 10, {from: buyer});
            await this.nutsPlatform.depositToken(this.issuanceId, this.collateralToken.address, 15, {from: buyer});
            const nextIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const nextIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const nextSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const nextSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const nextBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const nextBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});

            // Expect 5 Ether(borrow amount) has transferred from issuance to buyer
            expect(curIssuanceEther.sub(nextIssuanceEther)).be.bignumber.equal('5');
            expect(nextBuyerEther.sub(curBuyerEther)).be.bignumber.equal('5');
            expect(nextSellerEther).be.bignumber.equal(curSellerEther);
            // Expect 30 token(collateral) has transferred from buyer to issuance
            expect(nextIssuanceToken.sub(curIssuanceToken)).be.bignumber.equal('30');
            expect(curBuyerToken.sub(nextBuyerToken)).be.bignumber.equal('30');
            expect(curSellerToken).be.bignumber.equal(nextSellerToken);
        }),
        it("should fail to engage one issuance multiple times", async function() {
            // Engage the issuance
            let tx = await this.nutsPlatform.engageIssuance(this.issuanceId, "", {from: buyer});
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(this.issuanceId),
                state: "Active"
            });
            
            await shouldFail.reverting.withMessage(this.nutsPlatform.engageIssuance(this.issuanceId, "", {from: buyer2}), 
                "Issuance must be in the Engagable state");
        }),
        it("should go to Complete Not Engaged state if engagement is due", async function() {
            await shouldFail.reverting.withMessage(this.nutsPlatform.processScheduledEvent(this.issuanceId, this.engagementExpiredTimestamp, "engagement_expired", "")
                , "The scheduled event is not due now.");
            const prevIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const prevIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const prevSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const prevSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});    

            // Move the timestamp
            await time.increase(20 * 24 * 3600 + 100);
            // Scheduled event: engagement_expired
            let tx = await this.nutsPlatform.processScheduledEvent(this.issuanceId, this.engagementExpiredTimestamp, "engagement_expired", "");
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(this.issuanceId),
                state: "Complete Not Engaged"
            });

            const curIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const curIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const curSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const curSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});

            // The Ether deposit should have been returned to seller
            expect(prevIssuanceEther.sub(curIssuanceEther)).be.bignumber.equal('5');
            expect(curIssuanceToken).be.bignumber.equal(prevIssuanceToken);
            expect(curSellerEther.sub(prevSellerEther)).be.bignumber.equal('5');
            expect(curSellerToken).be.bignumber.equal(prevSellerToken);
        }),
        it("should go to Delinquent state if no collateral is deposit", async function() {
            // Engage the issuance
            let tx = await this.nutsPlatform.engageIssuance(this.issuanceId, "", {from: buyer});
            const timestamp = await getEventTimestamp(tx.receipt.transactionHash, Loan, "collateral_expired");
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(this.issuanceId),
                state: "Active"
            });
            
            await shouldFail.reverting.withMessage(this.nutsPlatform.processScheduledEvent(this.issuanceId, timestamp, "collateral_expired", "")
                , "The scheduled event is not due now.");
            const prevIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const prevIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const prevSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const prevSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const prevBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const prevBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});
    
            // Move the timestamp
            await time.increase(5 * 24 * 3600 + 100);
            // Scheduled event: engagement_expired
            tx = await this.nutsPlatform.processScheduledEvent(this.issuanceId, timestamp, "collateral_expired", "");
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(this.issuanceId),
                state: "Delinquent"
            });

            const curIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const curIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const curSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const curSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const curBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const curBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});
            // The Ether deposit should have been returned to seller
            expect(prevIssuanceEther.sub(curIssuanceEther)).be.bignumber.equal('5');
            expect(curIssuanceToken).be.bignumber.equal(prevIssuanceToken);
            expect(curSellerEther.sub(prevSellerEther)).be.bignumber.equal('5');
            expect(curSellerToken).be.bignumber.equal(prevSellerToken);
            expect(curBuyerEther).be.bignumber.equal(prevBuyerEther);
            expect(curBuyerToken).be.bignumber.equal(prevBuyerToken);
        }),
        it("should go to Delinquent state if not enough collateral is deposit", async function() {
            // Engage the issuance
            let tx = await this.nutsPlatform.engageIssuance(this.issuanceId, "", {from: buyer});
            const timestamp = await getEventTimestamp(tx.receipt.transactionHash, Loan, "collateral_expired");
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(this.issuanceId),
                state: "Active"
            });
            
            await shouldFail.reverting.withMessage(this.nutsPlatform.processScheduledEvent(this.issuanceId, timestamp, "collateral_expired", "")
                , "The scheduled event is not due now.");
            const prevIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const prevIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const prevSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const prevSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const prevBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const prevBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});
    
            // Complete a partial deposit
            await this.nutsPlatform.depositToken(this.issuanceId, this.collateralToken.address, 10, {from: buyer});

            // Move the timestamp
            await time.increase(5 * 24 * 3600 + 100);
            // Scheduled event: engagement_expired
            tx = await this.nutsPlatform.processScheduledEvent(this.issuanceId, timestamp, "collateral_expired", "");
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(this.issuanceId),
                state: "Delinquent"
            });

            const curIssuanceEther = await this.nutsEscrow.balanceOfIssuance(this.issuanceId);
            const curIssuanceToken = await this.nutsEscrow.tokenBalanceOfIssuance(this.issuanceId, this.collateralToken.address);
            const curSellerEther = await this.nutsEscrow.balanceOf({from: seller});
            const curSellerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: seller});
            const curBuyerEther = await this.nutsEscrow.balanceOf({from: buyer});
            const curBuyerToken = await this.nutsEscrow.tokenBalanceOf(this.collateralToken.address, {from: buyer});
            // The Ether deposit should have been returned to seller
            // console.log(prevIssuanceEther, curIssuanceEther);
            // console.log(prevIssuanceToken, curIssuanceToken);
            // console.log(prevSellerEther, curSellerEther);
            // console.log(prevSellerToken, curSellerToken);
            // console.log(prevBuyerEther, curBuyerEther);
            // console.log(prevBuyerToken, curBuyerToken);
            expect(prevIssuanceEther.sub(curIssuanceEther)).be.bignumber.equal('5');
            expect(curIssuanceToken).be.bignumber.equal(prevIssuanceToken);
            expect(curSellerEther.sub(prevSellerEther)).be.bignumber.equal('5');
            expect(curSellerToken).be.bignumber.equal(prevSellerToken);
            expect(curBuyerEther).be.bignumber.equal(prevBuyerEther);
            expect(curBuyerToken).be.bignumber.equal(prevBuyerToken);
        }),
        it("should go to Delinquent state if not enough collateral is deposit", async function() {
            // Engage the issuance
            let tx = await this.nutsPlatform.engageIssuance(this.issuanceId, "", {from: buyer});
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(this.issuanceId),
                state: "Active"
            });

            await shouldFail.reverting.withMessage(this.nutsPlatform.deposit(this.issuanceId, 2, {from: seller}), "Ether deposit must happen in Initiated state.");
            await shouldFail.reverting.withMessage(this.nutsPlatform.deposit(this.issuanceId, 2, {from: buyer}), "Ether repay must happen after collateral is deposited.");
            await shouldFail.reverting.withMessage(this.nutsPlatform.deposit(this.issuanceId, 2, {from: buyer2}), "Unknown transferer. Only seller or buyer can send Ether to issuance.");
        })
    })
});