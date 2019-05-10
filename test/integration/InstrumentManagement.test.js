const { BN, constants, expectEvent, shouldFail } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

const NutsPlatform = artifacts.require("../../contracts/NutsPlatform.sol");
const NutsToken = artifacts.require("../../contracts/NutsToken.sol");
const InstrumentMock = artifacts.require("../../contracts/mock/InstrumentMock.sol");

contract("NutsPlatform", ([owner, fsp, seller]) => {
    beforeEach("deploy new NUTS platform and loan contracts", async function() {
        this.platformInstance = await NutsPlatform.deployed();
        this.nutsToken = await NutsToken.deployed();
        // Grant Nuts token to fsp and seller
        this.nutsToken.mint(fsp, 10);
        this.nutsToken.mint(seller, 10);
        this.nutsToken.approve(this.platformInstance.address, 10, {from: fsp});
        this.nutsToken.approve(this.platformInstance.address, 10, {from: seller});
        this.instrumentInstance = await InstrumentMock.new({from: fsp});
    }),
    context("Instrument management", async function() {
        it("should register instrument and create issuance", async function() {
            await this.platformInstance.addFsp(fsp, {from: owner});
            await this.platformInstance.createInstrument(this.instrumentInstance.address, 0, {from: fsp});
            expect(await this.platformInstance.createIssuance(this.instrumentInstance.address, 
                "", {from: seller})).to.be.bignumber.equal.to(new BN(1));
        })
    })
});