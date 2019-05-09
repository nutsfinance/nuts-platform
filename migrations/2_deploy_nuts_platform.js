var UnifiedStorage = artifacts.require("./UnifiedStorage.sol");
var NutsEscrow = artifacts.require("./NutsEscrow.sol");
var NutsToken = artifacts.require("./NutsToken.sol");
var InstrumentRegistry = artifacts.require("./InstrumentRegistry.sol");
var NutsPlatform = artifacts.require("./NutsPlatform.sol");
var Loan = artifacts.require("./instrument/Loan.sol");

module.exports = function(deployer) {
  deployer.deploy(UnifiedStorage)
    .then(function() {
      return deployer.deploy(InstrumentRegistry);
    })
    .then(function() {
      return deployer.deploy(NutsToken);
    })
    .then(function() {
      return deployer.deploy(NutsEscrow);
    })
    .then(function() {
      return deployer.deploy(NutsPlatform, UnifiedStorage.address, 
        InstrumentRegistry.address, NutsToken.address, NutsEscrow.address, {gas: 6000000});
    });

  // deployer.deploy(Loan, {gas: 6700000});
  // grep \"bytecode\" build/contracts/* | awk '{print $1 " " length($3)/2}'
};
