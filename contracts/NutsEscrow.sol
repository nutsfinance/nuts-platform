pragma solidity ^0.5.0;

// Enable the ABI v2 Coder
pragma experimental ABIEncoderV2;

import "./common/payment/Balance.sol";
import "../node_modules/openzeppelin-solidity/contracts/access/roles/WhitelistAdminRole.sol";
import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract NutsEscrow is WhitelistAdminRole {
    using SafeMath for uint256;
    using Balance for Balance.Balances;

    event EtherDeposited(address indexed payee, uint256 amount);
    event EtherWithdrawn(address indexed payee, uint256 amount);
    event TokenDeposited(address indexed payee, address indexed token, uint256 amount);
    event TokenWithdrawn(address indexed payee, address indexed token, uint256 amount);
    event EtherTransfered(address indexed payee, string indexed insurance_id, bool indexed fromIssuance, uint256 amount);

    mapping(address => uint256) private _etherBalance;                          // Balance of Ether deposited by user
    mapping(address => mapping(address => uint256)) private _tokenBalance;      // Balance of token deposited by user
    mapping(uint256 => Balance.Balances) private _issuanceBalances;             // Balance of issuance
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
        return _issuanceBalances[issuanceId].getEtherBalance();
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
        uint balance = _issuanceBalances[issuanceId].getEtherBalance();
        _issuanceBalances[issuanceId].setEtherBalance(balance.add(amount));
    }

    /**
     * @dev Transfer Ethers from an issuance to a seller/buyer
     * @param payee The address of the seller/buyer
     * @param issuanceId The id of the issuance
     * @param amount The amount of Ether to transfer
     */
    function transferFromIssuance(address payee, uint256 issuanceId, uint256 amount) public onlyWhitelistAdmin {
        // Subtract from the issuance balance
        uint balance = _issuanceBalances[issuanceId].getEtherBalance();
        require(balance >= amount, "Insufficient Ether balance");
        _issuanceBalances[issuanceId].setEtherBalance(balance.sub(amount));

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
        return _issuanceBalances[issuanceId].getTokenBalance(address(token));
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
        uint balance = _issuanceBalances[issuanceId].getTokenBalance(address(token));
        _issuanceBalances[issuanceId].setTokenBalance(address(token), balance.add(amount));
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
        uint balance = _issuanceBalances[issuanceId].getTokenBalance(address(token));
        require(balance >= amount, "Insufficient token balance");
        _issuanceBalances[issuanceId].setTokenBalance(address(token), balance.sub(amount));
        
        // Increase to the seller/buyer balance
        _tokenBalance[payee][address(token)] = _tokenBalance[payee][address(token)].add(amount);
    }

    /**
     * @dev Return the serialized repreentation of the issuance balance
     * @param issuanceId The issuance id
     * @return The serialized balance
     */
    function getIssuanceBalance(uint256 issuanceId) public view onlyWhitelistAdmin returns (Balance.Balances memory) {
        return _issuanceBalances[issuanceId];
    }
}