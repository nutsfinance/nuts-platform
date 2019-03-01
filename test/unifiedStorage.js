const UnifiedStorage = artifacts.require('./UnifiedStorage.sol');
const assert = require('assert');

let contractInstance;

contract('UnifiedStorage', (accounts) => {
    beforeEach(async () => {
       contractInstance = await UnifiedStorage.deployed();
    })
    it('should add a new key-value pair of strings', async () => {
       await contractInstance.save('this is new key', 'this is new value');
       const valueContent = await contractInstance.lookup('this is new key');
       
       assert.equal(valueContent, 'this is new value', 'The content of the value is not correct')
    })
 });