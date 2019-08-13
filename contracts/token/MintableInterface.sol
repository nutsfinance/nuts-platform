pragma solidity ^0.5.0;

/**
 * @dev Interface for `ERC20` that adds `mint` API.
 *
 * Credit: https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC20/ERC20Mintable.sol
 */
interface MintableInterface {
    /**
     * @dev See `ERC20._mint`.
     */
    function mint(address account, uint256 amount) external returns (bool);
}