var UnifiedStorage = artifacts.require("./UnifiedStorage.sol");
var NutsEscrow = artifacts.require("./NutsEscrow.sol");
var NutsToken = artifacts.require("./NutsToken.sol");
var InstrumentRegistry = artifacts.require("./InstrumentRegistry.sol");
var NutsPlatform = artifacts.require("./NutsPlatform.sol");
var Loan = artifacts.require("./instrument/Loan.sol");

const deployNutsPlatform = async function(deployer) {
  let unifiedStorage = await deployer.deploy(UnifiedStorage);
  let instrumentRegistry = await deployer.deploy(InstrumentRegistry);
  let nutsToken = await deployer.deploy(NutsToken);
  let nutsEscrow = await deployer.deploy(NutsEscrow);
  let nutsPlatform = await deployer.deploy(NutsPlatform, unifiedStorage.address, 
    instrumentRegistry.address, nutsToken.address, nutsEscrow.address, {gas: 6000000});
  
  await unifiedStorage.addWhitelistAdmin(nutsPlatform.address);
  await instrumentRegistry.addWhitelistAdmin(nutsPlatform.address);
  await nutsEscrow.addWhitelistAdmin(nutsPlatform.address);
};

module.exports = function(deployer) {
  deployer
    .then(() => deployNutsPlatform(deployer))
    .catch(error => {
      console.log(error);
      process.exit(1);
    });
};

// module.exports = function(deployer) {
//   let unifiedStorage;
//   let instrumentRegistry;
//   let nutsToken;
//   let nutsEscrow;
//   let nutsPlatform;

//   deployer.deploy(UnifiedStorage)
//     .then(function(instance) {
//       unifiedStorage = instance;
//       return deployer.deploy(InstrumentRegistry);
//     })
//     .then(function(instance) {
//       instrumentRegistry = instance;
//       return deployer.deploy(NutsToken);
//     })
//     .then(function(instance) {
//       nutsToken = instance;
//       return deployer.deploy(NutsEscrow);
//     })
//     .then(function(instance) {
//       nutsEscrow = instance;
//       return deployer.deploy(NutsPlatform, UnifiedStorage.address, 
//         InstrumentRegistry.address, NutsToken.address, NutsEscrow.address, {gas: 6000000});
//     })
//     .then(function(instance) {
//       nutsPlatform = instance;
//       unifiedStorage.addWhitelistAdmin(nutsPlatform.address);
//     })
//     .then(function () {
//       instrumentRegistry.addWhitelistAdmin(nutsPlatform.address);
//     })
//     .then(function () {
//       nutsEscrow.addWhitelistAdmin(nutsPlatform.address);
//     });

//   // deployer.deploy(Loan, {gas: 6700000});
// };
