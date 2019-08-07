pragma solidity ^0.5.0;

interface PriceOracleInterface {

    /**
     * @dev Get the price of an ERC20 token.
     * @param tokenAddress The address of the ERC20 token.
     * @return The price in ETH scaled by 10**18, i.e. in wei.
     */
    function getTokenPrice(address tokenAddress) external view returns (uint256);
}