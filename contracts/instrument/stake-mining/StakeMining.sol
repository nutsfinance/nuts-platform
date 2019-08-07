pragma solidity ^0.5.0;

import "../../lib/math/SafeMath.sol";
import "../../lib/util/StringUtil.sol";
import "../../Instrument.sol";
import "../../IMintable.sol";
import "./StakeMiningInfo.sol";
import "./PriceOracleInterface.sol";

/**
 * @title A stake mining financial instrument.
 */
contract StakeMining is Instrument {

    event Minted(uint256 indexed issuanceId, address indexed staker, uint256 amount);

    using SafeMath for uint256;
    using StakeMiningParameters for StakeMiningParameters.Data;
    using StakeMiningProperties for StakeMiningProperties.Data;

    uint constant PERCENTAGE_DECIMALS = 4;
    uint constant INDEX_NOT_FOUND = uint(-1);
    uint constant ETH_IN_WEI = 10**18;

    /**
     * @dev Create a new stake mininig issuance
     * @param issuanceId The id of the issuance
     * @param sellerAddress The address of the seller who creates this issuance
     * @param sellerParameters The custom parameters to the newly created issuance
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function createIssuance(uint256 issuanceId, address sellerAddress, string memory sellerParameters)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory /** transfers */) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(sellerAddress != address(0x0), "Seller address must be set.");

        // Parse parameters
        StakeMiningParameters.Data memory parameters = StakeMiningParameters.decode(bytes(sellerParameters));

        // Validate parameters
        require(parameters.supportedTokens.length > 0 || parameters.supportETH, "Must support at least one token");
        require(parameters.mintedToken != address(0x0), "Minted token address must not be 0");
        require(parameters.startBlock > 0, "Start block must be greater than 0");
        require(parameters.endBlock > parameters.startBlock, "End block must be greater than start block");
        require(parameters.tokensPerBlock > 0, "Tokens per block must be greater than 0");
        require(parameters.priceOracle != address(0x0), "Price oracle address must be provided");

        // Set propertiess
        // Array size is one more than the supported tokens in order to hold ETH.
        StakeMiningProperties.Data memory stakeMiningProperties = StakeMiningProperties.Data({
          tokens: new address[](parameters.supportedTokens.length + 1),
          tokenSupported: new bool[](parameters.supportedTokens.length + 1),
          mintedToken: parameters.mintedToken,
          startBlock: parameters.startBlock,
          endBlock: parameters.endBlock,
          tokensPerBlock: parameters.tokensPerBlock,
          minimumDeposit: parameters.minimumDeposit,
          teamWallet: parameters.teamWallet,
          teamPercentage: parameters.teamPercentage,
          priceOracle: parameters.priceOracle,
          tokenTotals: new uint256[](parameters.supportedTokens.length + 1),
          tokenBalances: new TokenBalances.Data[](parameters.supportedTokens.length + 1)
        });

        // Initialize arrays
        // First element is ETH
        stakeMiningProperties.tokenSupported[0] = parameters.supportETH;
        for (uint i = 0; i < parameters.supportedTokens.length; i++) {
          stakeMiningProperties.tokens[i + 1] = parameters.supportedTokens[i];
          stakeMiningProperties.tokenSupported[i + 1] = true;
        }

        // Change to Initiated state
        updatedState = IssuanceStates.Initiated;

        // Persist the propertiess
        updatedProperties = string(stakeMiningProperties.encode());
    }

    /**
     * @dev Engage is not supported in stake mining.
     */
    function engage(uint256 /** issuanceId */, IssuanceStates /** state */, string memory /** properties */,
        string memory /** balances */, address /** buyerAddress */ , string memory /**buyerParameters */)
        public returns (IssuanceStates /** updatedState */ , string memory /** updatedProperties */, string memory /** transfers */) {
        revert('Engagement is not supported in stake mining.');
    }

    /**
     * @dev Buyer/Seller has made an Ether transfer to the issuance
     * @param issuanceId The id of the issuance
     * @param properties The current properties of the issuance
     * @param balances The current balance of the issuance
     * @param fromAddress The address of the Ether sender
     * @param amount The amount of Ether transfered
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processDeposit(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, address fromAddress, uint256 amount)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory /** transfers */) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(properties).length > 0, "Properties must be set.");
        require(fromAddress != address(0x0), "Transferer address must be set.");
        require(amount > 0, "Transfer amount must be greater than 0.");

        // Load properties
        StakeMiningProperties.Data memory stakeMiningProperties = StakeMiningProperties.decode(bytes(properties));
        // Validate whether ETH is supported
        require(stakeMiningProperties.tokenSupported[0], "ETH is not supported");

        // Mint tokens should take place before transfer
        mintTokens(issuanceId, stakeMiningProperties);
    }

    /**
     * @dev Buyer/Seller has made an ERC20 token transfer to the issuance
     * @param issuanceId The id of the issuance
     * @param properties The current properties of the issuance
     * @param balances The current balance of the issuance
     * @param fromAddress The address of the ERC20 token sender
     * @param tokenAddress The address of the ERC20 token
     * @param amount The amount of ERC20 token transfered
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processTokenDeposit(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, address fromAddress, address tokenAddress, uint256 amount)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(properties).length > 0, "Properties must be set.");
        require(fromAddress != address(0x0), "Transferer address must be set.");
        require(tokenAddress != address(0x0), "Transferred token address must be set.");
        require(amount > 0, "Transfer amount must be greater than 0.");

        // Load properties
        StakeMiningProperties.Data memory stakeMiningProperties = StakeMiningProperties.decode(bytes(properties));
        // Validate whether the token is supported
        uint256 tokenIndex = getTokenIndex(stakeMiningProperties.tokens, tokenAddress);
        require(tokenIndex != INDEX_NOT_FOUND, "ERC20 token is not supported.");

        // Mint tokens should take place before transfer
        mintTokens(issuanceId, stakeMiningProperties);
    }

    /**
     * @dev Process scheduled event
     * @param issuanceId The id of the issuance
     * @param properties The current properties of the issuance
     * @param balances The current balance of the issuance
     * @param eventName Name of the custom event, eventName of EventScheduled event
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processScheduledEvent(uint256 issuanceId, IssuanceStates state, string memory properties,
        string memory balances, string memory eventName, string memory /** eventPayload */)
        public returns (IssuanceStates updatedState, string memory updatedProperties, string memory transfers) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(properties).length > 0, "Properties must be set.");
        require(bytes(eventName).length > 0, "Event name must be set.");
    }

    /**
     * User-driven ETH withdraw is not supported in loan contract.
     */
    function processWithdraw(uint256 /** issuanceId */, IssuanceStates /** state */, string memory /** properties */,
        string memory /** balances */, address /** fromAddress */, uint256 /** amount */)
        public returns (IssuanceStates /** updatedState */, string memory /** updatedProperties */, string memory /** transfers */) {
        revert("User ETH withdraw unsupported");
    }

    /**
     * User-driven ERC20 token withdraw is not supported in loan contract.
     */
    function processTokenWithdraw(uint256 /** issuanceId */, IssuanceStates /** state */, string memory /** properties */,
        string memory /** balances */, address /** fromAddress */, address /** tokenAddress */, uint256 /** amount */)
        public returns (IssuanceStates /** updatedState */, string memory /** updatedProperties */, string memory /** transfers */) {
        revert("User ERC20 token withdraw unsupported");
    }

    /**
     * @dev Custom event is not supported in loan contract.
     */
    function processCustomEvent(uint256 /** issuanceId */, IssuanceStates /** state */, string memory /** properties */,
        string memory /** balances */, string memory /** eventName */, string memory /** eventPayload */)
        public returns (IssuanceStates /** updatedState */, string memory /** updatedProperties */, string memory /** transfers */) {
        revert("Custom evnet unsupported.");
    }

    /**
     * @dev Get the index of the token
     */
    function getTokenIndex(address[] memory tokens, address tokenAddress) private pure returns (uint256) {
      for (uint256 i = 0; i < tokens.length; i++) {
        if (tokens[i] == tokenAddress) {
          return i;
        }
      }

      return INDEX_NOT_FOUND;
    }

    function getAccountIndex(address[] memory accounts, address accountAddress) private pure returns (uint256) {
      for (uint256 j = 0; j < accounts.length; j++) {
        if (accounts[j] == accountAddress) {
          return j;
        }
      }

      return INDEX_NOT_FOUND;
    }

    /**
     * @dev Core function: This is the function to do the actual token minting.
     */
    function mintTokens(uint256 issuanceId, StakeMiningProperties.Data memory properties) private pure {
      // Check whether it's in the stake mininig period
      if (block.number < properties.startBlock || block.number > properties.endBlock) {
        return;
      }

      // Check whether the pool is empty
      bool poolEmpty = true;
      for (uint i = 0; i < properties.tokens.length; i++) {
        // If a token is supported and its total balance is non-zero, the pool is non empty
        if (properties.tokenSupported[i] && properties.tokenTotals[i] > 0) {
          poolEmpty = false;
          break;
        }
      }
      if (poolEmpty) {
        properties.lastMintBlock = block.number;
        return;
      }

      // Get the price for each token
      uint256[] memory tokenPrices = new uint256[](properties.tokens.length);
      // Price is in ETH, and
      tokenPrices[0] = 1;
      for (uint i = 1; i < properties.tokens.length; i++) {
        if (!properties.tokenSupported[i]) {
          continue;
        }
        tokenPrices[i] = PriceOracleInterface(properties.priceOracle).getTokenPrice(properties.tokens[i]);
      }

      // Calculate the amount of tokens to mint since last mint
      uint256 mintedAmount = (block.number - properties.lastMintBlock).mul(properties.tokensPerBlock);
      // If team wallet address is specified, mint to the team wallet address
      // with proportion specified in team percentage.
      if (properties.teamWallet != address(0x0)) {
          uint256 teamMintedAmount = mintedAmount.mul(properties.teamPercentage).div(PERCENTAGE_DECIMALS);
          IMintable(properties.mintedToken).mint(properties.teamWallet, teamMintedAmount);
          mintedAmount = mintedAmount.sub(teamMintedAmount);

          emit Minted(issuanceId, properties.teamWallet, teamMintedAmount);
      }

      // Calculate the total mining pool value
      uint256 totalBalance = 0;
      for (uint i = 0; i < properties.tokens.length; i++) {
        if (!properties.tokenSupported[i]) {
          continue;
        }
        totalBalance = totalBalance.add(properties.tokenTotals[i].mul(tokenPrices[i]));
      }
      // Calculate the total balance of each accounts
      uint256[] memory accountTotals = new uint256[](properties.accounts.length);
      for (uint i = 0; i < properties.tokens.length; i++) {
        // No need to check supported tokens
        if (!properties.tokenSupported[i]) {
          continue;
        }
        for (uint j = 0; j < properties.accounts.length; j++) {
          // Skip tokens with zero balance
          if (properties.accountBalances[i].balances[j] == 0) {
            continue;
          }
          accountTotals[j] = accountTotals[j].add(properties.accountBalances[i].balances[j].mul(tokenPrices[i]));
        }
      }
      // Mint for each account
      for (uint j = 0; j < properties.accounts.length; j++) {
        // Skip accounts with zero total balance
        if (accountTotals[j] == 0) {
          continue;
        }
        uint256 stakerMintedAmount = mintedAmount.mul(accountTotals[j]).div(totalBalance);
        IMintable(properties.mintedToken).mint(properties.accounts[j], stakerMintedAmount);

        emit Minted(issuanceId, properties.accounts[j], stakerMintedAmount);
      }
      properties.lastMintBlock = block.number;
    }
}
