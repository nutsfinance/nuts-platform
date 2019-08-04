pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;

import "./common/property/Property.sol";
import "./Instrument.sol";

contract PropertyBasedInstrument is Instrument {
    using Property for Property.Properties;

        /**
     *
     *  Internal utility functions for instruments
     *
     */
    // Current properties of the issuance
    Property.Properties internal _properties;
    // Custom parameters
    Property.Properties internal _parameters;

    // Issuance state constants
    string constant INITIATED_STATE = "Initiated";
    string constant ENGAGABLE_STATE = "Engageable";
    string constant ACTIVE_STATE = "Active";
    string constant UNFUNDED_STATE = "Unfunded";
    string constant COMPLETE_NOT_ENGAGED_STATE = "Complete Not Engaged";
    string constant COMPLETE_ENGAGED_STATE = "Complete Engaged";
    string constant DELINQUENT_STATE = "Delinquent";

    /**
     * @dev Check whether the issuance is currently in a state
     * @param state The state to check
     * @return True is the issuance is in this state
     */
    function isIssuanceInState(string memory state) internal view returns (bool) {
        return StringUtil.equals(_properties.getStringValue("state"), state);
    }

    /**
     * @dev Updates the state of the issuance.
     * @param issuanceId The issuance id
     * @param state The updated issuance state
     */
    function updateIssuanceState(uint issuanceId, string memory state) internal {
        _properties.setStringValue("state", state);
        emit IssuanceStateUpdated(issuanceId, state);
    }
}