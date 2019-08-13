const UnifiedStorage = artifacts.require("./storage/UnifiedStorage.sol");
const UnifiedStorageFactory = artifacts.require("./storage/StorageFactory.sol");
const NutsEscrow = artifacts.require("./escrow/NutsEscrow.sol");
const NutsToken = artifacts.require("./token/NutsToken.sol");
const InstrumentRegistry = artifacts.require("./instrument/InstrumentRegistry.sol");
const NutsPlatform = artifacts.require("./NutsPlatform.sol");

const deployNutsPlatform = async function(deployer) {
  // Deploy instrument registry
  let instrumentRegistryStorage = await deployer.deploy(UnifiedStorage);
  let instrumentRegistry = await deployer.deploy(InstrumentRegistry, instrumentRegistryStorage.address);
  await instrumentRegistryStorage.addWhitelistAdmin(instrumentRegistry.address);

  let nutsPlatformStorage = await deployer.deploy(UnifiedStorage);
  let unifiedStorageFactory = await deployer.deploy(UnifiedStorageFactory);
  let nutsToken = await deployer.deploy(NutsToken);
  let nutsEscrow = await deployer.deploy(NutsEscrow);
  let nutsPlatform = await deployer.deploy(NutsPlatform, nutsPlatformStorage.address, unifiedStorageFactory.address,
    instrumentRegistry.address, nutsToken.address, nutsEscrow.address);

  await nutsPlatformStorage.addWhitelistAdmin(nutsPlatform.address);
  await instrumentRegistry.addWhitelistAdmin(nutsPlatform.address);
  await nutsEscrow.addWhitelistAdmin(nutsPlatform.address);
  await unifiedStorageFactory.addWhitelistAdmin(nutsPlatform.address);
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
