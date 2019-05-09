var Loan = artifacts.require("./instrument/Loan.sol");

module.exports = function(deployer) {
  deployer.deploy(Loan, {gas: 6000000});
};
