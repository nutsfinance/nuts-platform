pragma solidity ^0.5.0;

import "./TokenBalance.sol";
import "./lib/access/WhitelistAdminRole.sol";
import "./lib/math/SafeMath.sol";
import "./lib/token/ERC20.sol";

/**
 * @title Escrow for both user and issuance.
 * Note: Unlike other infrastructure components of NUTS platform,
 * data of NutsEscrow is stored locally instead of in UnifiedStorage
 * as we don't expect NutsEscrow to upgrade.
 * Might review this decision later.
 */
contract NutsEscrow is WhitelistAdminRole {
    using SafeMath for uint256;
    using Balances for Balances.Data;

    event EtherDeposited(address indexed payee, uint256 amount);
    event EtherWithdrawn(address indexed payee, uint256 amount);
    event TokenDeposited(address indexed payee, address indexed token, uint256 amount);
    event TokenWithdrawn(address indexed payee, address indexed token, uint256 amount);

    // The balance information about a user are kept in mapping instead of TokenBalance.Balances.
    // This is because there is no requirement to iterate balance of a user.
    // Might review this requirement later.
    mapping(address => Balances.Data) private _userBalances;                // Balance of user
    mapping(uint256 => Balances.Data) private _issuanceBalances;            // Balance of issuance

    /**********************************************
     * API for users to deposit and withdraw Ether
     ***********************************************/

    /**
     * @dev Get the current balance in the escrow
     * @return Current balance of the invoker
     */
    function balanceOf() public view returns (uint256) {
        Balances.Data storage balances = _userBalances[msg.sender];
        for (uint i = 0; i < balances.entries.length; i++) {
            if (balances.entries[i].isEther) {
                return balances.entries[i].amount;
            }
        }
        return 0;
    }

    /**
     * @dev Deposits Ethers into the escrow
     */
    function deposit() public payable {
        uint256 amount = msg.value;
        Balance.Data storage userBalance = getUserEtherBalance(msg.sender);
        userBalance.amount = userBalance.amount.add(amount);

        emit EtherDeposited(msg.sender, amount);
    }

    /**
     * @dev Withdraw Ethers from the escrow
     * @param amount The amount of Ethers to withdraw
     */
    function withdraw(uint256 amount) public {
        Balance.Data storage userBalance = getUserEtherBalance(msg.sender);
        require(userBalance.amount >= amount, "Insufficial ether balance to withdraw");
        userBalance.amount = userBalance.amount.sub(amount);

        msg.sender.transfer(amount);

        emit EtherWithdrawn(msg.sender, amount);
    }

    /***********************************************
     *  API for users to deposit and withdraw ERC20 token
     **********************************************/

    /**
     * @dev Get the balance of the requested ERC20 token in the escrow
     * @param token The ERC20 token to check balance
     * @return The balance
     */
    function tokenBalanceOf(ERC20 token) public view returns (uint256) {
        Balances.Data storage balances = _userBalances[msg.sender];
        for (uint i = 0; i < balances.entries.length; i++) {
            if (balances.entries[i].tokenAddress == address(token)) {
                return balances.entries[i].amount;
            }
        }
        return 0;
    }

    /**
     * @dev Deposit ERC20 token to the escrow
     * @param token The ERC20 token to deposit
     * @param amount The amount to deposit
     */
    function depositToken(ERC20 token, uint256 amount) public {
        Balance.Data storage userBalance = getUserTokenBalance(msg.sender, address(token));
        userBalance.amount = userBalance.amount.add(amount);
        require(token.transferFrom(msg.sender, address(this), amount), "Insufficient balance to deposit");

        emit TokenDeposited(msg.sender, address(token), amount);
    }

    /**
     * @dev Withdraw ERC20 token from the escrow
     * @param token The ERC20 token to withdraw
     * @param amount The amount to withdraw
     */
    function withdrawToken(ERC20 token, uint256 amount) public {
        Balance.Data storage userBalance = getUserTokenBalance(msg.sender, address(token));
        userBalance.amount = userBalance.amount.sub(amount);

        require(token.transfer(msg.sender, amount), "Insufficient balance to withdraw");

        emit TokenWithdrawn(msg.sender, address(token), amount);
    }

    /**
     * @dev Get the balance information about all tokens of the user.
     * @param payee The user address
     * @return The balance of all tokens about this user.
     */
    function getUserBalances(address payee) public view onlyWhitelistAdmin returns (string memory) {
        return string(_userBalances[payee].encode());
    }

    /***********************************************
     *  API used by NUTS platform to hold tokens for issuance
     **********************************************/

    /**
     * @dev Get the Ether balance of an issuance in the escrow
     * @param issuanceId The id of the issuance
     * @return The Ether balance of the issuance in the escrow
     */
    function balanceOfIssuance(uint256 issuanceId) public view onlyWhitelistAdmin returns (uint256) {
        Balances.Data storage balances = _issuanceBalances[issuanceId];
        for (uint i = 0; i < balances.entries.length; i++) {
            if (balances.entries[i].isEther) {
                return balances.entries[i].amount;
            }
        }
        return 0;
    }

    /**
     * @dev Transfer Ethers from a seller/buyer to the issuance
     * @param payee The address of the seller/buyer
     * @param issuanceId The id of the issuance
     * @param amount The amount of Ether to transfer
     */
    function transferToIssuance(address payee, uint256 issuanceId, uint256 amount) public onlyWhitelistAdmin {
        // Subtract from the seller/buyer balance
        Balance.Data storage userBalance = getUserEtherBalance(payee);
        require(userBalance.amount >= amount, "Insufficient Ether balance");
        userBalance.amount = userBalance.amount.sub(amount);

        // Increase to the issuance balance
        Balance.Data storage issuanceBalance = getIssuanceEtherBalance(issuanceId);
        issuanceBalance.amount = issuanceBalance.amount.add(amount);
    }

    /**
     * @dev Transfer Ethers from an issuance to a seller/buyer
     * @param payee The address of the seller/buyer
     * @param issuanceId The id of the issuance
     * @param amount The amount of Ether to transfer
     */
    function transferFromIssuance(address payee, uint256 issuanceId, uint256 amount) public onlyWhitelistAdmin {
        // Subtract from the issuance balance
        Balance.Data storage issuanceBalance = getIssuanceEtherBalance(issuanceId);
        require(issuanceBalance.amount >= amount, "Insufficient Ether balance");
        issuanceBalance.amount = issuanceBalance.amount.sub(amount);

        // Increase to the seller/buyer balance
        Balance.Data storage userBalance = getUserEtherBalance(payee);
        userBalance.amount = userBalance.amount.add(amount);
    }

    /**
     * @dev Get the ERC20 token balance of an issuance in the escrow
     * @param issuanceId The id of the issuance
     * @param token The ERC20 token to check balance
     * @return The ERC20 token balance of the issuance in the escrow
     */
    function tokenBalanceOfIssuance(uint256 issuanceId, ERC20 token) public view onlyWhitelistAdmin returns (uint256) {
        Balances.Data storage balances = _issuanceBalances[issuanceId];
        for (uint i = 0; i < balances.entries.length; i++) {
            if (balances.entries[i].tokenAddress == address(token)) {
                return balances.entries[i].amount;
            }
        }
        return 0;
    }

    /**
     * @dev Transfer ERC20 token from a seller/buyer to the issuance
     * @param payee The address of the seller/buyer
     * @param issuanceId The id of the issuance
     * @param token The ERC20 token to transfer
     * @param amount The amount of ERC20 token to transfer
     */
    function transferTokenToIssuance(address payee, uint256 issuanceId, ERC20 token, uint256 amount) public onlyWhitelistAdmin {
        // Subtract from the seller/buyer balance
        Balance.Data storage userBalance = getUserTokenBalance(payee, address(token));
        require(userBalance.amount >= amount, "Inssufficient token balance");
        userBalance.amount = userBalance.amount.sub(amount);

        // Increase to the issuance balance
        Balance.Data storage issuanceBalance = getIssuanceTokenBalance(issuanceId, address(token));
        issuanceBalance.amount = issuanceBalance.amount.add(amount);
    }

    /**
     * @dev Transfer ERC20 token from the issuance to a seller/buyer
     * @param payee The address of the seller/buyer
     * @param issuanceId The id of the issuance
     * @param token The ERC20 token to transfer
     * @param amount The amount of ERC20 token to transfer
     */
    function transferTokenFromIssuance(address payee, uint256 issuanceId, ERC20 token, uint256 amount) public onlyWhitelistAdmin {
        // Subtract from the issuance balance
        Balance.Data storage issuanceBalance = getIssuanceTokenBalance(issuanceId, address(token));
        require(issuanceBalance.amount >= amount, "Insufficient token balance");
        issuanceBalance.amount = issuanceBalance.amount.sub(amount);

        // Increase to the seller/buyer balance
        Balance.Data storage userBalance = getUserTokenBalance(payee, address(token));
        userBalance.amount = userBalance.amount.add(amount);
    }

    /**
     * @dev Get the balance information about all tokens of the issuance.
     * @param issuanceId The issuance id
     * @return The balance of all tokens about this issuance.
     */
    function getIssuanceBalances(uint256 issuanceId) public view onlyWhitelistAdmin returns (string memory) {
        return string(_issuanceBalances[issuanceId].encode());
    }

    function getUserEtherBalance(address payee) private returns (Balance.Data storage) {
      Balances.Data storage balances = _userBalances[payee];
      for (uint i = 0; i < balances.entries.length; i++) {
        if (balances.entries[i].isEther) {
          return balances.entries[i];
        }
      }
      Balance.Data memory newBalance = Balance.Data(true, address(0x0), 0);
      balances.entries.push(newBalance);
      return balances.entries[balances.entries.length - 1];
    }

    function getUserTokenBalance(address payee, address tokenAddress) private returns (Balance.Data storage balance) {
      Balances.Data storage balances = _userBalances[payee];
      for (uint i = 0; i < balances.entries.length; i++) {
        if (balances.entries[i].tokenAddress == tokenAddress) {
          balance = balances.entries[i];
          return balance;
        }
      }
      Balance.Data memory newBalance = Balance.Data(false, tokenAddress, 0);
      balances.entries.push(newBalance);
      return balances.entries[balances.entries.length - 1];
    }

    function getIssuanceEtherBalance(uint256 issuanceId) private returns (Balance.Data storage) {
      Balances.Data storage balances = _issuanceBalances[issuanceId];
      for (uint i = 0; i < balances.entries.length; i++) {
        if (balances.entries[i].isEther) {
          return balances.entries[i];
        }
      }
      Balance.Data memory newBalance = Balance.Data(true, address(0x0), 0);
      balances.entries.push(newBalance);
      return balances.entries[balances.entries.length - 1];
    }

    function getIssuanceTokenBalance(uint256 issuanceId, address tokenAddress) private returns (Balance.Data storage balance) {
      Balances.Data storage balances = _issuanceBalances[issuanceId];
      for (uint i = 0; i < balances.entries.length; i++) {
        if (balances.entries[i].tokenAddress == tokenAddress) {
          balance = balances.entries[i];
          return balance;
        }
      }
      Balance.Data memory newBalance = Balance.Data(false, tokenAddress, 0);
      balances.entries.push(newBalance);
      return balances.entries[balances.entries.length - 1];
    }
}
