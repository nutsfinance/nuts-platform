pragma solidity ^0.5.0;

import "../Instrument.sol";

contract InstrumentMock {
    function createIssuance(uint256 issuanceId, address sellerAddress, string memory sellerParameters)
        public returns (string memory updatedProperties, string memory transfers) {
        // solhint-disable-previous-line no-empty-blocks
    }

    function engage(uint256 issuanceId, string memory properties, string memory balance, address buyerAddress,
        string memory buyerParameters) public returns (string memory updatedProperties, string memory transfers) {
        // solhint-disable-previous-line no-empty-blocks
    }

    function processTransfer(uint256 issuanceId, string memory properties, string memory balance,
        address fromAddress, uint256 amount) public returns (string memory updatedProperties, string memory transfers) {
        // solhint-disable-previous-line no-empty-blocks
    }

    function processTokenTransfer(uint256 issuanceId, string memory properties, string memory balance,
        address fromAddress, address tokenAddress, uint256 amount)
        public returns (string memory updatedProperties, string memory transfers) {
        // solhint-disable-previous-line no-empty-blocks
    }

    function processScheduledEvent(uint256 issuanceId, string memory properties, string memory balance,
        string memory eventName, string memory eventPayload) public returns (string memory updatedProperties, string memory transfers) {
        // solhint-disable-previous-line no-empty-blocks
    }

    function processCustomEvent(uint256 issuanceId, string memory properties, string memory balance,
        string memory eventName, string memory eventPayload) public returns (string memory updatedProperties, string memory transfers) {
        // solhint-disable-previous-line no-empty-blocks
    }

}