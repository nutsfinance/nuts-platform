const { BN, constants, expectEvent, shouldFail, time, send, ether } = require('openzeppelin-test-helpers');
const { ZERO_ADDRESS } = constants;
const NutsPlatform = artifacts.require("../../contracts/NutsPlatform.sol");
const NutsEscrow = artifacts.require("../../contracts/NutsEscrow.sol");
const NutsToken = artifacts.require("../../contracts/NutsToken.sol");
const Loan = artifacts.require("../../contracts/instrument/Loan.sol");
const ERC20Mintable = artifacts.require("../../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol");

contract("NutsPlatform", ([owner, fsp, seller, buyer, tokenOwner]) => {
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
    }),
    beforeEach("deploy new collateral token", async function() {
        // Deploy new collateral token
        this.collateralToken = await ERC20Mintable.new({from : tokenOwner});
        
        // // Buyer deposits Collateral token to escrow
        await this.collateralToken.mint(buyer, 50, {from: tokenOwner});
        await this.collateralToken.approve(this.nutsEscrow.address, 50, {from: buyer});
        await this.nutsEscrow.depositToken(this.collateralToken.address, 40, {from: buyer});
    }),
    context("Issuance creation", async function() {
        it("should be able to create issuance and deposit Ether", async function() {
            // Create issuance
            let tx = await this.nutsPlatform.createIssuance(this.loan.address,
                `collateral-token-address=${this.collateralToken.address}&collateral-amount=30&` + 
                `borrow-amount=5&deposit-due-days=3&engagement-due-days=20&collateral-due-days=5&` +
                `tenor-days=30&interest-rate=10000&grace-period=5`, {from: seller});
            const issuanceId = tx.logs.find(e => e.event == "IssuanceCreated").args.issuanceId.toNumber();
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(issuanceId),
                state: "Initiated"
            });

            // Seller deposit Ether: borrow amount = 5
            tx = await this.nutsPlatform.deposit(issuanceId, 5, {from: seller});
            await expectEvent.inTransaction(tx.receipt.transactionHash, Loan, "IssuanceStateUpdated", {
                issuanceId: new BN(issuanceId),
                state: "Engageable"
            });
            (await this.nutsEscrow.balanceOfIssuance(issuanceId)).should.be.bignumber.equal('5');
        })
        // it("should fail to create issuance with invalid parameters", async function() {
        //     // Send a zero collateral token address
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-token-address=0&collateral-amount=30&` + 
        //         `borrow-amount=5&deposit-due-days=3&engagement-due-days=20&collateral-due-days=5&` +
        //         `tenor-days=30&interest-rate=10000&grace-period=5`), "Collateral token address must not be 0");
            
        //     // Don't send collateral token address
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-amount=30&` + 
        //         `borrow-amount=5&deposit-due-days=3&engagement-due-days=20&collateral-due-days=5&` +
        //         `tenor-days=30&interest-rate=10000&grace-period=5`), "Collateral token address must not be 0");

        //     // Send a zero collateral amount
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-token-address=${this.collateralToken.address}&collateral-amount=0&` + 
        //         `borrow-amount=5&deposit-due-days=3&engagement-due-days=20&collateral-due-days=5&` +
        //         `tenor-days=30&interest-rate=10000&grace-period=5`), "Collateral amount must be greater than 0");

        //     // Don't send collateral amount
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-token-address=${this.collateralToken.address}&` + 
        //         `borrow-amount=5&deposit-due-days=3&engagement-due-days=20&collateral-due-days=5&` +
        //         `tenor-days=30&interest-rate=10000&grace-period=5`), "Collateral amount must be greater than 0");

        //     // Send a zero borrow amount
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-token-address=${this.collateralToken.address}&collateral-amount=30&` + 
        //         `borrow-amount=0&deposit-due-days=0&engagement-due-days=20&collateral-due-days=5&` +
        //         `tenor-days=30&interest-rate=10000&grace-period=5`), "Borrow amount must be greater than 0");
            
        //     // Don't send borrow amount
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-token-address=${this.collateralToken.address}&collateral-amount=30&` + 
        //         `deposit-due-days=3&engagement-due-days=20&collateral-due-days=5&` +
        //         `tenor-days=30&interest-rate=10000&grace-period=5`), "Borrow amount must be greater than 0");

        //     // Send a zero deposit due days
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-token-address=${this.collateralToken.address}&collateral-amount=30&` + 
        //         `borrow-amount=5&deposit-due-days=0&engagement-due-days=20&collateral-due-days=5&` +
        //         `tenor-days=30&interest-rate=10000&grace-period=5`), "Deposit due days must be greater than 0");

        //     // Don't send deposit due days
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-token-address=${this.collateralToken.address}&collateral-amount=30&` + 
        //         `borrow-amount=5&engagement-due-days=20&collateral-due-days=5&` +
        //         `tenor-days=30&interest-rate=10000&grace-period=5`), "Deposit due days must be greater than 0");

        //     // Send a zero engagement due days
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-token-address=${this.collateralToken.address}&collateral-amount=30&` + 
        //         `borrow-amount=5&deposit-due-days=3&engagement-due-days=0&collateral-due-days=5&` +
        //         `tenor-days=30&interest-rate=10000&grace-period=5`), "Engagement due days must be greater than 0");

        //     // Don't send engagement due days
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-token-address=${this.collateralToken.address}&collateral-amount=30&` + 
        //         `borrow-amount=5&deposit-due-days=3&collateral-due-days=5&` +
        //         `tenor-days=30&interest-rate=10000&grace-period=5`), "Engagement due days must be greater than 0");

        //     // Send a zero collateral due days
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-token-address=${this.collateralToken.address}&collateral-amount=30&` + 
        //         `borrow-amount=5&deposit-due-days=3&engagement-due-days=20&collateral-due-days=0&` +
        //         `tenor-days=30&interest-rate=10000&grace-period=5`), "Collateral due days must be greater than 0");

        //     // Don't send collateral due days
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-token-address=${this.collateralToken.address}&collateral-amount=30&` + 
        //         `borrow-amount=5&deposit-due-days=3&engagement-due-days=20&` +
        //         `tenor-days=30&interest-rate=10000&grace-period=5`), "Collateral due days must be greater than 0");

        //     // Send a zero tenor days
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-token-address=${this.collateralToken.address}&collateral-amount=30&` + 
        //         `borrow-amount=5&deposit-due-days=3&engagement-due-days=20&collateral-due-days=5&` +
        //         `tenor-days=0&interest-rate=10000&grace-period=5`), "Tenor days must be greater than 0");

        //     // Don't send tenor days
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-token-address=${this.collateralToken.address}&collateral-amount=30&` + 
        //         `borrow-amount=5&deposit-due-days=3&engagement-due-days=20&collateral-due-days=5&` +
        //         `interest-rate=10000&grace-period=5`), "Tenor days must be greater than 0");

        //     // Send a tenor days smaller than or equal to collateral days
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-token-address=${this.collateralToken.address}&collateral-amount=30&` + 
        //         `borrow-amount=5&deposit-due-days=3&engagement-due-days=20&collateral-due-days=5&` +
        //         `tenor-days=5&interest-rate=10000&grace-period=5`), "Tenor days must be greater than collateral due days");

        //     // Send a zero grace period
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-token-address=${this.collateralToken.address}&collateral-amount=30&` + 
        //         `borrow-amount=5&deposit-due-days=3&engagement-due-days=20&collateral-due-days=5&` +
        //         `tenor-days=30&interest-rate=10000&grace-period=0`), "Grace period must be greater than 0");

        //     // Don't send grace period
        //     await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.loan.address,
        //         `collateral-token-address=${this.collateralToken.address}&collateral-amount=30&` + 
        //         `borrow-amount=5&deposit-due-days=3&engagement-due-days=20&collateral-due-days=5&` +
        //         `tenor-days=30&interest-rate=10000`), "Grace period must be greater than 0");

        // })
    })
});