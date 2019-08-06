const { BN, constants, expectEvent, shouldFail, time } = require('openzeppelin-test-helpers');
const { ZERO_ADDRESS } = constants;

const NutsPlatform = artifacts.require("../../contracts/NutsPlatform.sol");
const NutsToken = artifacts.require("../../contracts/NutsToken.sol");
const InstrumentMock = artifacts.require("../../contracts/mock/InstrumentMock.sol");

contract("NutsPlatform", ([owner, fsp, seller, buyer, minter]) => {
    before("deploy NUTS platform", async function() {
        this.nutsPlatform = await NutsPlatform.deployed();
        this.nutsToken = await NutsToken.deployed();
        // Grant Nuts token to fsp and seller
        await this.nutsToken.setMinterCap(minter, 20000);
        await this.nutsToken.mint(fsp, 200), {from: minter};
        await this.nutsToken.mint(seller, 200, {from: minter});
        await this.nutsToken.approve(this.nutsPlatform.address, 200, {from: fsp});
        await this.nutsToken.approve(this.nutsPlatform.address, 200, {from: seller});
        await this.nutsPlatform.addFsp(fsp, {from: owner});
    }),
    beforeEach("deploy new instrument", async function() {
        this.mockInstrument = await InstrumentMock.new({from: fsp});
    }),
    context("Instrument management", async function() {
        it("should register instrument and create issuance", async function() {
            let tx = await this.nutsPlatform.createInstrument(this.mockInstrument.address, 0, {from: fsp});
            expectEvent.inLogs(tx.logs, 'InstrumentCreated', {
                instrumentAddress: this.mockInstrument.address,
                fspAddress: fsp
            });
            tx = await this.nutsPlatform.createIssuance(this.mockInstrument.address, 
                "", {from: seller});
            expectEvent.inLogs(tx.logs, 'IssuanceCreated', {
                issuanceId: new BN(1),
                instrumentAddress: this.mockInstrument.address,
                sellerAddress: seller
            });
        }),
        it("should fail to create issuance on expired instrument", async function() {
            await this.nutsPlatform.createInstrument(this.mockInstrument.address, 200, {from: fsp});
            await this.nutsPlatform.createIssuance(this.mockInstrument.address, 
                "", {from: seller});
            await time.increase(250);
            await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.mockInstrument.address, 
                "", {from: seller}), "Invalid instrument");
        }),
        it("should fail to create issuance on deactivated instrument", async function() {
            await this.nutsPlatform.createInstrument(this.mockInstrument.address, 200, {from: fsp});
            await this.nutsPlatform.createIssuance(this.mockInstrument.address, 
                "", {from: seller});
            await this.nutsPlatform.deactivateInstrument(this.mockInstrument.address, {from: fsp});
            await shouldFail.reverting.withMessage(this.nutsPlatform.createIssuance(this.mockInstrument.address, 
                "", {from: seller}), "Invalid instrument");
        }),
        it("should fail to deactivate an instrument", async function() {
            await this.nutsPlatform.createInstrument(this.mockInstrument.address, 200, {from: fsp});
            await this.nutsPlatform.addFsp(seller, {from: owner});
            await shouldFail.reverting.withMessage(this.nutsPlatform.deactivateInstrument(this.mockInstrument.address, 
                {from: seller}), "Only admin or creator can deactivate an instrument");
            await this.nutsPlatform.deactivateInstrument(this.mockInstrument.address, 
                {from: owner});
            await this.nutsPlatform.renounceFsp({from: seller});
        }),
        it("should be able to update issuance from an expired instrument", async function() {
            await this.nutsPlatform.createInstrument(this.mockInstrument.address, 200, {from: fsp});
            const {logs} = await this.nutsPlatform.createIssuance(this.mockInstrument.address, 
                "", {from: seller});
            const event = logs.find(e => e.event == "IssuanceCreated");
            const issuanceId = event.args.issuanceId.toNumber();
            await time.increase(250);
            await this.nutsPlatform.engageIssuance(issuanceId, "");
        }),
        it("should be able to update issuance from an deactivated instrument", async function() {
            await this.nutsPlatform.createInstrument(this.mockInstrument.address, 200, {from: fsp});
            const {logs} = await this.nutsPlatform.createIssuance(this.mockInstrument.address, 
                "", {from: seller});
            const event = logs.find(e => e.event == "IssuanceCreated");
            const issuanceId = event.args.issuanceId.toNumber();
            await this.nutsPlatform.deactivateInstrument(this.mockInstrument.address, {from: fsp});
            await this.nutsPlatform.engageIssuance(issuanceId, "");
        }),
        it("should fail to create the same instrument multiple times", async function() {
            await this.nutsPlatform.createInstrument(this.mockInstrument.address, 200, {from: fsp});
            await shouldFail.reverting.withMessage(this.nutsPlatform.createInstrument(this.mockInstrument.address, 200, {from: fsp}),
                "Instrument already exists");
        })
    }),
    context("Access control", async function() {
        it("should not allow non-fsp to create instrument", async function() {
            await shouldFail.reverting.withMessage(this.nutsPlatform.createInstrument(this.mockInstrument.address, 0, {from: seller}),
                "FspRole: caller does not have the Fsp role");
        }),
        it("should not allow non-fsp to add or remove fsp role", async function() {
            await shouldFail.reverting.withMessage(this.nutsPlatform.addFsp(buyer, {from: seller}),
                "FspRole: caller does not have the Fsp role");
        })
    })
});


