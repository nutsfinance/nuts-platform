pragma solidity ^0.5.0;

import "./TokenBalance.sol";
import "../node_modules/openzeppelin-solidity/contracts/access/roles/WhitelistAdminRole.sol";
import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

/**
 * @title Escrow for both user and issuance.
 * Tokens owned by issuance are alway locked in this escrow.
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
    mapping(address => uint256) private _etherBalance;                          // Balance of Ether deposited by user
    mapping(address => mapping(address => uint256)) private _tokenBalance;      // Balance of token deposited by user
    mapping(uint256 => Balances.Data) private _issuanceBalances;                // Balance of issuance
    /**
     * API for users to deposit and withdraw Ether
     */

    /**
     * @dev Get the current balance in the escrow
     * @return Current balance of the invoker
     */
    function balanceOf() public view returns (uint256) {
        return _etherBalance[msg.sender];
    }

    /**
     * @dev Deposits Ethers into the escrow
     */
    function deposit() public payable {
        uint256 amount = msg.value;
        _etherBalance[msg.sender] = _etherBalance[msg.sender].add(amount);

        emit EtherDeposited(msg.sender, amount);
    }

    /**
     * @dev Withdraw Ethers from the escrow
     * @param amount The amount of Ethers to withdraw
     */
    function withdraw(uint256 amount) public {
        require(_etherBalance[msg.sender] >= amount, "Insufficial ether balance to withdraw");
        _etherBalance[msg.sender] = _etherBalance[msg.sender].sub(amount);

        msg.sender.transfer(amount);

        emit EtherWithdrawn(msg.sender, amount);
    }

    /**
        API for users to deposit and withdraw ERC20 token
     */

    /**
     * @dev Get the balance of the requested ERC20 token in the escrow
     * @param token The ERC20 token to check balance
     * @return The balance
     */
    function tokenBalanceOf(ERC20 token) public view returns (uint256) {
        return _tokenBalance[msg.sender][address(token)];
    }

    /**
     * @dev Deposit ERC20 token to the escrow
     * @param token The ERC20 token to deposit
     * @param amount The amount to deposit
     */
    function depositToken(ERC20 token, uint256 amount) public {
        _tokenBalance[msg.sender][address(token)] = _tokenBalance[msg.sender][address(token)].add(amount);
        require(token.transferFrom(msg.sender, address(this), amount), "Insufficient balance to deposit");

        emit TokenDeposited(msg.sender, address(token), amount);
    }

    /**
     * @dev Withdraw ERC20 token from the escrow
     * @param token The ERC20 token to withdraw
     * @param amount The amount to withdraw
     */
    function withdrawToken(ERC20 token, uint256 amount) public {
        _tokenBalance[msg.sender][address(token)] = _tokenBalance[msg.sender][address(token)].sub(amount);
        require(token.transfer(msg.sender, amount), "Insufficient balance to withdraw");

        emit TokenWithdrawn(msg.sender, address(token), amount);
    }

    /**
        API used by NUTS platform to hold tokens for issuance
     */

    /**
     * @dev Get the Ether balance of an issuance in the escrow
     * @param issuanceId The id of the issuance
     * @return The Ether balance of the issuance in the escrow
     */
    function balanceOfIssuance(uint256 issuanceId) public view onlyWhitelistAdmin returns (uint256) {
        // return _issuanceEther[issuanceId];
        return getEtherBalance(issuanceId).amount;
    }

    /**
     * @dev Transfer Ethers from a seller/buyer to the issuance
     * @param payee The address of the seller/buyer
     * @param issuanceId The id of the issuance
     * @param amount The amount of Ether to transfer
     */
    function transferToIssuance(address payee, uint256 issuanceId, uint256 amount) public onlyWhitelistAdmin {
        // Subtract from the seller/buyer balance
        require(_etherBalance[payee] >= amount, "Insufficient Ether balance");
        _etherBalance[payee] = _etherBalance[payee].sub(amount);

        // Increase to the issuance balance
        Balance.Data storage balance = getEtherBalance(issuanceId);
        balance.amount = balance.amount.add(amount);
    }

    /**
     * @dev Transfer Ethers from an issuance to a seller/buyer
     * @param payee The address of the seller/buyer
     * @param issuanceId The id of the issuance
     * @param amount The amount of Ether to transfer
     */
    function transferFromIssuance(address payee, uint256 issuanceId, uint256 amount) public onlyWhitelistAdmin {
        // Subtract from the issuance balance
        Balance.Data storage balance = getEtherBalance(issuanceId);
        require(balance.amount >= amount, "Insufficient Ether balance");
        balance.amount = balance.amount.sub(amount);

        // Increase to the seller/buyer balance
        _etherBalance[payee] = _etherBalance[payee].add(amount);
    }

    /**
     * @dev Get the ERC20 token balance of an issuance in the escrow
     * @param issuanceId The id of the issuance
     * @param token The ERC20 token to check balance
     * @return The ERC20 token balance of the issuance in the escrow
     */
    function tokenBalanceOfIssuance(uint256 issuanceId, ERC20 token) public view onlyWhitelistAdmin returns (uint256) {
        return getTokenBalance(issuanceId, address(token)).amount;
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
        require(_tokenBalance[payee][address(token)] >= amount, "Inssufficient token balance");
        _tokenBalance[payee][address(token)] = _tokenBalance[payee][address(token)].sub(amount);

        // Increase to the issuance balance
        Balance.Data storage balance = getTokenBalance(issuanceId, address(token));
        balance.amount = balance.amount.add(amount);
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
        Balance.Data storage balance = getTokenBalance(issuanceId, address(token));
        require(balance.amount >= amount, "Insufficient token balance");
        balance.amount = balance.amount.sub(amount);

        // Increase to the seller/buyer balance
        _tokenBalance[payee][address(token)] = _tokenBalance[payee][address(token)].add(amount);
    }

    /**
     * @dev Get the balance information about all tokens of the issuance.
     * @param issuanceId The issuance id
     * @return The balance of all tokens about this issuance.
     */
    function getIssuanceBalance(uint256 issuanceId) public view onlyWhitelistAdmin returns (string memory) {
        return string(_issuanceBalances[issuanceId].encode());
    }

    /**
     * @dev Transfer the token balance from one issuance to another.
     * @param prevIssuanceId The id of the issuance from which the balance is transfereed.
     * @param newIssuanceId The id of the issuance to which the balance is transferred.
     */
    function transferBalance(uint256 prevIssuanceId, uint256 newIssuanceId) public onlyWhitelistAdmin {
        _issuanceBalances[newIssuanceId].balances.length = 0;
        for (uint i = 0; i < _issuanceBalances[prevIssuanceId].balances.length; i++) {
            _issuanceBalances[newIssuanceId].balances.push(_issuanceBalances[prevIssuanceId].balances[i]);
        }
        _issuanceBalances[prevIssuanceId].balances.length = 0;
    }

    function getEtherBalance(uint256 issuanceId) private returns (Balance.Data storage) {
      Balances.Data storage balances = _issuanceBalances[issuanceId];
      for (uint i = 0; i < balances.balances.length; i++) {
        if (balances.balances[i].isEther) {
          return balances.balances[i];
        }
      }
      Balance.Data memory newBalance = Balance.Data(true, address(0x0), 0);
      balances.balances.push(newBalance);
      return newBalance;
    }

    function getTokenBalance(uint256 issuanceId, address tokenAddress) private returns (Balance.Data storage balance) {
      Balances.Data storage balances = _issuanceBalances[issuanceId];
      for (uint i = 0; i < balances.balances.length; i++) {
        if (balances.balances[i].tokenAddress == tokenAddress) {
          balance = balances.balances[i];
          return balance;
        }
      }
      balance = Balance.Data(true, tokenAddress, 0);
      balances.balances.push(balance);
    }
}
