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
    function save(Balances storage self) internal view returns (bytes memory data) {
        // Size of one balance = size of address(20) + size of uint(32) = 52
        uint size = 32 + self.entries.length * 52;
        data = new bytes(size);
        uint offset = size;
        TypesToBytes.uintToBytes(offset, self.entries.length, data);
        offset -= 32;

        for (uint i = 0; i < self.entries.length; i++) {
            TypesToBytes.addressToBytes(offset, self.entries[i].tokenAddress, data);
            offset -= 20;

            TypesToBytes.uintToBytes(offset, self.entries[i].amount, data);
            offset -= 32;
        }
    }

    /**
     * Deserialize the self from bytes
     */
    function load(Balances storage self, bytes memory data) internal {
        self.entries.length = 0;
        uint offset = data.length;
        uint length = BytesToTypes.bytesToUint256(offset, data);
        offset -= 32;
        
        for (uint i = 0; i < length; i++) {
            address tokenAddress = BytesToTypes.bytesToAddress(offset, data);
            offset -= 20;
            uint amount = BytesToTypes.bytesToUint256(offset, data);
            offset -= 32;

            self.entries.push(BalanceEntry(tokenAddress == address(0x0), tokenAddress, amount));
        }
    }

    function clear(Balances storage self) internal {
        self.entries.length = 0;
    }

    /**
     * @dev Get the Ether balance
     */
    function getEtherBalance(Balances storage self) internal view returns (uint amount) {
        for (uint i = 0; i < self.entries.length; i++) {
            if (self.entries[i].isEther) {
                amount = self.entries[i].amount;
                break;
            }
        }
    }

    /**
     * @dev Set the Ether balance
     */
    function setEtherBalance(Balances storage self, uint amount) internal {
        for (uint i = 0; i < self.entries.length; i++) {
            if (self.entries[i].isEther) {
                self.entries[i].amount = amount;
                return;
            }
        }
        // Ether not in balance
        self.entries.push(BalanceEntry(true, address(0x0), amount));
    }

    /**
     * @dev Get the ERC20 token balance
     */
    function getTokenBalance(Balances storage self, address tokenAddress) internal view returns (uint amount) {
        for (uint i = 0; i < self.entries.length; i++) {
            if (self.entries[i].tokenAddress == tokenAddress) {
                amount = self.entries[i].amount;
                break;
            }
        }
    }

    /**
     * @dev Set the ERC20 token balance
     */
    function setTokenBalance(Balances storage self, address tokenAddress, uint amount) internal {
        for (uint i = 0; i < self.entries.length; i++) {
            if (self.entries[i].tokenAddress == tokenAddress) {
                self.entries[i].amount = amount;
                return;
            }
        }
        // Token not in balance
        self.entries.push(BalanceEntry(false, tokenAddress, amount));
    }
}