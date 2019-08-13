pragma solidity ^0.5.0;

import "../lib/access/WhitelistAdminRole.sol";
import "../lib/util/StringUtil.sol";
import "../storage/StorageInterface.sol";
import "./InstrumentInfo.sol";

/**
 * @title Interface for instrument registry.
 */
interface InstrumentRegistryInterface {
    /**
     * @dev Creates a new instruments in the registry.
     * @param fspAddress The address of the FSP which creates the instrument.
     * @param instrumentAddress The address the deployed instrument contract.
     * @param expiration The TTL of the instrument. 0 means never expires.
     */
    function create(address fspAddress, address instrumentAddress, uint256 expiration) external;

    /**
     * @dev Deactivates an instrument.
     * @param fspAddress The address of the FSP who deactivates the instrument.
     * @param instrumentAddress The address of the instrumetn to deactivate.
     */
    function deactivate(address fspAddress, address instrumentAddress) external;

    /**
     * @dev Validate an instrument.
     * @param instrumentAddress The address of the instrument to validate.
     */
    function validate(address instrumentAddress) external view returns (bool);
}
