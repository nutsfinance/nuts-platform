const StakeMining = artifacts.require("./instrument/stake-mining/StakeMining.sol");

module.exports = function(deployer) {
  deployer.deploy(StakeMining, {gas: 6500000});
};
