const BigNumber = require('bignumber.js');
const { BN, expectEvent, shouldFail, time, ether } = require('openzeppelin-test-helpers');
function getSellerParameters(proto, collateralTokenAddressData, collateralTokenAmountData,
  borrowAmountData, depositDueDaysData, collateralDueDaysData, engagementDueDaysData, tenorDaysData,
  interestRateData, gracePeriodData) {
  let message = new proto.SellerParameters();
  let collateralTokenAddress = new proto.solidity.address();
  let collateralTokenAmount = new proto.solidity.uint256();
  let borrowAmount = new proto.solidity.uint256();
  let depositDueDays = new proto.solidity.uint32();
  let collateralDueDays = new proto.solidity.uint32();
  let engagementDueDays = new proto.solidity.uint32();
  let tenorDays = new proto.solidity.uint32();
  let interestRate = new proto.solidity.uint32();
  let gracePeriod = new proto.solidity.uint32();
  collateralTokenAddress.saveAsBytes(BigNumber(collateralTokenAddressData.toString().toLowerCase()));
  collateralTokenAmount.saveAsBytes(collateralTokenAmountData);
  borrowAmount.saveAsBytes(BigNumber(ether(borrowAmountData).toString()));
  depositDueDays.saveAsBytes(depositDueDaysData);
  collateralDueDays.saveAsBytes(collateralDueDaysData);
  engagementDueDays.saveAsBytes(engagementDueDaysData);
  tenorDays.saveAsBytes(tenorDaysData);
  interestRate.saveAsBytes(interestRateData);
  gracePeriod.saveAsBytes(gracePeriodData);
  message.setCollateraltokenaddress(collateralTokenAddress);
  message.setCollateraltokenamount(collateralTokenAmount);
  message.setBorrowamount(borrowAmount);
  message.setDepositduedays(depositDueDays);
  message.setCollateralduedays(collateralDueDays);
  message.setEngagementduedays(engagementDueDays);
  message.setTenordays(tenorDays);
  message.setInterestrate(interestRate);
  message.setGraceperiod(gracePeriod);
  return message.serializeBinary();
}

module.exports = {
  getSellerParameters: getSellerParameters
}
