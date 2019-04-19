pragma solidity ^0.5.0;

import "../seriality/BytesToTypes.sol";
import "../seriality/TypesToBytes.sol";
import "../seriality/SizeOf.sol";
import "../util/StringUtil.sol";

/**
 * Core library to represent a balance transfer action
 */
library Transfer {
    struct TransferAction {
        // Whether it's the Ether balance entry
        bool isEther;
        // Address of the ERC20 token; not applicable if isEther = true
        address tokenAddress;
        // The receiver of the Ether/ERC20 token
        address receiverAddress;
        uint amount;
    }

    struct Transfers {
        TransferAction[] actions;
    }

    /**
     * Serialize the transfers into bytes
     */
    function save(Transfers storage transfers) internal view returns (bytes memory data) {
        // Size of one balance = size of token address(20) + + size of receiver address(20) + size of uint(32) = 84
        uint size = 32 + transfers.actions.length * 72;
        data = new bytes(size);
        uint offset = size;
        TypesToBytes.uintToBytes(offset, transfers.actions.length, data);
        offset -= 32;

        for (uint i = 0; i < transfers.actions.length; i++) {
            TypesToBytes.stringToBytes(offset, StringUtil.addressToBytes(transfers.actions[i].tokenAddress), data);
            offset -= 20;
            TypesToBytes.stringToBytes(offset, StringUtil.addressToBytes(transfers.actions[i].receiverAddress), data);
            offset -= 20;
            TypesToBytes.uintToBytes(offset, transfers.actions[i].amount, data);
            offset -= 32;
        }
    }

    /**
     * Deserialize the transfers from bytes
     */
    function load(Transfers storage transfers, bytes memory data) internal {
        transfers.actions.length = 0;
        uint offset = data.length;
        uint length = BytesToTypes.bytesToUint256(offset, data);
        offset -= 32;
        
        for (uint i = 0; i < length; i++) {
            bytes memory addressBuffer = new bytes(BytesToTypes.getStringSize(offset, data));
            BytesToTypes.bytesToString(offset, data, addressBuffer);
            offset -= BytesToTypes.getStringSize(offset, data);
            address tokenAddress = StringUtil.bytesToAddress(addressBuffer);
            addressBuffer = new bytes(BytesToTypes.getStringSize(offset, data));
            BytesToTypes.bytesToString(offset, data, addressBuffer);
            offset -= BytesToTypes.getStringSize(offset, data);
            address receiverAddress = StringUtil.bytesToAddress(addressBuffer);
            uint amount = BytesToTypes.bytesToUint256(offset, data);
            offset -= 32;

            transfers.actions.push(TransferAction(tokenAddress == address(0x0), tokenAddress, receiverAddress, amount));
        }
    }

    function clear(Transfers storage transfers) internal {
        transfers.actions.length = 0;
    }

    function addEtherTransfer(Transfers storage transfers, address receiverAddress, uint amount) internal {
        transfers.actions.push(TransferAction(true, address(0x0), receiverAddress, amount));
    }

    function addTokenTransfer(Transfers storage transfers, address tokenAddress, address receiverAddress, uint amount) internal {
        transfers.actions.push(TransferAction(false, tokenAddress, receiverAddress, amount));
    }
}