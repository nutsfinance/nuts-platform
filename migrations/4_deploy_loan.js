const Loan = artifacts.require("./instrument/loan/Loan.sol");

module.exports = function(deployer) {
  deployer.deploy(Loan, {gas: 6500000});
};
