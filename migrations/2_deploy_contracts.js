var UnifiedStorage = artifacts.require("./UnifiedStorage.sol");
var NutsEscrow = artifacts.require("./NutsEscrow.sol");
var NutsToken = artifacts.require("./NutsToken.sol");
var InstrumentRegistry = artifacts.require("./InstrumentRegistry.sol");

module.exports = function(deployer) {
  deployer.deploy(UnifiedStorage);
  deployer.deploy(NutsEscrow);
  deployer.deploy(NutsToken);
  deployer.deploy(InstrumentRegistry);
};
