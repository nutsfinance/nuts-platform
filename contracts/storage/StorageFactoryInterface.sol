pragma solidity ^0.5.0;

import "./StorageInterface.sol";

/**
 * @title Interface for creating new Storage contract.
 */
interface StorageFactoryInterface {
    function createNewStorage() external returns (StorageInterface);
}