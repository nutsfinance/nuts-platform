pragma solidity ^0.5.0;

import "../seriality/BytesToTypes.sol";
import "../seriality/TypesToBytes.sol";
import "../seriality/SizeOf.sol";
import "../util/StringUtil.sol";

/**
 * @title Core library to represent the balance of an issuance.
 */
library Balance {
    struct BalanceEntry {
        // Whether it's the Ether balance entry
        bool isEther;
        // Address of the ERC20 token; not applicable if isEther = true
        address tokenAddress;
        uint amount;
    }

    struct Balances {
        BalanceEntry[] entries;
    }

    /**
     * Serialize the balances into bytes
     */
    function save(Balances storage balances) internal view returns (bytes memory data) {
        // Size of one balance = size of address(20) + size of uint(32) = 52
        uint size = 32 + balances.entries.length * 52;
        data = new bytes(size);
        uint offset = size;
        TypesToBytes.uintToBytes(offset, balances.entries.length, data);
        offset -= 32;

        for (uint i = 0; i < balances.entries.length; i++) {
            TypesToBytes.stringToBytes(offset, bytes(StringUtil.addressToString(balances.entries[i].tokenAddress)), data);
            offset -= 20;

            TypesToBytes.uintToBytes(offset, balances.entries[i].amount, data);
            offset -= 32;
        }
    }

    /**
     * Deserialize the balances from bytes
     */
    function load(Balances storage balances, bytes memory data) internal {
        balances.entries.length = 0;
        uint offset = data.length;
        uint length = BytesToTypes.bytesToUint256(offset, data);
        offset -= 32;
        
        for (uint i = 0; i < length; i++) {
            bytes memory addressBuffer = new bytes(BytesToTypes.getStringSize(offset, data));
            BytesToTypes.bytesToString(offset, data, addressBuffer);
            offset -= BytesToTypes.getStringSize(offset, data);
            address tokenAddress = StringUtil.stringToAddress(string(addressBuffer));
            uint amount = BytesToTypes.bytesToUint(offset, data);
            offset -= 32;

            balances.entries.push(BalanceEntry(tokenAddress == address(0x0), tokenAddress, amount));
        }
    }

    function clear(Balances storage balances) internal {
        balances.entries.length = 0;
    }

    /**
     * @dev Get the Ether balance
     */
    function getEtherBalance(Balances storage balances) internal view returns (uint amount) {
        for (uint i = 0; i < balances.entries.length; i++) {
            if (balances.entries[i].isEther) {
                amount = balances.entries[i].amount;
                break;
            }
        }
    }

    /**
     * @dev Set the Ether balance
     */
    function setEtherBalance(Balances storage balances, uint amount) internal {
        for (uint i = 0; i < balances.entries.length; i++) {
            if (balances.entries[i].isEther) {
                balances.entries[i].amount = amount;
                return;
            }
        }
        // Ether not in balance
        balances.entries.push(BalanceEntry(true, address(0x0), amount));
    }

    /**
     * @dev Get the ERC20 token balance
     */
    function getTokenBalance(Balances storage balances, address tokenAddress) internal view returns (uint amount) {
        for (uint i = 0; i < balances.entries.length; i++) {
            if (balances.entries[i].tokenAddress == tokenAddress) {
                amount = balances.entries[i].amount;
                break;
            }
        }
    }

    /**
     * @dev Set the ERC20 token balance
     */
    function setTokenBalance(Balances storage balances, address tokenAddress, uint amount) internal {
        for (uint i = 0; i < balances.entries.length; i++) {
            if (balances.entries[i].tokenAddress == tokenAddress) {
                balances.entries[i].amount = amount;
                return;
            }
        }
        // Token not in balance
        balances.entries.push(BalanceEntry(false, tokenAddress, amount));
    }
}