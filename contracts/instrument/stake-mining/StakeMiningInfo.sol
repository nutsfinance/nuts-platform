pragma solidity ^0.5.0;
import "../../ProtoBufRuntime.sol";

library StakeMiningParameters {


  //struct definition
  struct Data {
    address[] supportedTokens;
    bool supportETH;
    address mintedToken;
    uint256 startBlock;
    uint256 endBlock;
    uint256 tokensPerBlock;
    uint256 minimumDeposit;
    address teamWallet;
    uint256 teamPercentage;
    address priceOracle;
  }

  // Decoder section

  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x,) = _decode(32, bs, bs.length);
    return x;
  }

  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x,) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  function _decode(uint p, bytes memory bs, uint sz)
      internal pure returns (Data memory, uint) {
    Data memory r;
    uint[11] memory counters;
    uint fieldId;
    ProtoBufRuntime.WireType wireType;
    uint bytesRead;
    uint offset = p;
    uint pointer = p;
    while(pointer < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if(fieldId == 1) {
        pointer += _read_supportedTokens(pointer, bs, nil(), counters);
      }
      else if(fieldId == 2) {
        pointer += _read_supportETH(pointer, bs, r, counters);
      }
      else if(fieldId == 3) {
        pointer += _read_mintedToken(pointer, bs, r, counters);
      }
      else if(fieldId == 4) {
        pointer += _read_startBlock(pointer, bs, r, counters);
      }
      else if(fieldId == 5) {
        pointer += _read_endBlock(pointer, bs, r, counters);
      }
      else if(fieldId == 6) {
        pointer += _read_tokensPerBlock(pointer, bs, r, counters);
      }
      else if(fieldId == 7) {
        pointer += _read_minimumDeposit(pointer, bs, r, counters);
      }
      else if(fieldId == 8) {
        pointer += _read_teamWallet(pointer, bs, r, counters);
      }
      else if(fieldId == 9) {
        pointer += _read_teamPercentage(pointer, bs, r, counters);
      }
      else if(fieldId == 10) {
        pointer += _read_priceOracle(pointer, bs, r, counters);
      }
    }
    pointer = offset;
    r.supportedTokens = new address[](counters[1]);

    while(pointer < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if(fieldId == 1) {
        pointer += _read_supportedTokens(pointer, bs, r, counters);
      }
      else if(fieldId == 2) {
        pointer += _read_supportETH(pointer, bs, nil(), counters);
      }
      else if(fieldId == 3) {
        pointer += _read_mintedToken(pointer, bs, nil(), counters);
      }
      else if(fieldId == 4) {
        pointer += _read_startBlock(pointer, bs, nil(), counters);
      }
      else if(fieldId == 5) {
        pointer += _read_endBlock(pointer, bs, nil(), counters);
      }
      else if(fieldId == 6) {
        pointer += _read_tokensPerBlock(pointer, bs, nil(), counters);
      }
      else if(fieldId == 7) {
        pointer += _read_minimumDeposit(pointer, bs, nil(), counters);
      }
      else if(fieldId == 8) {
        pointer += _read_teamWallet(pointer, bs, nil(), counters);
      }
      else if(fieldId == 9) {
        pointer += _read_teamPercentage(pointer, bs, nil(), counters);
      }
      else if(fieldId == 10) {
        pointer += _read_priceOracle(pointer, bs, nil(), counters);
      }
    }
    return (r, sz);
  }

  // field readers

  function _read_supportedTokens(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.supportedTokens[r.supportedTokens.length - counters[1]] = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }

  function _read_supportETH(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (bool x, uint sz) = ProtoBufRuntime._decode_bool(p, bs);
    if(isNil(r)) {
      counters[2] += 1;
    } else {
      r.supportETH = x;
      if(counters[2] > 0) counters[2] -= 1;
    }
    return sz;
  }

  function _read_mintedToken(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[3] += 1;
    } else {
      r.mintedToken = x;
      if(counters[3] > 0) counters[3] -= 1;
    }
    return sz;
  }

  function _read_startBlock(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[4] += 1;
    } else {
      r.startBlock = x;
      if(counters[4] > 0) counters[4] -= 1;
    }
    return sz;
  }

  function _read_endBlock(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[5] += 1;
    } else {
      r.endBlock = x;
      if(counters[5] > 0) counters[5] -= 1;
    }
    return sz;
  }

  function _read_tokensPerBlock(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[6] += 1;
    } else {
      r.tokensPerBlock = x;
      if(counters[6] > 0) counters[6] -= 1;
    }
    return sz;
  }

  function _read_minimumDeposit(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[7] += 1;
    } else {
      r.minimumDeposit = x;
      if(counters[7] > 0) counters[7] -= 1;
    }
    return sz;
  }

  function _read_teamWallet(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[8] += 1;
    } else {
      r.teamWallet = x;
      if(counters[8] > 0) counters[8] -= 1;
    }
    return sz;
  }

  function _read_teamPercentage(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[9] += 1;
    } else {
      r.teamPercentage = x;
      if(counters[9] > 0) counters[9] -= 1;
    }
    return sz;
  }

  function _read_priceOracle(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[10] += 1;
    } else {
      r.priceOracle = x;
      if(counters[10] > 0) counters[10] -= 1;
    }
    return sz;
  }


  // Encoder section

  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  function _encode(Data memory r, uint p, bytes memory bs)
      internal pure returns (uint) {
    uint offset = p;
    uint pointer = p;uint i;
    for(i = 0; i < r.supportedTokens.length; i++) {
      pointer += ProtoBufRuntime._encode_key(1, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
      pointer += ProtoBufRuntime._encode_sol_address(r.supportedTokens[i], pointer, bs);
    }
    pointer += ProtoBufRuntime._encode_key(2, ProtoBufRuntime.WireType.Varint, pointer, bs);
    pointer += ProtoBufRuntime._encode_bool(r.supportETH, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(3, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.mintedToken, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(4, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.startBlock, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(5, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.endBlock, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(6, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.tokensPerBlock, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(7, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.minimumDeposit, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(8, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.teamWallet, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(9, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.teamPercentage, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(10, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.priceOracle, pointer, bs);
    return pointer - offset;
  }
  // nested encoder

  function _encode_nested(Data memory r, uint p, bytes memory bs)
      internal pure returns (uint) {
    uint offset = p;
    uint pointer = p;
    pointer += ProtoBufRuntime._encode_varint(_estimate(r), pointer, bs);
    pointer += _encode(r, pointer, bs);
    return pointer - offset;
  }
  // estimator

  function _estimate(Data memory r) internal pure returns (uint) {
    uint e;uint i;
    for(i = 0; i < r.supportedTokens.length; i++) {
      e += 1 + 23;
    }
    e += 1 + 1;
    e += 1 + 23;
    e += 1 + 35;
    e += 1 + 35;
    e += 1 + 35;
    e += 1 + 35;
    e += 1 + 23;
    e += 1 + 35;
    e += 1 + 23;
    return e;
  }

  //store function
  function store(Data memory input, Data storage output) internal {
    output.supportedTokens = input.supportedTokens;
    output.supportETH = input.supportETH;
    output.mintedToken = input.mintedToken;
    output.startBlock = input.startBlock;
    output.endBlock = input.endBlock;
    output.tokensPerBlock = input.tokensPerBlock;
    output.minimumDeposit = input.minimumDeposit;
    output.teamWallet = input.teamWallet;
    output.teamPercentage = input.teamPercentage;
    output.priceOracle = input.priceOracle;

  }


  //array helpers for SupportedTokens
  function addSupportedTokens(Data memory self, address  value) internal pure {
    address[] memory tmp = new address[](self.supportedTokens.length + 1);
    for (uint i = 0; i < self.supportedTokens.length; i++) {
      tmp[i] = self.supportedTokens[i];
    }
    tmp[self.supportedTokens.length] = value;
    self.supportedTokens = tmp;
  }


  //utility functions
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library StakeMiningParameters

library StakeMiningProperties {


  //struct definition
  struct Data {
    address[] tokens;
    bool[] tokenSupported;
    address mintedToken;
    uint256 startBlock;
    uint256 endBlock;
    uint256 tokensPerBlock;
    uint256 minimumDeposit;
    address teamWallet;
    uint256 teamPercentage;
    address priceOracle;
    uint256[] tokenTotals;
    TokenBalances.Data[] tokenBalances;
    address[] accounts;
    uint256 accountCount;
    uint256 lastMintBlock;
  }

  // Decoder section

  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x,) = _decode(32, bs, bs.length);
    return x;
  }

  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x,) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  function _decode(uint p, bytes memory bs, uint sz)
      internal pure returns (Data memory, uint) {
    Data memory r;
    uint[16] memory counters;
    uint fieldId;
    ProtoBufRuntime.WireType wireType;
    uint bytesRead;
    uint offset = p;
    uint pointer = p;
    while(pointer < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if(fieldId == 1) {
        pointer += _read_tokens(pointer, bs, nil(), counters);
      }
      else if(fieldId == 2) {
        pointer += _read_tokenSupported(pointer, bs, nil(), counters);
      }
      else if(fieldId == 3) {
        pointer += _read_mintedToken(pointer, bs, r, counters);
      }
      else if(fieldId == 4) {
        pointer += _read_startBlock(pointer, bs, r, counters);
      }
      else if(fieldId == 5) {
        pointer += _read_endBlock(pointer, bs, r, counters);
      }
      else if(fieldId == 6) {
        pointer += _read_tokensPerBlock(pointer, bs, r, counters);
      }
      else if(fieldId == 7) {
        pointer += _read_minimumDeposit(pointer, bs, r, counters);
      }
      else if(fieldId == 8) {
        pointer += _read_teamWallet(pointer, bs, r, counters);
      }
      else if(fieldId == 9) {
        pointer += _read_teamPercentage(pointer, bs, r, counters);
      }
      else if(fieldId == 10) {
        pointer += _read_priceOracle(pointer, bs, r, counters);
      }
      else if(fieldId == 11) {
        pointer += _read_tokenTotals(pointer, bs, nil(), counters);
      }
      else if(fieldId == 12) {
        pointer += _read_tokenBalances(pointer, bs, nil(), counters);
      }
      else if(fieldId == 13) {
        pointer += _read_accounts(pointer, bs, nil(), counters);
      }
      else if(fieldId == 14) {
        pointer += _read_accountCount(pointer, bs, r, counters);
      }
      else if(fieldId == 15) {
        pointer += _read_lastMintBlock(pointer, bs, r, counters);
      }
    }
    pointer = offset;
    r.tokens = new address[](counters[1]);
    r.tokenSupported = new bool[](counters[2]);
    r.tokenTotals = new uint256[](counters[11]);
    r.tokenBalances = new TokenBalances.Data[](counters[12]);
    r.accounts = new address[](counters[13]);

    while(pointer < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if(fieldId == 1) {
        pointer += _read_tokens(pointer, bs, r, counters);
      }
      else if(fieldId == 2) {
        pointer += _read_tokenSupported(pointer, bs, r, counters);
      }
      else if(fieldId == 3) {
        pointer += _read_mintedToken(pointer, bs, nil(), counters);
      }
      else if(fieldId == 4) {
        pointer += _read_startBlock(pointer, bs, nil(), counters);
      }
      else if(fieldId == 5) {
        pointer += _read_endBlock(pointer, bs, nil(), counters);
      }
      else if(fieldId == 6) {
        pointer += _read_tokensPerBlock(pointer, bs, nil(), counters);
      }
      else if(fieldId == 7) {
        pointer += _read_minimumDeposit(pointer, bs, nil(), counters);
      }
      else if(fieldId == 8) {
        pointer += _read_teamWallet(pointer, bs, nil(), counters);
      }
      else if(fieldId == 9) {
        pointer += _read_teamPercentage(pointer, bs, nil(), counters);
      }
      else if(fieldId == 10) {
        pointer += _read_priceOracle(pointer, bs, nil(), counters);
      }
      else if(fieldId == 11) {
        pointer += _read_tokenTotals(pointer, bs, r, counters);
      }
      else if(fieldId == 12) {
        pointer += _read_tokenBalances(pointer, bs, r, counters);
      }
      else if(fieldId == 13) {
        pointer += _read_accounts(pointer, bs, r, counters);
      }
      else if(fieldId == 14) {
        pointer += _read_accountCount(pointer, bs, nil(), counters);
      }
      else if(fieldId == 15) {
        pointer += _read_lastMintBlock(pointer, bs, nil(), counters);
      }
    }
    return (r, sz);
  }

  // field readers

  function _read_tokens(uint p, bytes memory bs, Data memory r, uint[16] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.tokens[r.tokens.length - counters[1]] = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }

  function _read_tokenSupported(uint p, bytes memory bs, Data memory r, uint[16] memory counters) internal pure returns (uint) {
    (bool x, uint sz) = ProtoBufRuntime._decode_bool(p, bs);
    if(isNil(r)) {
      counters[2] += 1;
    } else {
      r.tokenSupported[r.tokenSupported.length - counters[2]] = x;
      if(counters[2] > 0) counters[2] -= 1;
    }
    return sz;
  }

  function _read_mintedToken(uint p, bytes memory bs, Data memory r, uint[16] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[3] += 1;
    } else {
      r.mintedToken = x;
      if(counters[3] > 0) counters[3] -= 1;
    }
    return sz;
  }

  function _read_startBlock(uint p, bytes memory bs, Data memory r, uint[16] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[4] += 1;
    } else {
      r.startBlock = x;
      if(counters[4] > 0) counters[4] -= 1;
    }
    return sz;
  }

  function _read_endBlock(uint p, bytes memory bs, Data memory r, uint[16] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[5] += 1;
    } else {
      r.endBlock = x;
      if(counters[5] > 0) counters[5] -= 1;
    }
    return sz;
  }

  function _read_tokensPerBlock(uint p, bytes memory bs, Data memory r, uint[16] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[6] += 1;
    } else {
      r.tokensPerBlock = x;
      if(counters[6] > 0) counters[6] -= 1;
    }
    return sz;
  }

  function _read_minimumDeposit(uint p, bytes memory bs, Data memory r, uint[16] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[7] += 1;
    } else {
      r.minimumDeposit = x;
      if(counters[7] > 0) counters[7] -= 1;
    }
    return sz;
  }

  function _read_teamWallet(uint p, bytes memory bs, Data memory r, uint[16] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[8] += 1;
    } else {
      r.teamWallet = x;
      if(counters[8] > 0) counters[8] -= 1;
    }
    return sz;
  }

  function _read_teamPercentage(uint p, bytes memory bs, Data memory r, uint[16] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[9] += 1;
    } else {
      r.teamPercentage = x;
      if(counters[9] > 0) counters[9] -= 1;
    }
    return sz;
  }

  function _read_priceOracle(uint p, bytes memory bs, Data memory r, uint[16] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[10] += 1;
    } else {
      r.priceOracle = x;
      if(counters[10] > 0) counters[10] -= 1;
    }
    return sz;
  }

  function _read_tokenTotals(uint p, bytes memory bs, Data memory r, uint[16] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[11] += 1;
    } else {
      r.tokenTotals[r.tokenTotals.length - counters[11]] = x;
      if(counters[11] > 0) counters[11] -= 1;
    }
    return sz;
  }

  function _read_tokenBalances(uint p, bytes memory bs, Data memory r, uint[16] memory counters) internal pure returns (uint) {
    (TokenBalances.Data memory x, uint sz) = _decode_TokenBalances(p, bs);
    if(isNil(r)) {
      counters[12] += 1;
    } else {
      r.tokenBalances[r.tokenBalances.length - counters[12]] = x;
      if(counters[12] > 0) counters[12] -= 1;
    }
    return sz;
  }

  function _read_accounts(uint p, bytes memory bs, Data memory r, uint[16] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[13] += 1;
    } else {
      r.accounts[r.accounts.length - counters[13]] = x;
      if(counters[13] > 0) counters[13] -= 1;
    }
    return sz;
  }

  function _read_accountCount(uint p, bytes memory bs, Data memory r, uint[16] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[14] += 1;
    } else {
      r.accountCount = x;
      if(counters[14] > 0) counters[14] -= 1;
    }
    return sz;
  }

  function _read_lastMintBlock(uint p, bytes memory bs, Data memory r, uint[16] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[15] += 1;
    } else {
      r.lastMintBlock = x;
      if(counters[15] > 0) counters[15] -= 1;
    }
    return sz;
  }

  // struct decoder
  function _decode_TokenBalances(uint p, bytes memory bs)
      internal pure returns (TokenBalances.Data memory, uint) {
    uint pointer = p;
    (uint sz, uint bytesRead) = ProtoBufRuntime._decode_varint(pointer, bs);
    pointer += bytesRead;
    (TokenBalances.Data memory r,) = TokenBalances._decode(pointer, bs, sz);
    return (r, sz + bytesRead);
  }


  // Encoder section

  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  function _encode(Data memory r, uint p, bytes memory bs)
      internal pure returns (uint) {
    uint offset = p;
    uint pointer = p;uint i;
    for(i = 0; i < r.tokens.length; i++) {
      pointer += ProtoBufRuntime._encode_key(1, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
      pointer += ProtoBufRuntime._encode_sol_address(r.tokens[i], pointer, bs);
    }
    for(i = 0; i < r.tokenSupported.length; i++) {
      pointer += ProtoBufRuntime._encode_key(2, ProtoBufRuntime.WireType.Varint, pointer, bs);
      pointer += ProtoBufRuntime._encode_bool(r.tokenSupported[i], pointer, bs);
    }
    pointer += ProtoBufRuntime._encode_key(3, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.mintedToken, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(4, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.startBlock, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(5, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.endBlock, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(6, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.tokensPerBlock, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(7, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.minimumDeposit, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(8, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.teamWallet, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(9, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.teamPercentage, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(10, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.priceOracle, pointer, bs);
    for(i = 0; i < r.tokenTotals.length; i++) {
      pointer += ProtoBufRuntime._encode_key(11, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
      pointer += ProtoBufRuntime._encode_sol_uint256(r.tokenTotals[i], pointer, bs);
    }
    for(i = 0; i < r.tokenBalances.length; i++) {
      pointer += ProtoBufRuntime._encode_key(12, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
      pointer += TokenBalances._encode_nested(r.tokenBalances[i], pointer, bs);
    }
    for(i = 0; i < r.accounts.length; i++) {
      pointer += ProtoBufRuntime._encode_key(13, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
      pointer += ProtoBufRuntime._encode_sol_address(r.accounts[i], pointer, bs);
    }
    pointer += ProtoBufRuntime._encode_key(14, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.accountCount, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(15, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.lastMintBlock, pointer, bs);
    return pointer - offset;
  }
  // nested encoder

  function _encode_nested(Data memory r, uint p, bytes memory bs)
      internal pure returns (uint) {
    uint offset = p;
    uint pointer = p;
    pointer += ProtoBufRuntime._encode_varint(_estimate(r), pointer, bs);
    pointer += _encode(r, pointer, bs);
    return pointer - offset;
  }
  // estimator

  function _estimate(Data memory r) internal pure returns (uint) {
    uint e;uint i;
    for(i = 0; i < r.tokens.length; i++) {
      e += 1 + 23;
    }
    for(i = 0; i < r.tokenSupported.length; i++) {
      e += 1 + 1;
    }
    e += 1 + 23;
    e += 1 + 35;
    e += 1 + 35;
    e += 1 + 35;
    e += 1 + 35;
    e += 1 + 23;
    e += 1 + 35;
    e += 1 + 23;
    for(i = 0; i < r.tokenTotals.length; i++) {
      e += 1 + 35;
    }
    for(i = 0; i < r.tokenBalances.length; i++) {
      e += 1 + ProtoBufRuntime._sz_lendelim(TokenBalances._estimate(r.tokenBalances[i]));
    }
    for(i = 0; i < r.accounts.length; i++) {
      e += 1 + 23;
    }
    e += 1 + 35;
    e += 1 + 35;
    return e;
  }

  //store function
  function store(Data memory input, Data storage output) internal {
    output.tokens = input.tokens;
    output.tokenSupported = input.tokenSupported;
    output.mintedToken = input.mintedToken;
    output.startBlock = input.startBlock;
    output.endBlock = input.endBlock;
    output.tokensPerBlock = input.tokensPerBlock;
    output.minimumDeposit = input.minimumDeposit;
    output.teamWallet = input.teamWallet;
    output.teamPercentage = input.teamPercentage;
    output.priceOracle = input.priceOracle;
    output.tokenTotals = input.tokenTotals;

    output.tokenBalances.length = input.tokenBalances.length;
    for(uint i12 = 0; i12 < input.tokenBalances.length; i12++) {
      TokenBalances.store(input.tokenBalances[i12], output.tokenBalances[i12]);
    }
    
    output.accounts = input.accounts;
    output.accountCount = input.accountCount;
    output.lastMintBlock = input.lastMintBlock;

  }


  //array helpers for Tokens
  function addTokens(Data memory self, address  value) internal pure {
    address[] memory tmp = new address[](self.tokens.length + 1);
    for (uint i = 0; i < self.tokens.length; i++) {
      tmp[i] = self.tokens[i];
    }
    tmp[self.tokens.length] = value;
    self.tokens = tmp;
  }

  //array helpers for TokenSupported
  function addTokenSupported(Data memory self, bool  value) internal pure {
    bool[] memory tmp = new bool[](self.tokenSupported.length + 1);
    for (uint i = 0; i < self.tokenSupported.length; i++) {
      tmp[i] = self.tokenSupported[i];
    }
    tmp[self.tokenSupported.length] = value;
    self.tokenSupported = tmp;
  }

  //array helpers for TokenTotals
  function addTokenTotals(Data memory self, uint256  value) internal pure {
    uint256[] memory tmp = new uint256[](self.tokenTotals.length + 1);
    for (uint i = 0; i < self.tokenTotals.length; i++) {
      tmp[i] = self.tokenTotals[i];
    }
    tmp[self.tokenTotals.length] = value;
    self.tokenTotals = tmp;
  }

  //array helpers for TokenBalances
  function addTokenBalances(Data memory self, TokenBalances.Data memory value) internal pure {
    TokenBalances.Data[] memory tmp = new TokenBalances.Data[](self.tokenBalances.length + 1);
    for (uint i = 0; i < self.tokenBalances.length; i++) {
      tmp[i] = self.tokenBalances[i];
    }
    tmp[self.tokenBalances.length] = value;
    self.tokenBalances = tmp;
  }

  //array helpers for Accounts
  function addAccounts(Data memory self, address  value) internal pure {
    address[] memory tmp = new address[](self.accounts.length + 1);
    for (uint i = 0; i < self.accounts.length; i++) {
      tmp[i] = self.accounts[i];
    }
    tmp[self.accounts.length] = value;
    self.accounts = tmp;
  }


  //utility functions
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library StakeMiningProperties

library TokenBalances {


  //struct definition
  struct Data {
    uint256[] balances;
  }

  // Decoder section

  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x,) = _decode(32, bs, bs.length);
    return x;
  }

  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x,) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  function _decode(uint p, bytes memory bs, uint sz)
      internal pure returns (Data memory, uint) {
    Data memory r;
    uint[2] memory counters;
    uint fieldId;
    ProtoBufRuntime.WireType wireType;
    uint bytesRead;
    uint offset = p;
    uint pointer = p;
    while(pointer < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if(fieldId == 1) {
        pointer += _read_balances(pointer, bs, nil(), counters);
      }
    }
    pointer = offset;
    r.balances = new uint256[](counters[1]);

    while(pointer < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if(fieldId == 1) {
        pointer += _read_balances(pointer, bs, r, counters);
      }
    }
    return (r, sz);
  }

  // field readers

  function _read_balances(uint p, bytes memory bs, Data memory r, uint[2] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.balances[r.balances.length - counters[1]] = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }


  // Encoder section

  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  function _encode(Data memory r, uint p, bytes memory bs)
      internal pure returns (uint) {
    uint offset = p;
    uint pointer = p;uint i;
    for(i = 0; i < r.balances.length; i++) {
      pointer += ProtoBufRuntime._encode_key(1, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
      pointer += ProtoBufRuntime._encode_sol_uint256(r.balances[i], pointer, bs);
    }
    return pointer - offset;
  }
  // nested encoder

  function _encode_nested(Data memory r, uint p, bytes memory bs)
      internal pure returns (uint) {
    uint offset = p;
    uint pointer = p;
    pointer += ProtoBufRuntime._encode_varint(_estimate(r), pointer, bs);
    pointer += _encode(r, pointer, bs);
    return pointer - offset;
  }
  // estimator

  function _estimate(Data memory r) internal pure returns (uint) {
    uint e;uint i;
    for(i = 0; i < r.balances.length; i++) {
      e += 1 + 35;
    }
    return e;
  }

  //store function
  function store(Data memory input, Data storage output) internal {
    output.balances = input.balances;

  }


  //array helpers for Balances
  function addBalances(Data memory self, uint256  value) internal pure {
    uint256[] memory tmp = new uint256[](self.balances.length + 1);
    for (uint i = 0; i < self.balances.length; i++) {
      tmp[i] = self.balances[i];
    }
    tmp[self.balances.length] = value;
    self.balances = tmp;
  }


  //utility functions
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library TokenBalances