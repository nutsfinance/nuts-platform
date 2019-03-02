pragma solidity ^0.5.0;

/**
 *  @title Financial instrument interface
 */
interface IInstrument {

    /**
     *  Create a new issuance of the financial instrument
     */
    function createIssuance(uint256 issuance_id, string calldata state) external returns (string memory);
}