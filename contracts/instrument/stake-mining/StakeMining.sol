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
    uint constant INITIAL_ARRAY_SIZE = 20;

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
          tokenBalances: new TokenBalances.Data[](parameters.supportedTokens.length + 1),
          accounts: new address[](INITIAL_ARRAY_SIZE),
          accountCount: 0,
          lastMintBlock: parameters.startBlock
        });

        // Initialize arrays
        // First element is ETH
        stakeMiningProperties.tokenSupported[0] = parameters.supportETH;
        stakeMiningProperties.tokenBalances[0].balances = new uint256[](INITIAL_ARRAY_SIZE);
        for (uint i = 0; i < parameters.supportedTokens.length; i++) {
          stakeMiningProperties.tokens[i + 1] = parameters.supportedTokens[i];
          stakeMiningProperties.tokenSupported[i + 1] = true;
          stakeMiningProperties.tokenBalances[i + 1].balances = new uint256[](INITIAL_ARRAY_SIZE);
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
     * @param fromAddress The address of the Ether sender
     * @param amount The amount of Ether transfered
     * @return updatedProperties The updated issuance properties
     */
    function processDeposit(uint256 issuanceId, IssuanceStates /** state */, string memory properties,
        string memory /** balances */, address fromAddress, uint256 amount)
        public returns (IssuanceStates /** updatedState */, string memory updatedProperties, string memory /** transfers */) {
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

        uint256 accountIndex = getAccountIndex(stakeMiningProperties.accounts, stakeMiningProperties.accountCount, fromAddress);
        if (accountIndex != INDEX_NOT_FOUND) {
            // The account is already in the list
            stakeMiningProperties.tokenBalances[0].balances[accountIndex] = stakeMiningProperties.tokenBalances[0].balances[accountIndex].add(amount);
        } else {
            // Check whether we have reached the limit of the pre-allocated array
            if (stakeMiningProperties.accountCount == stakeMiningProperties.accounts.length) {
                extendAccounts(stakeMiningProperties);
            }
            stakeMiningProperties.tokenBalances[0].balances[stakeMiningProperties.accountCount] = stakeMiningProperties
                .tokenBalances[0].balances[stakeMiningProperties.accountCount].add(amount);
            stakeMiningProperties.accountCount++;
        }

        // Update the properties
        updatedProperties = string(stakeMiningProperties.encode());
    }

    /**
     * @dev Buyer/Seller has made an ERC20 token transfer to the issuance
     * @param issuanceId The id of the issuance
     * @param properties The current properties of the issuance
     * @param fromAddress The address of the ERC20 token sender
     * @param tokenAddress The address of the ERC20 token
     * @param amount The amount of ERC20 token transfered
     * @return updatedProperties The updated issuance properties
     */
    function processTokenDeposit(uint256 issuanceId, IssuanceStates /** state */, string memory properties,
        string memory /** balances */, address fromAddress, address tokenAddress, uint256 amount)
        public returns (IssuanceStates /** updatedState */, string memory updatedProperties, string memory /** transfers */) {
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

        uint256 accountIndex = getAccountIndex(stakeMiningProperties.accounts, stakeMiningProperties.accountCount, fromAddress);
        if (accountIndex != INDEX_NOT_FOUND) {
            // The account is already in the list
            stakeMiningProperties.tokenBalances[0].balances[accountIndex] = stakeMiningProperties.tokenBalances[0].balances[accountIndex].add(amount);
        } else {
            // Check whether we have reached the limit of the pre-allocated array
            if (stakeMiningProperties.accountCount == stakeMiningProperties.accounts.length) {
                extendAccounts(stakeMiningProperties);
            }
            stakeMiningProperties.tokenBalances[tokenIndex].balances[stakeMiningProperties.accountCount] = stakeMiningProperties
                .tokenBalances[tokenIndex].balances[stakeMiningProperties.accountCount].add(amount);
            stakeMiningProperties.accountCount++;
        }

        // Update the properties
        updatedProperties = string(stakeMiningProperties.encode());
    }

    /**
     * @dev Process scheduled event
     * @param issuanceId The id of the issuance
     * @param properties The current properties of the issuance
     * @param eventName Name of the custom event, eventName of EventScheduled event
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processScheduledEvent(uint256 issuanceId, IssuanceStates /** state */, string memory properties,
        string memory /** balances */, string memory eventName, string memory /** eventPayload */)
        public returns (IssuanceStates /** updatedState */, string memory /** updatedProperties */, string memory /** transfers */) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(properties).length > 0, "Properties must be set.");
        require(bytes(eventName).length > 0, "Event name must be set.");
    }

    /**
     * @dev Buyer/Seller has made an Ether withdraw from the issuance
     * @param issuanceId The id of the issuance
     * @param properties The current properties of the issuance
     * @param toAddress The address of the Ether receiver
     * @param amount The amount of Ether transfered
     * @return updatedState The new state of the issuance.
     * @return updatedProperties The updated issuance properties
     */
   function processWithdraw(uint256 issuanceId, IssuanceStates /** state*/, string memory properties,
        string memory /** balances */, address toAddress, uint256 amount)
        public returns (IssuanceStates /** updatedState */, string memory updatedProperties, string memory /** transers */) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(properties).length > 0, "Properties must be set.");
        require(toAddress != address(0x0), "Receiver address must be set.");
        require(amount > 0, "Withdraw amount must be greater than 0.");

        // Load properties
        StakeMiningProperties.Data memory stakeMiningProperties = StakeMiningProperties.decode(bytes(properties));
        // Validate whether ETH is supported
        require(stakeMiningProperties.tokenSupported[0], "ETH is not supported");
        uint256 accountIndex = getAccountIndex(stakeMiningProperties.accounts, stakeMiningProperties.accountCount, toAddress);
        require(accountIndex != INDEX_NOT_FOUND, "Receiver address does not exist in mining pool");
        require(stakeMiningProperties.tokenBalances[0].balances[accountIndex] >= amount, "Insufficient balance to withdraw");

        // Mint tokens should take place before transfer
        mintTokens(issuanceId, stakeMiningProperties);

        stakeMiningProperties.tokenBalances[0].balances[accountIndex] = stakeMiningProperties.tokenBalances[0]
            .balances[accountIndex].sub(amount);

        // Update the properties
        updatedProperties = string(stakeMiningProperties.encode());
    }

    /**
     * @dev Buyer/Seller has made an ERC20 token withdraw from the issuance
     * @param issuanceId The id of the issuance
     * @param properties The current properties of the issuance
     * @param toAddress The address of the ERC20 token receiver
     * @param tokenAddress The address of the ERC20 token
     * @param amount The amount of ERC20 token transfered
     * @return updatedState The new state of the issuance.
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processTokenWithdraw(uint256 issuanceId, IssuanceStates /** state */, string memory properties,
        string memory /** balances */, address toAddress, address tokenAddress, uint256 amount)
        public returns (IssuanceStates /** updatedState */, string memory updatedProperties, string memory /** transfers */) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(properties).length > 0, "Properties must be set.");
        require(toAddress != address(0x0), "Receiver address must be set.");
        require(tokenAddress != address(0x0), "Transferred token address must be set.");
        require(amount > 0, "Withdraw amount must be greater than 0.");

        // Load properties
        StakeMiningProperties.Data memory stakeMiningProperties = StakeMiningProperties.decode(bytes(properties));
        // Validate whether the token is supported
        uint256 tokenIndex = getTokenIndex(stakeMiningProperties.tokens, tokenAddress);
        require(tokenIndex != INDEX_NOT_FOUND, "ERC20 token is not supported.");
        uint256 accountIndex = getAccountIndex(stakeMiningProperties.accounts, stakeMiningProperties.accountCount, toAddress);
        require(accountIndex != INDEX_NOT_FOUND, "Receiver address does not exist in mining pool");
        require(stakeMiningProperties.tokenBalances[tokenIndex].balances[accountIndex] >= amount, "Insufficient balance to withdraw");

        // Mint tokens should take place before transfer
        mintTokens(issuanceId, stakeMiningProperties);

        stakeMiningProperties.tokenBalances[tokenIndex].balances[accountIndex] = stakeMiningProperties.tokenBalances[tokenIndex]
            .balances[accountIndex].sub(amount);

        // Update the properties
        updatedProperties = string(stakeMiningProperties.encode());
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

    /**
     * @dev Get the index of the account address
     */
    function getAccountIndex(address[] memory accounts, uint256 accountCount, address accountAddress) private pure returns (uint256) {
      for (uint256 j = 0; j < accountCount; j++) {
        if (accounts[j] == accountAddress) {
          return j;
        }
      }

      return INDEX_NOT_FOUND;
    }

    /**
     * @dev Doubling the size of the pre-allocated accounts array.
     */
    function extendAccounts(StakeMiningProperties.Data memory properties) private pure {
        uint256 accountCount = properties.accountCount;
        // Extend the accounts array
        address[] memory newAccounts = new address[](accountCount * 2);
        for (uint j = 0; j < accountCount; j++) {
            newAccounts[j] = properties.accounts[j];
        }
        properties.accounts = newAccounts;

        // Extend the token balances array
        for (uint i = 0; i < properties.tokens.length; i++) {
            uint256[] memory newBalances = new uint256[](accountCount * 2);
            for (uint j = 0; j < accountCount; j++) {
                newBalances[j] = properties.tokenBalances[i].balances[j];
            }
            properties.tokenBalances[i].balances = newBalances;
        }
    }

    /**
     * @dev Core function: This is the function to do the actual token minting.
     */
    function mintTokens(uint256 issuanceId, StakeMiningProperties.Data memory properties) private {
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
      uint256[] memory accountTotals = new uint256[](properties.accountCount);
      for (uint i = 0; i < properties.tokens.length; i++) {
        // No need to check supported tokens
        if (!properties.tokenSupported[i]) {
          continue;
        }
        // The accounts array is pre-allocated so that accountCount is the actual count.
        for (uint j = 0; j < properties.accountCount; j++) {
          // Skip tokens with zero balance
          if (properties.tokenBalances[i].balances[j] == 0) {
            continue;
          }
          accountTotals[j] = accountTotals[j].add(properties.tokenBalances[i].balances[j].mul(tokenPrices[i]));
        }
      }
      // Mint for each account
      // The accounts array is pre-allocated so that accountCount is the actual count.
      for (uint j = 0; j < properties.accountCount; j++) {
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
