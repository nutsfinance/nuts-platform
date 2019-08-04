pragma solidity ^0.5.0;

/**
 * @title Core library to represent the token balance, including ETH.
 */
library TokenBalance {
    struct Balance {
        // Whether it's the Ether balance entry
        bool isEther;
        // Address of the ERC20 token; not applicable if isEther = true
        address tokenAddress;
        uint amount;
    }

    struct Balances {
        Balance[] entries;
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
        self.entries.push(Balance(true, address(0x0), amount));
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
        self.entries.push(Balance(false, tokenAddress, amount));
    }
}