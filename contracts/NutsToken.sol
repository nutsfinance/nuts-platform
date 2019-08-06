pragma solidity ^0.5.0;

import "./ERC20CappedMintable.sol";

contract NutsToken is ERC20CappedMintable {
    string public constant name = 'NUTS Token';
    string public constant symbol = 'NUTS';
    uint8 public constant decimals = 18;
    uint256 public constant cap = 200000000 * 10 ** uint256(decimals);

    constructor() ERC20CappedMintable(cap) public {
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
    
    /**
     * @dev See {ERC20-_burnFrom}.
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}