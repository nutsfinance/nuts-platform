pragma solidity ^0.5.2;

import "node_modules/openzeppelin-solidity/contracts/ownership/Secondary.sol";
import "node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract NutsEscrow is Secondary {
    using SafeMath for uint256;

    event EtherDeposited(address indexed, uint256 amount);
    event EtherWithdrawn(address indexed, uint256 amount);
    event TokenDeposited(address indexed payee, address indexed token, uint256 amount);
    event TokenWithdrawn(address indexed payee, address indexed token, uint256 amount);

    mapping(address => uint256) private _etherBalance;                          // Balance of Ether deposited by user
    mapping(address => mapping(address => uint256)) private _tokenBalance;      // Balance of token deposited by user
    mapping(string => uint256) private _issuanceEther;                          // Balance of Ether withheld by issuance
    mapping(string => mapping(address => uint256)) private _issuanceTokens;     // Balance of token withheld by issuance

    /**
        API for users to deposit and withdraw Ether
     */
    function balanceOf() public view returns (uint256) {
        return _etherBalance[msg.sender];
    }

    function deposit() public payable {
        uint256 amount = msg.value;
        _etherBalance[msg.sender].add(amount);

        emit EtherDeposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        require(_etherBalance[msg.sender] >= amount, "Insufficial ether balance to withdraw");
        _etherBalance[msg.sender].sub(amount);

        msg.sender.transfer(amount);

        emit EtherWithdrawn(msg.sender, amount);
    }

    /**
        API for users to deposit and withdraw ERC20 token
     */
    function tokenBalanceOf(ERC20 token) public view returns (uint256) {
        return _tokenBalance[msg.sender][token];
    }

    function depositToken(ERC20 token, uint256 amount) public {
        _tokenBalance[msg.sender][token].add(amount);
        require(token.transferFrom(msg.sender, this, amount), "Insufficient balance to deposit");

        emit TokenDeposited(msg.sender, token, amount);
    }

    function withdrawToken(ERC20 token, uint256 amount) public {
        _tokenBalance[msg.sender][token].sub(amount);
        require(token.transferFrom(this, msg.sender, amount), "Insufficient balance to withdraw");

        emit Withdrawn(msg.sender, token, amount);
    }

    /**
        API used by NUTS platform to hold tokens for issuance
     */

    function transferToIssuance(address payee, string issuance_id, uint256 amount) public onlyPrimary {
        require(_etherBalance[payee] >= amount, "Insufficient Ether balance");
        _etherBalance[payee].sub(amount);
        _issuanceEther[issuance_id].add(amount);
    }

    function transferFromIssuance(address payee, string issuance_id, uint256 amount) public onlyPrimary {
        require(_issuanceEther[issuance_id] >= amount, "Insufficient Ether balance");
        _issuanceEther[issuance_id].sub(amount);
        _etherBalance[payee].add(amount);
    }

    function transferTokenToIssuance(address payee, string issuance_id, ERC20 token, uint256 amount) public onlyPrimary {
        require(_tokenBalance[payee][token] >= amount, "Inssufficient token balance");
        _tokenBalance[payee][token].sub(amount);
        _issuanceTokens[issuance_id][token].add(amount);
    }

    function transferTokenFromIssuance(address payee, string issuance_id, ERC20 token, uint256 amount) public onlyPrimary {
        require(_issuanceTokens[issuance_id][token] >= amount, "Insufficient token balance");
        _issuanceTokens[issuance_id][token].sub(amount);
        _tokenBalance[payee][token].add(amount);
    }
}