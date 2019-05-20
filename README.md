# NUTS Platform

The NUTS platform is designed to support the issuance of non-standardized financial contracts traded through an over-the-counter network. The detail design of the platform can be viewed [here](https://app.gitbook.com/@nutsfinance/s/nuts-design-doc/);

## How to Run

To build the project and run the test cases, following the steps below:

1. Install Truffle  `npm install -g truffle`
1. Install Ganache-GUI and start it
1. Run the Test Cases `truffle test --development`

To get the contract size, run the following command:
```
grep \"bytecode\" build/contracts/* | awk '{print $1 " " length($3)/2}'
```
## How to Deploy

To deploy the NUTS platform to test net/main net, follow the steps below:

1. Deploy the **UnifiedStorage** contract;
1. Deploy the **InstrumentRegistry** contract;
1. Deploy the **NutsToken** contract;
1. Deploy the **NutsEscrow** contract;
1. Deploy the **NutsPlatform** contract and pass the addresses of **UnifiedStorage, InstrumentRegistry, NutsToken, NutsEscrow** as parameters;
1. Whitelist **NutsPlatform**'s access to **UnifiedStorage**
```
unifiedStorage.addWhitelistAdmin(nutsPlatform.address);
```
1. Whitelist **NutsPlatform**'s access to **InstrumentRegistry**
```
instrumentRegistry.addWhitelistAdmin(nutsPlatform.address);
```
1. Whitelist **NutsPlatform**'s access to **NutsEscrow**
```
nutsEscrow.addWhitelistAdmin(nutsPlatform.address);
```
