pragma solidity ^0.5.0;

/**
 * @title Core library to represent a balance transfer action
 * Note: One key difference between Balance and Transfer is that,
 * Balance has at most one entry per token, but Transfer can have multiple
 * entries as the receivers might be different.
 */
library TokenTransfer {
    /**
     * @dev Represent a single transfer action
     */
    struct Transfer {
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
        Transfer[] actions;
    }

    function clear(Transfers storage self) internal {
        self.actions.length = 0;
    }

    /**
     * @dev Add a new Ether transfer action.
     */
    function addEtherTransfer(Transfers storage self, address receiverAddress, uint amount) internal {
        self.actions.push(Transfer(true, address(0x0), receiverAddress, amount));
    }

    function getEtherTransfer(Transfers storage self, address receiverAddress) internal view returns (uint amount) {
        for (uint i = 0; i < self.actions.length; i++) {
            if (self.actions[i].isEther && self.actions[i].receiverAddress == receiverAddress) {
                amount = self.actions[i].amount;
                break;
            }
        }
    }

    function addTokenTransfer(Transfers storage self, address tokenAddress, address receiverAddress, uint amount) internal {
        self.actions.push(Transfer(false, tokenAddress, receiverAddress, amount));
    }

    function getTokenTransfer(Transfers storage self, address tokenAddress) internal view returns (address receiverAddress, uint amount) {
        for (uint i = 0; i < self.actions.length; i++) {
            if (!self.actions[i].isEther && self.actions[i].tokenAddress == tokenAddress) {
                receiverAddress = self.actions[i].receiverAddress;
                amount = self.actions[i].amount;
                break;
            }
        }
    }
}