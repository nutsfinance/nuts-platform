const { BN, constants, expectEvent, shouldFail, time } = require('openzeppelin-test-helpers');
const { ZERO_ADDRESS } = constants;

const NutsPlatform = artifacts.require("../../contracts/NutsPlatform.sol");
const NutsToken = artifacts.require("../../contracts/NutsToken.sol");
const InstrumentMock = artifacts.require("../../contracts/mock/InstrumentMock.sol");

contract("NutsPlatform", ([owner, fsp, seller]) => {
    beforeEach("deploy new NUTS platform and loan contracts", async function() {
        this.platformInstance = await NutsPlatform.deployed();
        this.nutsToken = await NutsToken.deployed();
        // Grant Nuts token to fsp and seller
        await this.nutsToken.mint(fsp, 20);
        await this.nutsToken.mint(seller, 20);
        await this.nutsToken.approve(this.platformInstance.address, 20, {from: fsp});
        await this.nutsToken.approve(this.platformInstance.address, 20, {from: seller});
        this.instrumentInstance = await InstrumentMock.new({from: fsp});

        // If fsp is not assigned the role, do it
        const isFsp = await this.platformInstance.isFsp(fsp);
        if (!isFsp) {
            await this.platformInstance.addFsp(fsp, {from: owner});
        }
    }),
    context("Instrument management", async function() {
        it("should register instrument and create issuance", async function() {
            await this.platformInstance.createInstrument(this.instrumentInstance.address, 0, {from: fsp});
            const { logs } = await this.platformInstance.createIssuance(this.instrumentInstance.address, 
                "", {from: seller});
            expectEvent.inLogs(logs, 'IssuanceCreated', {
                issuanceId: new BN(1),
                instrumentAddress: this.instrumentInstance.address,
                sellerAddress: seller
            });
        }),
        it("should fail to create issuance on expired instrument", async function() {
            await this.platformInstance.createInstrument(this.instrumentInstance.address, 200, {from: fsp});
            await this.platformInstance.createIssuance(this.instrumentInstance.address, 
                "", {from: seller});
            await time.increase(250);
            await shouldFail.reverting.withMessage(this.platformInstance.createIssuance(this.instrumentInstance.address, 
                "", {from: seller}), "Invalid instrument");
        }),
        it("should fail to create issuance on deactivated instrument", async function() {
            await this.platformInstance.createInstrument(this.instrumentInstance.address, 200, {from: fsp});
            await this.platformInstance.createIssuance(this.instrumentInstance.address, 
                "", {from: seller});
            await this.platformInstance.deactivateInstrument(this.instrumentInstance.address, {from: fsp});
            await shouldFail.reverting.withMessage(this.platformInstance.createIssuance(this.instrumentInstance.address, 
                "", {from: seller}), "Invalid instrument");
        }),
        it("should fail to deactivate an instrument", async function() {
            await this.platformInstance.createInstrument(this.instrumentInstance.address, 200, {from: fsp});
            await this.platformInstance.addFsp(seller, {from: owner});
            await shouldFail.reverting.withMessage(this.platformInstance.deactivateInstrument(this.instrumentInstance.address, 
                {from: seller}), "Only admin or creator can deactivate an instrument");
            await this.platformInstance.deactivateInstrument(this.instrumentInstance.address, 
                {from: owner});
            await this.platformInstance.renounceFsp({from: seller});
        }),
        it("should be able to update issuance from an expired instrument", async function() {
            await this.platformInstance.createInstrument(this.instrumentInstance.address, 200, {from: fsp});
            const {logs} = await this.platformInstance.createIssuance(this.instrumentInstance.address, 
                "", {from: seller});
            const event = logs.find(e => e.event == "IssuanceCreated");
            const issuanceId = event.args.issuanceId.toNumber();
            await time.increase(250);
            await this.platformInstance.engageIssuance(issuanceId, "");
        }),
        it("should be able to update issuance from an deactivated instrument", async function() {
            await this.platformInstance.createInstrument(this.instrumentInstance.address, 200, {from: fsp});
            const {logs} = await this.platformInstance.createIssuance(this.instrumentInstance.address, 
                "", {from: seller});
            const event = logs.find(e => e.event == "IssuanceCreated");
            const issuanceId = event.args.issuanceId.toNumber();
            await this.platformInstance.deactivateInstrument(this.instrumentInstance.address, {from: fsp});
            await this.platformInstance.engageIssuance(issuanceId, "");
        })
    })
});


