const NutsEscrow = artifacts.require('../NutsEscrow.sol');
const NutsToken = artifacts.require('../NutsToken.sol');
const assert = require('assert');

let escrowInstance;
let tokenInstance;
const DIFF = 100000000000000000;       // The transaction cost should be less then 0.1 Ether

contract('NutsEscrow', (accounts) => {
    beforeEach(async () => {
        tokenInstance = await NutsToken.new();
        escrowInstance = await NutsEscrow.new();
    }),
    it('should deposit and withdraw Ethers', async () => {
        let prev = parseInt(await web3.eth.getBalance(accounts[0]));
        let amount = 10000000000000000000;  // 10 ETH
        await escrowInstance.deposit({from: accounts[0], value: amount});
        let current = parseInt(await web3.eth.getBalance(accounts[0]));
        // Verify wallet balance after deposit
        assert.ok(prev - amount - current > 0 && prev - amount - current < DIFF, "The Ether is not transfered");

        // Verify escrow balance
        let escrowBalance = await escrowInstance.balanceOf({from: accounts[0]});
        console.log(escrowBalance);
        let balance = web3.utils.fromWei(escrowBalance, "Ether");
        assert.equal(balance, 10);

        await escrowInstance.withdraw(new web3.utils.BN('10000000000000000000'));
        balance = web3.utils.fromWei(await escrowInstance.balanceOf(), "Ether");
        assert.equal(balance, 0);
    }),
    it('should deposit and withdraw ERC20 tokens', async () => {
        // console.log(escrowInstance.address);
        // console.log(tokenInstance.address);
        await tokenInstance.setMinterCap(accounts[5], 20000);
        await tokenInstance.mint(accounts[0], 200, {from: accounts[5]});
        await tokenInstance.approve(escrowInstance.address, 150);
        await escrowInstance.depositToken(tokenInstance.address, 80);
        let balance = (await escrowInstance.tokenBalanceOf(tokenInstance.address)).toNumber();
        assert.equal(balance, 80);

        let accountBalance = (await tokenInstance.balanceOf(accounts[0])).toNumber();
        let escrowBalance = (await tokenInstance.balanceOf(escrowInstance.address)).toNumber();
        assert.equal(accountBalance, 120);
        assert.equal(escrowBalance, 80);

        await escrowInstance.withdrawToken(tokenInstance.address, 50);
        balance = (await escrowInstance.tokenBalanceOf(tokenInstance.address)).toNumber();
        assert.equal(balance, 30);
    }),
    it('should allow issuance to hold Ethers', async () => {
        // console.log(escrowInstance.address);
        // console.log(tokenInstance.address);
        let amount = 10000000000000000000;
        let issuanceId = 100;
        await escrowInstance.deposit({from: accounts[0], value: amount});
        await escrowInstance.transferToIssuance(accounts[0], issuanceId, new web3.utils.BN('4000000000000000000'));
        let accountBalance = web3.utils.fromWei(await escrowInstance.balanceOf(), 'Ether');
        let issuanceBalance = web3.utils.fromWei(await escrowInstance.balanceOfIssuance(issuanceId), 'Ether');

        assert.equal(accountBalance, 6);
        assert.equal(issuanceBalance, 4);

        await escrowInstance.transferFromIssuance(accounts[0], issuanceId, new web3.utils.BN('2000000000000000000'));
        accountBalance = web3.utils.fromWei(await escrowInstance.balanceOf(), 'Ether');
        issuanceBalance = web3.utils.fromWei(await escrowInstance.balanceOfIssuance(issuanceId), 'Ether');

        assert.equal(accountBalance, 8);
        assert.equal(issuanceBalance, 2);
    }),
    it('should allow issuance to hold ERC20 tokens', async () => {
        // console.log(escrowInstance.address);
        // console.log(tokenInstance.address);
        let issuanceId = 100;
        await tokenInstance.setMinterCap(accounts[5], 2000);
        await tokenInstance.mint(accounts[0], 200, {from: accounts[5]});
        await tokenInstance.approve(escrowInstance.address, 150);
        
        // account - 120, escrow - 80
        await escrowInstance.depositToken(tokenInstance.address, 80);
        let accountBalance = await tokenInstance.balanceOf(accounts[0]);
        let escrowBalance = await tokenInstance.balanceOf(escrowInstance.address);
        let issuanceBalance;
        assert.equal(escrowBalance, 80);
        assert.equal(accountBalance, 120);

        // account - 120, escrow - 20, issuance - 60(from token point of view, escrow still has 80)
        await escrowInstance.transferTokenToIssuance(accounts[0], issuanceId, tokenInstance.address, 60);
        escrowBalance = await escrowInstance.tokenBalanceOf(tokenInstance.address);
        issuanceBalance = await escrowInstance.tokenBalanceOfIssuance(issuanceId, tokenInstance.address);
        // console.log(escrowBalance.toNumber());
        // console.log(issuanceBalance.toNumber());
        assert.equal(escrowBalance, 20);
        assert.equal(issuanceBalance, 60);

        // account - 120, escrow - 30, issuance - 50
        await escrowInstance.transferTokenFromIssuance(accounts[0], issuanceId, tokenInstance.address, 10);
        escrowBalance = await escrowInstance.tokenBalanceOf(tokenInstance.address);
        issuanceBalance = await escrowInstance.tokenBalanceOfIssuance(issuanceId, tokenInstance.address);
        // console.log(escrowBalance.toNumber());
        // console.log(issuanceBalance.toNumber());
        assert.equal(escrowBalance, 30);
        assert.equal(issuanceBalance, 50);
    })
 });