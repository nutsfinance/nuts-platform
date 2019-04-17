const Issuance = artifacts.require('./Issuance.sol');
const assert = require('assert');

let issuanceInstance;

contract('Issuance', (accounts) => {
    beforeEach(async () => {
        issuanceInstance = await Issuance.new();
    }),
    it('should set and get string properties', async () => {
        await issuanceInstance.setStringProperty('key1', 'value1');
        await issuanceInstance.setStringProperty('key2', 'value2');
        let value1 = await issuanceInstance.getStringProperty('key1');
        let value2 = await issuanceInstance.getStringProperty('key2');
        assert.equal(value1, "value1");
        assert.equal(value2, "value2");
    });
});