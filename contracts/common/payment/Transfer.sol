pragma solidity ^0.5.0;

import "../seriality/BytesToTypes.sol";
import "../seriality/TypesToBytes.sol";
import "../seriality/SizeOf.sol";
import "../util/StringUtil.sol";

/**
 * @title Core library to represent a balance transfer action
 * Note: One key difference between Balance and Transfer is that,
 * Balance has at most one entry per token, but Transfer can have multiple
 * entries as the receivers might be different!
 */
library Transfer {
    /**
     * @dev Represent a single transfer action
     */
    struct TransferAction {
        // Whether it's the Ether balance entry
        bool isEther;
        // Address of the ERC20 token; not applicable if isEther = true
        address tokenAddress;
        // The receiver of the Ether/ERC20 token
        address receiverAddress;
        uint amount;
    }

    /**
     * @dev Represents a set of transfer actions
     */
    struct Transfers {
        TransferAction[] actions;
    }

    /**
     * @dev Serialize the transfers into bytes
     */
    function save(Transfers storage transfers) internal view returns (bytes memory data) {
        // Size of one balance = size of token address(20) + + size of receiver address(20) + size of uint(32) = 84
        uint size = 32 + transfers.actions.length * 72;
        data = new bytes(size);
        uint offset = size;
        TypesToBytes.uintToBytes(offset, transfers.actions.length, data);
        offset -= 32;

        for (uint i = 0; i < transfers.actions.length; i++) {
            TypesToBytes.addressToBytes(offset, transfers.actions[i].tokenAddress, data);
            offset -= 20;
            TypesToBytes.addressToBytes(offset, transfers.actions[i].receiverAddress, data);
            offset -= 20;
            TypesToBytes.uintToBytes(offset, transfers.actions[i].amount, data);
            offset -= 32;
        }
    }

    /**
     * @dev Deserialize the transfers from bytes
     */
    function load(Transfers storage transfers, bytes memory data) internal {
        transfers.actions.length = 0;
        uint offset = data.length;
        uint length = BytesToTypes.bytesToUint256(offset, data);
        offset -= 32;
        
        for (uint i = 0; i < length; i++) {
            address tokenAddress = BytesToTypes.bytesToAddress(offset, data);
            offset -= 20;
            address receiverAddress = BytesToTypes.bytesToAddress(offset, data);
            offset -= 20;
            uint amount = BytesToTypes.bytesToUint256(offset, data);
            offset -= 32;

            transfers.actions.push(TransferAction(tokenAddress == address(0x0), tokenAddress, receiverAddress, amount));
        }
    }

    function clear(Transfers storage transfers) internal {
        transfers.actions.length = 0;
    }

    /**
     * @dev Add a new Ether transfer action.
     */
    function addEtherTransfer(Transfers storage transfers, address receiverAddress, uint amount) internal {
        transfers.actions.push(TransferAction(true, address(0x0), receiverAddress, amount));
    }

    function getEtherTransfer(Transfers storage transfers, address receiverAddress) internal view returns (uint amount) {
        for (uint i = 0; i < transfers.actions.length; i++) {
            if (transfers.actions[i].isEther && transfers.actions[i].receiverAddress == receiverAddress) {
                amount = transfers.actions[i].amount;
                break;
            }
        }
    }

    function addTokenTransfer(Transfers storage transfers, address tokenAddress, address receiverAddress, uint amount) internal {
        transfers.actions.push(TransferAction(false, tokenAddress, receiverAddress, amount));
    }

    function getTokenTransfer(Transfers storage transfers, address tokenAddress) internal view returns (address receiverAddress, uint amount) {
        for (uint i = 0; i < transfers.actions.length; i++) {
            if (!transfers.actions[i].isEther && transfers.actions[i].tokenAddress == tokenAddress) {
                receiverAddress = transfers.actions[i].receiverAddress;
                amount = transfers.actions[i].amount;
                break;
            }
        }
    }
}