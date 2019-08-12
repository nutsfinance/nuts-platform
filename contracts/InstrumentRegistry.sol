pragma solidity ^0.5.0;

import "./lib/access/WhitelistAdminRole.sol";
import "./InstrumentInfo.sol";
import "./UnifiedStorage.sol";
import "./lib/util/StringUtil.sol";

/**
 * @title The registry of instruments.
 * All data are persisted in UnifiedStorage.
 */
contract InstrumentRegistry is WhitelistAdminRole {
    using InstrumentStatus for InstrumentStatus.Data;
    using FSPStatus for FSPStatus.Data;

    UnifiedStorage private _storage;

    constructor(address unifiedStorageAddress) public {
        _storage = UnifiedStorage(unifiedStorageAddress);
        // Validation
        // require(_storage.isWhitelistAdmin(address(this)), "InstrumentRegistry: Not admin of UnifiedStorage");
    }

    /**
     * @dev Creates a new instruments in the registry.
     * @param fspAddress The address of the FSP which creates the instrument.
     * @param instrumentAddress The address the deployed instrument contract.
     * @param expiration The TTL of the instrument. 0 means never expires.
     */
    function create(address fspAddress, address instrumentAddress, uint256 expiration) public onlyWhitelistAdmin {
        require(fspAddress != address(0x0), "InstrumentRegistry: FSP address must be set");
        require(instrumentAddress != address(0x0), "InstrumentRegistry: Instrument address must be set");
        bytes memory instrumentStatusData = _storage.getBytes(getInstrumentStatusKey(instrumentAddress));
        require(instrumentStatusData.length == 0, "InstrumentRegistry: Instrument already exists");

        // Save new instrument
        InstrumentStatus.Data memory instrumentStatus = InstrumentStatus.Data(instrumentAddress, fspAddress, true, now, now + expiration);
        _storage.setBytes(getInstrumentStatusKey(instrumentAddress), InstrumentStatus.encode(instrumentStatus));

        // Update FSP status
        bytes memory fspStatusData = _storage.getBytes(getFSPStatusKey(fspAddress));
        FSPStatus.Data memory fspStatus;
        if (fspStatusData.length == 0) {
            // New FSP
            fspStatus = FSPStatus.Data(fspAddress, new address[](1));
            fspStatus.instrumentAddresses[0] = instrumentAddress;
        } else {
            fspStatus = FSPStatus.decode(fspStatusData);
            fspStatus.addInstrumentAddresses(instrumentAddress);
        }
        _storage.setBytes(getFSPStatusKey(fspAddress), FSPStatus.encode(fspStatus));
    }

    /**
     * @dev Deactivates an instrument.
     * @param fspAddress The address of the FSP who deactivates the instrument.
     * @param instrumentAddress The address of the instrumetn to deactivate.
     */
    function deactivate(address fspAddress, address instrumentAddress) public onlyWhitelistAdmin {
        require(fspAddress != address(0x0), "InstrumentRegistry: FSP address must be set");
        require(instrumentAddress != address(0x0), "InstrumentRegistry: Instrument address must be set");
        bytes memory instrumentStatusData = _storage.getBytes(getInstrumentStatusKey(instrumentAddress));
        require(instrumentStatusData.length > 0, "InstrumentRegistry: Instrument does not exist");
        InstrumentStatus.Data memory instrumentStatus = InstrumentStatus.decode(instrumentStatusData);
        require(isWhitelistAdmin(fspAddress) || instrumentStatus.fspAddress == fspAddress,
            "InstrumentRegistry: Only admin or creator can deactivate an instrument");

        instrumentStatus.active = false;
        _storage.setBytes(getInstrumentStatusKey(instrumentAddress), InstrumentStatus.encode(instrumentStatus));
    }

    /**
     * @dev Validate an instrument.
     * @param instrumentAddress The address of the instrument to validate.
     */
    function validate(address instrumentAddress) public view onlyWhitelistAdmin returns (bool) {
        require(instrumentAddress != address(0x0), "Instrument address must be set");
        bytes memory instrumentStatusData = _storage.getBytes(getInstrumentStatusKey(instrumentAddress));
        require(instrumentStatusData.length > 0, "InstrumentRegistry: Instrument does not exist");
        InstrumentStatus.Data memory instrumentStatus = InstrumentStatus.decode(instrumentStatusData);
        // Validity check
        // 1. Not deactivated(status.active = true)
        // 2. Either expiration = 0 or expiration > now
        return instrumentStatus.active && (instrumentStatus.expiration == instrumentStatus.creation || instrumentStatus.expiration > now);
    }

    function getInstrumentStatusKey(address instrumentAddress) private pure returns (string memory) {
        return StringUtil.concat(instrumentAddress, "_instrumentStatus");
    }

    function getFSPStatusKey(address fspAddress) private pure returns (string memory) {
        return StringUtil.concat(fspAddress, "_fspStatus");
    }
}
