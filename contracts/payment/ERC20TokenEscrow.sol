pragma solidity ^0.5.2;

import "node_modules/openzeppelin-solidity/contracts/ownership/Secondary.sol";
import "node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract ERC20TokenEscrow is Secondary {
    using SafeMath for uint256;

    event Deposited(address indexed payee, address indexed token, uint256 amount);
    event Withdrawn(address indexed payee, address indexed token, uint256 amount);

    mapping(address => mapping(address => uint256)) internal _tokenBalance;

    function balanceOf(address payee, ERC20 token) public view returns (uint256) {
        return _tokenBalance[payee][token];
    }

    function deposit(address payee, ERC20 token, uint256 amount) public {
        _tokenBalance[msg.sender][token].add(amount);
        require(token.transferFrom(msg.sender, this, amount), "Insufficient balance to deposit");

        emit Deposited(payee, token, amount);
    }

    function withdraw(address payee, ERC20 token, uint256 amount) public {
        _tokenBalance[msg.sender][token].sub(amount);
        require(token.transferFrom(this, msg.sender, amount), "Insufficient balance to withdraw");

        emit Withdrawn(payee, token, amount);
    }
}