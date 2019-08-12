pragma solidity ^0.5.0;

import "../../lib/math/SafeMath.sol";
import "../../lib/util/StringUtil.sol";
import "../../Instrument.sol";
import "../../IMintable.sol";
import "../../UnifiedStorage.sol";
import "./StakeMiningInfo.sol";
import "./PriceOracleInterface.sol";

/**
 * @title A stake mining financial instrument.
 */
contract StakeMining is Instrument {

    event Minted(uint256 indexed issuanceId, address indexed staker, uint256 amount);

    using SafeMath for uint256;
    using StringUtil for string;
    using StakeMiningParameters for StakeMiningParameters.Data;
    using StakeMiningProperties for StakeMiningProperties.Data;
    using Account for Account.Data;

    string constant PROPERTIES_KEY = "propertoes";
    string constant ACCOUNTS_KEY_PREFIX = "account_";
    uint constant PERCENTAGE_DECIMALS = 4;
    uint constant INDEX_NOT_FOUND = uint(-1);
    uint constant ETH_IN_WEI = 10**18;
    address constant ETH_ADDRESS = address(0x0);

    /**
     * @dev Create a new stake mininig issuance
     * @param issuanceId The id of the issuance
     * @param unifiedStorage The storage contract created for this issuance
     * @param sellerAddress The address of the seller who creates this issuance
     * @param sellerParameters The custom parameters to the newly created issuance
     * @return updatedState The updated issuance state
     * @return transfers The transfers to perform after the invocation
     */
    function createIssuance(uint256 issuanceId, UnifiedStorage unifiedStorage, address sellerAddress, string memory sellerParameters)
        public returns (IssuanceStates updatedState, string memory /** transfers */) {
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
          minimumBalance: parameters.minimumBalance,
          teamWallet: parameters.teamWallet,
          teamPercentage: parameters.teamPercentage,
          priceOracle: parameters.priceOracle,
          accountCount: 0,
          lastMintBlock: parameters.startBlock
        });

        // Initialize arrays
        // First element is ETH
        stakeMiningProperties.tokens[0] = ETH_ADDRESS;
        stakeMiningProperties.tokenSupported[0] = parameters.supportETH;
        for (uint i = 0; i < parameters.supportedTokens.length; i++) {
          stakeMiningProperties.tokens[i + 1] = parameters.supportedTokens[i];
          stakeMiningProperties.tokenSupported[i + 1] = true;
        }

        // Change to Initiated state
        updatedState = IssuanceStates.Initiated;

        // Persist the propertiess
        unifiedStorage.setString(PROPERTIES_KEY, string(stakeMiningProperties.encode()));
    }

    /**
     * @dev Engage is not supported in stake mining.
     */
    function engage(uint256 /** issuanceId */, IssuanceStates /** state */, UnifiedStorage /** unifiedStorage */,
        string memory /** balances */, address /** buyerAddress */ , string memory /**buyerParameters */)
        public returns (IssuanceStates /** updatedState */ , string memory /** transfers */) {
        revert('Engagement is not supported in stake mining.');
    }

    /**
     * @dev Buyer/Seller has made an Ether transfer to the issuance
     * @param issuanceId The id of the issuance
     * @param unifiedStorage The storage contract created for this issuance
     * @param fromAddress The address of the Ether sender
     * @param amount The amount of Ether transfered
     */
    function processDeposit(uint256 issuanceId, IssuanceStates /** state */, UnifiedStorage unifiedStorage,
        string memory /** balances */, address fromAddress, uint256 amount)
        public returns (IssuanceStates /** updatedState */, string memory /** transfers */) {
        
        handleTokenDeposit(issuanceId, unifiedStorage, fromAddress, ETH_ADDRESS, amount);
    }

    /**
     * @dev Buyer/Seller has made an ERC20 token transfer to the issuance
     * @param issuanceId The id of the issuance
     * @param unifiedStorage The storage contract created for this issuance
     * @param fromAddress The address of the ERC20 token sender
     * @param tokenAddress The address of the ERC20 token
     * @param amount The amount of ERC20 token transfered
     */
    function processTokenDeposit(uint256 issuanceId, IssuanceStates /** state */, UnifiedStorage unifiedStorage,
        string memory /** balances */, address fromAddress, address tokenAddress, uint256 amount)
        public returns (IssuanceStates /** updatedState */, string memory /** transfers */) {

        handleTokenDeposit(issuanceId, unifiedStorage, fromAddress, tokenAddress, amount);
    }

    /**
     * @dev Buyer/Seller has made an ERC20 token transfer to the issuance
     * @param issuanceId The id of the issuance
     * @param unifiedStorage The storage contract created for this issuance
     * @param fromAddress The address of the ERC20 token sender
     * @param tokenAddress The address of the ERC20 token
     * @param amount The amount of ERC20 token transfered
     */
    function handleTokenDeposit(uint256 issuanceId, UnifiedStorage unifiedStorage,
        address fromAddress, address tokenAddress, uint256 amount) private {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(fromAddress != address(0x0), "Transferer address must be set.");
        require(tokenAddress != address(0x0), "Transferred token address must be set.");
        require(amount > 0, "Transfer amount must be greater than 0.");
        bytes memory properties = bytes(unifiedStorage.getString(PROPERTIES_KEY));
        require(properties.length > 0, "Properties must be set.");

        // Load properties
        StakeMiningProperties.Data memory stakeMiningProperties = StakeMiningProperties.decode(properties);
        // Validate whether the token is supported
        uint256 tokenIndex = getTokenIndex(stakeMiningProperties.tokens, tokenAddress);
        require(tokenIndex != INDEX_NOT_FOUND, "ERC20 token is not supported.");

        // Load all account addresses
        Account.Data[] memory accounts = new Account.Data[](stakeMiningProperties.accountCount);
        uint256 accountIndex = INDEX_NOT_FOUND;
        uint256[] memory tokenTotals = new uint256[](stakeMiningProperties.tokens.length);
        for (uint i = 0; i < stakeMiningProperties.accountCount; i++) {
          accounts[i] = Account.decode(bytes(unifiedStorage.getString(ACCOUNTS_KEY_PREFIX.concat(i))));
          for (uint j = 0; j < accounts[i].balances.length; j++) {
            tokenTotals[j] = tokenTotals[j].add(accounts[i].balances[j]);
          }
          if (accounts[i].accountAddress == fromAddress) {
            accountIndex = i;
          }
        }

        // Mint tokens should take place before transfer
        mintTokens(issuanceId, stakeMiningProperties, accounts, tokenTotals);

        // Update the account balances
        if (accountIndex != INDEX_NOT_FOUND) {
            // The account is already in the list
            // Special case: The balances array length is smaller than the token index
            // This is possible if a new token is added
            if (accounts[accountIndex].balances.length < stakeMiningProperties.tokens.length) {
              uint256[] memory newBalances = new uint256[](stakeMiningProperties.tokens.length);
              for (uint j = 0; j < stakeMiningProperties.tokens.length; j++) {
                newBalances[j] = accounts[accountIndex].balances[j];
              }
              accounts[accountIndex].balances = newBalances;
            }

            // Update the account information in unified storage
            accounts[accountIndex].balances[tokenIndex] = accounts[accountIndex].balances[tokenIndex].add(amount);
            unifiedStorage.setString(ACCOUNTS_KEY_PREFIX.concat(accountIndex), string(accounts[accountIndex].encode()));
        } else {
            // This is a new account
            // Add the account information in unified storage
            Account.Data memory newAccount = Account.Data({
              accountAddress: fromAddress,
              balances: new uint256[](stakeMiningProperties.tokens.length)
            });
            newAccount.balances[tokenIndex] = amount;
            unifiedStorage.setString(ACCOUNTS_KEY_PREFIX.concat(accountIndex), string(newAccount.encode()));

            // Update the account count
            stakeMiningProperties.accountCount++;
        }

        // Persist the propertiess
        unifiedStorage.setString(PROPERTIES_KEY, string(stakeMiningProperties.encode()));
    }

    /**
     * @dev Process scheduled event
     * @param issuanceId The id of the issuance
     * @param unifiedStorage The storage contract created for this issuance
     * @param eventName Name of the custom event, eventName of EventScheduled event
     * @return updatedProperties The updated issuance properties
     * @return transfers The transfers to perform after the invocation
     */
    function processScheduledEvent(uint256 issuanceId, IssuanceStates /** state */, UnifiedStorage unifiedStorage,
        string memory /** balances */, string memory eventName, string memory /** eventPayload */)
        public returns (IssuanceStates /** updatedState */, string memory /** transfers */) {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(bytes(eventName).length > 0, "Event name must be set.");
        bytes memory properties = bytes(unifiedStorage.getString(PROPERTIES_KEY));
        require(properties.length > 0, "Properties must be set.");
    }

    /**
     * @dev Buyer/Seller has made an Ether withdraw from the issuance
     * @param issuanceId The id of the issuance
     * @param unifiedStorage The storage contract created for this issuance
     * @param toAddress The address of the Ether receiver
     * @param amount The amount of Ether transfered
     * @return updatedState The new state of the issuance.
     */
   function processWithdraw(uint256 issuanceId, IssuanceStates /** state*/, UnifiedStorage unifiedStorage,
        string memory /** balances */, address toAddress, uint256 amount)
        public returns (IssuanceStates /** updatedState */, string memory /** transers */) {

        handleTokenWithdraw(issuanceId, unifiedStorage, toAddress, ETH_ADDRESS, amount);
    }

    /**
     * @dev Buyer/Seller has made an ERC20 token withdraw from the issuance
     * @param issuanceId The id of the issuance
     * @param unifiedStorage The storage contract created for this issuance
     * @param toAddress The address of the ERC20 token receiver
     * @param tokenAddress The address of the ERC20 token
     * @param amount The amount of ERC20 token transfered
     * @return updatedState The new state of the issuance.
     * @return transfers The transfers to perform after the invocation
     */
    function processTokenWithdraw(uint256 issuanceId, IssuanceStates /** state */, UnifiedStorage unifiedStorage,
        string memory /** balances */, address toAddress, address tokenAddress, uint256 amount)
        public returns (IssuanceStates /** updatedState */, string memory /** transfers */) {
        
        handleTokenWithdraw(issuanceId, unifiedStorage, toAddress, tokenAddress, amount);
    }

    /**
     * @dev Buyer/Seller has made an ERC20 token withdraw from the issuance
     * @param issuanceId The id of the issuance
     * @param unifiedStorage The storage contract created for this issuance
     * @param toAddress The address of the ERC20 token receiver
     * @param tokenAddress The address of the ERC20 token
     * @param amount The amount of ERC20 token transfered
     */
    function handleTokenWithdraw(uint256 issuanceId, UnifiedStorage unifiedStorage,
        address toAddress, address tokenAddress, uint256 amount) private {
        // Parameter validation
        require(issuanceId > 0, "Issuance id must be set.");
        require(toAddress != address(0x0), "Receiver address must be set.");
        require(tokenAddress != address(0x0), "Transferred token address must be set.");
        require(amount > 0, "Withdraw amount must be greater than 0.");
        bytes memory properties = bytes(unifiedStorage.getString(PROPERTIES_KEY));
        require(properties.length > 0, "Properties must be set.");

        // Load properties
        StakeMiningProperties.Data memory stakeMiningProperties = StakeMiningProperties.decode(properties);
        // Validate whether the token is supported
        uint256 tokenIndex = getTokenIndex(stakeMiningProperties.tokens, tokenAddress);
        require(tokenIndex != INDEX_NOT_FOUND, "ERC20 token is not supported.");
        
        // Load all account addresses
        Account.Data[] memory accounts = new Account.Data[](stakeMiningProperties.accountCount);
        uint256 accountIndex = INDEX_NOT_FOUND;
        uint256[] memory tokenTotals = new uint256[](stakeMiningProperties.tokens.length);
        for (uint i = 0; i < stakeMiningProperties.accountCount; i++) {
          accounts[i] = Account.decode(bytes(unifiedStorage.getString(ACCOUNTS_KEY_PREFIX.concat(i))));
          for (uint j = 0; j < accounts[i].balances.length; j++) {
            tokenTotals[j] = tokenTotals[j].add(accounts[i].balances[j]);
          }
          if (accounts[i].accountAddress == toAddress) {
            accountIndex = i;
          }
        }
        require(accountIndex != INDEX_NOT_FOUND, "Receiver address does not exist in mining pool");
        require(accounts[accountIndex].balances.length >= tokenIndex, "Receiver does not the token to withdraw");
        require(accounts[accountIndex].balances[tokenIndex] >= amount, "Insufficient balance to withdraw");

        // Mint tokens should take place before transfer
        mintTokens(issuanceId, stakeMiningProperties, accounts, tokenTotals);

        // Update the account balance
        accounts[accountIndex].balances[tokenIndex] = accounts[accountIndex].balances[0].sub(tokenIndex);

        // Check whether the balance of this user has reached zero
        bool emptyAccount = true;
        for (uint j = 0; j < accounts[accountIndex].balances.length; j++) {
          if (accounts[accountIndex].balances[j] > 0) {
            emptyAccount = false;
            break;
          }
        }

        // If the account is empty, remove this user from storage
        if (emptyAccount) {
          // Check whether the user is the last account
          if (accountIndex != stakeMiningProperties.accountCount - 1) {
            // The account is not the last one; move the last one to current location
            unifiedStorage.setString(ACCOUNTS_KEY_PREFIX.concat(accountIndex),
              unifiedStorage.getString(ACCOUNTS_KEY_PREFIX.concat(stakeMiningProperties.accountCount - 1)));
          }

          // Update the account count
          stakeMiningProperties.accountCount--;
        } else {
          // Update account to unified storage
          unifiedStorage.setString(ACCOUNTS_KEY_PREFIX.concat(accountIndex), string(accounts[accountIndex].encode()));
        }

        // Persist the propertiess
        unifiedStorage.setString(PROPERTIES_KEY, string(stakeMiningProperties.encode()));
    }

    /**
     * @dev Custom event is not supported in loan contract.
     */
    function processCustomEvent(uint256 /** issuanceId */, IssuanceStates /** state */, UnifiedStorage /** unifiedStorage */,
        string memory /** balances */, string memory /** eventName */, string memory /** eventPayload */)
        public returns (IssuanceStates /** updatedState */, string memory /** transfers */) {
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
     * @dev Core function: This is the function to do the actual token minting.
     */
    function mintTokens(uint256 issuanceId, StakeMiningProperties.Data memory properties,
      Account.Data[] memory accounts, uint256[] memory tokenTotals) private {
      // Check whether it's in the stake mininig period
      if (block.number < properties.startBlock || block.number > properties.endBlock) {
        return;
      }

      // Calculate the total mining pool value
      uint256 totalBalance = 0;
      // Get the price for each token
      uint256[] memory tokenPrices = new uint256[](properties.tokens.length);
      for (uint i = 0; i < properties.tokens.length; i++) {
        if (!properties.tokenSupported[i]) {
          continue;
        }
        tokenPrices[i] = PriceOracleInterface(properties.priceOracle).getPrice(properties.tokens[i]);
        totalBalance = totalBalance.add(tokenTotals[i].mul(tokenPrices[i]));
      }

      // If the pool is empty, skip minting
      if (totalBalance == 0) {
        properties.lastMintBlock = block.number;
        return;
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

      // Calculate the total balance of each accounts
      uint256[] memory accountTotals = new uint256[](properties.accountCount);
      // For all users
      for (uint j = 0; j < properties.accountCount; j++) {
        // For all supported tokens
        for (uint i = 0; i < properties.tokens.length && i < accounts[j].balances.length; i++) {
          // No need to check supported tokens
          if (!properties.tokenSupported[i]) {
            continue;
          }
          accountTotals[j] = accountTotals[j].add(accounts[j].balances[i].mul(tokenPrices[i]));
        }
      }

      // Mint for each account
      for (uint j = 0; j < properties.accountCount; j++) {
        // Skip accounts with zero total balance
        if (accountTotals[j] == 0) {
          continue;
        }
        uint256 stakerMintedAmount = mintedAmount.mul(accountTotals[j]).div(totalBalance);
        IMintable(properties.mintedToken).mint(accounts[j].accountAddress, stakerMintedAmount);

        emit Minted(issuanceId, accounts[j].accountAddress, stakerMintedAmount);
      }
      properties.lastMintBlock = block.number;
    }
}
