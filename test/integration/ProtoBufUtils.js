const BigNumber = require('bignumber.js');
const { BN, expectEvent, shouldFail, time, ether } = require('openzeppelin-test-helpers');
function getSellerParameters(SellerParameters, collateralTokenAddress, collateralTokenAmount,
  borrowAmount, depositDueDays, collateralDueDays, engagementDueDays, tenorDays,
  interestRate, gracePeriod) {
  let payload = {
    collateralTokenAddress: {

    },
    collateralTokenAmount: {

    },
    borrowAmount: {

    },
    depositDueDays: {

    },
    collateralDueDays: {

    },
    engagementDueDays: {

    },
    tenorDays: {

    },
    interestRate: {

    },
    gracePeriod: {

    }
  }
  let message = SellerParameters.fromObject(payload);
  message.collateralTokenAddress.saveAsBytes(BigNumber(collateralTokenAddress.toString().toLowerCase()));
  message.collateralTokenAmount.saveAsBytes(collateralTokenAmount);
  message.borrowAmount.saveAsBytes(BigNumber(ether(borrowAmount).toString()));
  message.depositDueDays.saveAsBytes(depositDueDays);
  message.collateralDueDays.saveAsBytes(collateralDueDays);
  message.engagementDueDays.saveAsBytes(engagementDueDays);
  message.tenorDays.saveAsBytes(tenorDays);
  message.interestRate.saveAsBytes(interestRate);
  message.gracePeriod.saveAsBytes(gracePeriod);
  return SellerParameters.encode(message).finish();
}

module.exports = {
  getSellerParameters: getSellerParameters
}
