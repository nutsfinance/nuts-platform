pragma solidity ^0.5.0;

import "./StorageFactoryInterface.sol";
import "./StorageInterface.sol";
import "./UnifiedStorage.sol";

/**
 * @title Factory for unified storages.
 */
contract StorageFactory {
    function createNewStorage() external returns (StorageInterface) {
        return new UnifiedStorage();
    }
}