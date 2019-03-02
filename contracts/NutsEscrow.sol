pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/ownership/Secondary.sol";
import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract NutsEscrow is Secondary {
    using SafeMath for uint256;

    event EtherDeposited(address indexed payee, uint256 amount);
    event EtherWithdrawn(address indexed payee, uint256 amount);
    event TokenDeposited(address indexed payee, address indexed token, uint256 amount);
    event TokenWithdrawn(address indexed payee, address indexed token, uint256 amount);
    event EtherTransfered(address indexed payee, string indexed insurance_id, bool indexed fromIssuance, uint256 amount);

    mapping(address => uint256) private _etherBalance;                          // Balance of Ether deposited by user
    mapping(address => mapping(address => uint256)) private _tokenBalance;      // Balance of token deposited by user
    mapping(uint256 => uint256) private _issuanceEther;                          // Balance of Ether withheld by issuance
    mapping(uint256 => mapping(address => uint256)) private _issuanceTokens;     // Balance of token withheld by issuance

    /**
        API for users to deposit and withdraw Ether
     */
    function balanceOf() public view returns (uint256) {
        return _etherBalance[msg.sender];
    }

    function deposit() public payable {
        uint256 amount = msg.value;
        _etherBalance[msg.sender] = _etherBalance[msg.sender].add(amount);

        emit EtherDeposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        require(_etherBalance[msg.sender] >= amount, "Insufficial ether balance to withdraw");
        _etherBalance[msg.sender] = _etherBalance[msg.sender].sub(amount);

        msg.sender.transfer(amount);

        emit EtherWithdrawn(msg.sender, amount);
    }

    /**
        API for users to deposit and withdraw ERC20 token
     */
    function tokenBalanceOf(ERC20 token) public view returns (uint256) {
        return _tokenBalance[msg.sender][address(token)];
    }

    function depositToken(ERC20 token, uint256 amount) public {
        _tokenBalance[msg.sender][address(token)] = _tokenBalance[msg.sender][address(token)].add(amount);
        require(token.transferFrom(msg.sender, address(this), amount), "Insufficient balance to deposit");

        emit TokenDeposited(msg.sender, address(token), amount);
    }

    function withdrawToken(ERC20 token, uint256 amount) public {
        _tokenBalance[msg.sender][address(token)] = _tokenBalance[msg.sender][address(token)].sub(amount);
        require(token.transfer(msg.sender, amount), "Insufficient balance to withdraw");

        emit TokenWithdrawn(msg.sender, address(token), amount);
    }

    /**
        API used by NUTS platform to hold tokens for issuance
     */

    function balanceOfIssuance(uint256 issuance_id) public view onlyPrimary returns (uint256) {
        return _issuanceEther[issuance_id];
    }

    function transferToIssuance(address payee, uint256 issuance_id, uint256 amount) public onlyPrimary {
        require(_etherBalance[payee] >= amount, "Insufficient Ether balance");
        _etherBalance[payee] = _etherBalance[payee].sub(amount);
        _issuanceEther[issuance_id] = _issuanceEther[issuance_id].add(amount);
    }

    function transferFromIssuance(address payee, uint256 issuance_id, uint256 amount) public onlyPrimary {
        require(_issuanceEther[issuance_id] >= amount, "Insufficient Ether balance");
        _issuanceEther[issuance_id] = _issuanceEther[issuance_id].sub(amount);
        _etherBalance[payee] = _etherBalance[payee].add(amount);
    }

    function tokenBalanceOfIssuance(uint256 issuance_id, ERC20 token) public view onlyPrimary returns (uint256) {
        return _issuanceTokens[issuance_id][address(token)];
    }

    function transferTokenToIssuance(address payee, uint256 issuance_id, ERC20 token, uint256 amount) public onlyPrimary {
        require(_tokenBalance[payee][address(token)] >= amount, "Inssufficient token balance");
        _tokenBalance[payee][address(token)] = _tokenBalance[payee][address(token)].sub(amount);
        _issuanceTokens[issuance_id][address(token)] = _issuanceTokens[issuance_id][address(token)].add(amount);
    }

    function transferTokenFromIssuance(address payee, uint256 issuance_id, ERC20 token, uint256 amount) public onlyPrimary {
        require(_issuanceTokens[issuance_id][address(token)] >= amount, "Insufficient token balance");
        _tokenBalance[payee][address(token)] = _tokenBalance[payee][address(token)].add(amount);
        _issuanceTokens[issuance_id][address(token)] = _issuanceTokens[issuance_id][address(token)].sub(amount);
    }
}