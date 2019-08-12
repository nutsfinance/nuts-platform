var UnifiedStorage = artifacts.require("./UnifiedStorage.sol");
var NutsEscrow = artifacts.require("./NutsEscrow.sol");
var NutsToken = artifacts.require("./NutsToken.sol");
var InstrumentRegistry = artifacts.require("./InstrumentRegistry.sol");
var NutsPlatform = artifacts.require("./NutsPlatform.sol");
var Loan = artifacts.require("./instrument/Loan.sol");

const deployNutsPlatform = async function(deployer) {
  let instrumentRegistryStorage = await deployer.deploy(UnifiedStorage);
  console.log("instrumentRegistryStorage");
  let instrumentRegistry = await deployer.deploy(InstrumentRegistry, instrumentRegistryStorage.address);
  console.log("instrumentRegistry");
  await instrumentRegistryStorage.addWhitelistAdmin(instrumentRegistry.address);
  console.log("addWhitelistAdmin");
  let nutsPlatformStorage = await deployer.deploy(UnifiedStorage);
  console.log("nutsPlatformStorage");
  let nutsToken = await deployer.deploy(NutsToken);
  console.log("nutsToken");
  let nutsEscrow = await deployer.deploy(NutsEscrow);
  console.log("nutsEscrow");
  let nutsPlatform = await deployer.deploy(NutsPlatform, nutsPlatformStorage.address,
    instrumentRegistry.address, nutsToken.address, nutsEscrow.address);
  console.log("nutsPlatform");
  await nutsPlatformStorage.addWhitelistAdmin(nutsPlatform.address);
  console.log("nutsPlatformStorage.addWhitelistAdmin");
  await instrumentRegistry.addWhitelistAdmin(nutsPlatform.address);
  console.log("instrumentRegistry.addWhitelistAdmin");
  await nutsEscrow.addWhitelistAdmin(nutsPlatform.address);
  console.log("nutsEscrow.addWhitelistAdmin");
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
