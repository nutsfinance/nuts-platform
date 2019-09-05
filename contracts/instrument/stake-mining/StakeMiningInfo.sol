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
    uint256 minimumBalance;
    address teamWallet;
    uint256 teamPercentage;
    address priceOracle;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x,) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x,) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
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
        pointer += _read_minimumBalance(pointer, bs, r, counters);
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
      else {
        if (wireType == ProtoBufRuntime.WireType.Fixed64) {
          uint size;
          (, size) = ProtoBufRuntime._decode_fixed64(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.Fixed32) {
          uint size;
          (, size) = ProtoBufRuntime._decode_fixed32(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.Varint) {
          uint size;
          (, size) = ProtoBufRuntime._decode_varint(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.LengthDelim) {
          uint size;
          (, size) = ProtoBufRuntime._decode_lendelim(pointer, bs);
          pointer += size;
        }
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
        pointer += _read_minimumBalance(pointer, bs, nil(), counters);
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
      else {
        if (wireType == ProtoBufRuntime.WireType.Fixed64) {
          uint size;
          (, size) = ProtoBufRuntime._decode_fixed64(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.Fixed32) {
          uint size;
          (, size) = ProtoBufRuntime._decode_fixed32(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.Varint) {
          uint size;
          (, size) = ProtoBufRuntime._decode_varint(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.LengthDelim) {
          uint size;
          (, size) = ProtoBufRuntime._decode_lendelim(pointer, bs);
          pointer += size;
        }
      }
    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_supportedTokens(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.supportedTokens[r.supportedTokens.length - counters[1]] = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_supportETH(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (bool x, uint sz) = ProtoBufRuntime._decode_bool(p, bs);
    if(isNil(r)) {
      counters[2] += 1;
    } else {
      r.supportETH = x;
      if(counters[2] > 0) counters[2] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_mintedToken(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[3] += 1;
    } else {
      r.mintedToken = x;
      if(counters[3] > 0) counters[3] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_startBlock(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[4] += 1;
    } else {
      r.startBlock = x;
      if(counters[4] > 0) counters[4] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_endBlock(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[5] += 1;
    } else {
      r.endBlock = x;
      if(counters[5] > 0) counters[5] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_tokensPerBlock(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[6] += 1;
    } else {
      r.tokensPerBlock = x;
      if(counters[6] > 0) counters[6] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_minimumBalance(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[7] += 1;
    } else {
      r.minimumBalance = x;
      if(counters[7] > 0) counters[7] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_teamWallet(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[8] += 1;
    } else {
      r.teamWallet = x;
      if(counters[8] > 0) counters[8] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_teamPercentage(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[9] += 1;
    } else {
      r.teamPercentage = x;
      if(counters[9] > 0) counters[9] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_priceOracle(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
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

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint p, bytes memory bs)
      internal pure returns (uint) {
    uint offset = p;
    uint pointer = p;
    uint i;
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
    pointer += ProtoBufRuntime._encode_sol_uint256(r.minimumBalance, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(8, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.teamWallet, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(9, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.teamPercentage, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(10, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.priceOracle, pointer, bs);
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint p, bytes memory bs)
      internal pure returns (uint) {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint offset = p;
    uint pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
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
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.supportedTokens = input.supportedTokens;
    output.supportETH = input.supportETH;
    output.mintedToken = input.mintedToken;
    output.startBlock = input.startBlock;
    output.endBlock = input.endBlock;
    output.tokensPerBlock = input.tokensPerBlock;
    output.minimumBalance = input.minimumBalance;
    output.teamWallet = input.teamWallet;
    output.teamPercentage = input.teamPercentage;
    output.priceOracle = input.priceOracle;

  }


  //array helpers for SupportedTokens
  /**
   * @dev Add value to an array
   * @param self The in-memory struct
   * @param value The value to add
   */
  function addSupportedTokens(Data memory self, address  value) internal pure {
    /**
     * First resize the array. Then add the new element to the end.
     */
    address[] memory tmp = new address[](self.supportedTokens.length + 1);
    for (uint i = 0; i < self.supportedTokens.length; i++) {
      tmp[i] = self.supportedTokens[i];
    }
    tmp[self.supportedTokens.length] = value;
    self.supportedTokens = tmp;
  }


  //utility functions
  /**
   * @dev Return an empty struct
   * @return The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return True if it is empty
   */
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
    uint256 minimumBalance;
    address teamWallet;
    uint256 teamPercentage;
    address priceOracle;
    uint256 accountCount;
    uint256 lastMintBlock;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x,) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x,) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint p, bytes memory bs, uint sz)
      internal pure returns (Data memory, uint) {
    Data memory r;
    uint[13] memory counters;
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
        pointer += _read_minimumBalance(pointer, bs, r, counters);
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
        pointer += _read_accountCount(pointer, bs, r, counters);
      }
      else if(fieldId == 12) {
        pointer += _read_lastMintBlock(pointer, bs, r, counters);
      }
      else {
        if (wireType == ProtoBufRuntime.WireType.Fixed64) {
          uint size;
          (, size) = ProtoBufRuntime._decode_fixed64(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.Fixed32) {
          uint size;
          (, size) = ProtoBufRuntime._decode_fixed32(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.Varint) {
          uint size;
          (, size) = ProtoBufRuntime._decode_varint(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.LengthDelim) {
          uint size;
          (, size) = ProtoBufRuntime._decode_lendelim(pointer, bs);
          pointer += size;
        }
      }
    }
    pointer = offset;
    r.tokens = new address[](counters[1]);
    r.tokenSupported = new bool[](counters[2]);

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
        pointer += _read_minimumBalance(pointer, bs, nil(), counters);
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
        pointer += _read_accountCount(pointer, bs, nil(), counters);
      }
      else if(fieldId == 12) {
        pointer += _read_lastMintBlock(pointer, bs, nil(), counters);
      }
      else {
        if (wireType == ProtoBufRuntime.WireType.Fixed64) {
          uint size;
          (, size) = ProtoBufRuntime._decode_fixed64(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.Fixed32) {
          uint size;
          (, size) = ProtoBufRuntime._decode_fixed32(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.Varint) {
          uint size;
          (, size) = ProtoBufRuntime._decode_varint(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.LengthDelim) {
          uint size;
          (, size) = ProtoBufRuntime._decode_lendelim(pointer, bs);
          pointer += size;
        }
      }
    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_tokens(uint p, bytes memory bs, Data memory r, uint[13] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.tokens[r.tokens.length - counters[1]] = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_tokenSupported(uint p, bytes memory bs, Data memory r, uint[13] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (bool x, uint sz) = ProtoBufRuntime._decode_bool(p, bs);
    if(isNil(r)) {
      counters[2] += 1;
    } else {
      r.tokenSupported[r.tokenSupported.length - counters[2]] = x;
      if(counters[2] > 0) counters[2] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_mintedToken(uint p, bytes memory bs, Data memory r, uint[13] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[3] += 1;
    } else {
      r.mintedToken = x;
      if(counters[3] > 0) counters[3] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_startBlock(uint p, bytes memory bs, Data memory r, uint[13] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[4] += 1;
    } else {
      r.startBlock = x;
      if(counters[4] > 0) counters[4] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_endBlock(uint p, bytes memory bs, Data memory r, uint[13] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[5] += 1;
    } else {
      r.endBlock = x;
      if(counters[5] > 0) counters[5] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_tokensPerBlock(uint p, bytes memory bs, Data memory r, uint[13] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[6] += 1;
    } else {
      r.tokensPerBlock = x;
      if(counters[6] > 0) counters[6] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_minimumBalance(uint p, bytes memory bs, Data memory r, uint[13] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[7] += 1;
    } else {
      r.minimumBalance = x;
      if(counters[7] > 0) counters[7] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_teamWallet(uint p, bytes memory bs, Data memory r, uint[13] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[8] += 1;
    } else {
      r.teamWallet = x;
      if(counters[8] > 0) counters[8] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_teamPercentage(uint p, bytes memory bs, Data memory r, uint[13] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[9] += 1;
    } else {
      r.teamPercentage = x;
      if(counters[9] > 0) counters[9] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_priceOracle(uint p, bytes memory bs, Data memory r, uint[13] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[10] += 1;
    } else {
      r.priceOracle = x;
      if(counters[10] > 0) counters[10] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_accountCount(uint p, bytes memory bs, Data memory r, uint[13] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[11] += 1;
    } else {
      r.accountCount = x;
      if(counters[11] > 0) counters[11] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_lastMintBlock(uint p, bytes memory bs, Data memory r, uint[13] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[12] += 1;
    } else {
      r.lastMintBlock = x;
      if(counters[12] > 0) counters[12] -= 1;
    }
    return sz;
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint p, bytes memory bs)
      internal pure returns (uint) {
    uint offset = p;
    uint pointer = p;
    uint i;
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
    pointer += ProtoBufRuntime._encode_sol_uint256(r.minimumBalance, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(8, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.teamWallet, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(9, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.teamPercentage, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(10, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.priceOracle, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(11, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.accountCount, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(12, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.lastMintBlock, pointer, bs);
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint p, bytes memory bs)
      internal pure returns (uint) {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint offset = p;
    uint pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
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
    e += 1 + 35;
    e += 1 + 35;
    return e;
  }

  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.tokens = input.tokens;
    output.tokenSupported = input.tokenSupported;
    output.mintedToken = input.mintedToken;
    output.startBlock = input.startBlock;
    output.endBlock = input.endBlock;
    output.tokensPerBlock = input.tokensPerBlock;
    output.minimumBalance = input.minimumBalance;
    output.teamWallet = input.teamWallet;
    output.teamPercentage = input.teamPercentage;
    output.priceOracle = input.priceOracle;
    output.accountCount = input.accountCount;
    output.lastMintBlock = input.lastMintBlock;

  }


  //array helpers for Tokens
  /**
   * @dev Add value to an array
   * @param self The in-memory struct
   * @param value The value to add
   */
  function addTokens(Data memory self, address  value) internal pure {
    /**
     * First resize the array. Then add the new element to the end.
     */
    address[] memory tmp = new address[](self.tokens.length + 1);
    for (uint i = 0; i < self.tokens.length; i++) {
      tmp[i] = self.tokens[i];
    }
    tmp[self.tokens.length] = value;
    self.tokens = tmp;
  }

  //array helpers for TokenSupported
  /**
   * @dev Add value to an array
   * @param self The in-memory struct
   * @param value The value to add
   */
  function addTokenSupported(Data memory self, bool  value) internal pure {
    /**
     * First resize the array. Then add the new element to the end.
     */
    bool[] memory tmp = new bool[](self.tokenSupported.length + 1);
    for (uint i = 0; i < self.tokenSupported.length; i++) {
      tmp[i] = self.tokenSupported[i];
    }
    tmp[self.tokenSupported.length] = value;
    self.tokenSupported = tmp;
  }


  //utility functions
  /**
   * @dev Return an empty struct
   * @return The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library StakeMiningProperties

library Account {


  //struct definition
  struct Data {
    address accountAddress;
    uint256[] balances;
  }

  // Decoder section

  /**
   * @dev The main decoder for memory
   * @param bs The bytes array to be decoded
   * @return The decoded struct
   */
  function decode(bytes memory bs) internal pure returns (Data memory) {
    (Data memory x,) = _decode(32, bs, bs.length);
    return x;
  }

  /**
   * @dev The main decoder for storage
   * @param self The in-storage struct
   * @param bs The bytes array to be decoded
   */
  function decode(Data storage self, bytes memory bs) internal {
    (Data memory x,) = _decode(32, bs, bs.length);
    store(x, self);
  }
  // inner decoder

  /**
   * @dev The decoder for internal usage
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param sz The number of bytes expected
   * @return The decoded struct
   * @return The number of bytes decoded
   */
  function _decode(uint p, bytes memory bs, uint sz)
      internal pure returns (Data memory, uint) {
    Data memory r;
    uint[3] memory counters;
    uint fieldId;
    ProtoBufRuntime.WireType wireType;
    uint bytesRead;
    uint offset = p;
    uint pointer = p;
    while(pointer < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if(fieldId == 1) {
        pointer += _read_accountAddress(pointer, bs, r, counters);
      }
      else if(fieldId == 2) {
        pointer += _read_balances(pointer, bs, nil(), counters);
      }
      else {
        if (wireType == ProtoBufRuntime.WireType.Fixed64) {
          uint size;
          (, size) = ProtoBufRuntime._decode_fixed64(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.Fixed32) {
          uint size;
          (, size) = ProtoBufRuntime._decode_fixed32(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.Varint) {
          uint size;
          (, size) = ProtoBufRuntime._decode_varint(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.LengthDelim) {
          uint size;
          (, size) = ProtoBufRuntime._decode_lendelim(pointer, bs);
          pointer += size;
        }
      }
    }
    pointer = offset;
    r.balances = new uint256[](counters[2]);

    while(pointer < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if(fieldId == 1) {
        pointer += _read_accountAddress(pointer, bs, nil(), counters);
      }
      else if(fieldId == 2) {
        pointer += _read_balances(pointer, bs, r, counters);
      }
      else {
        if (wireType == ProtoBufRuntime.WireType.Fixed64) {
          uint size;
          (, size) = ProtoBufRuntime._decode_fixed64(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.Fixed32) {
          uint size;
          (, size) = ProtoBufRuntime._decode_fixed32(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.Varint) {
          uint size;
          (, size) = ProtoBufRuntime._decode_varint(pointer, bs);
          pointer += size;
        }
        if (wireType == ProtoBufRuntime.WireType.LengthDelim) {
          uint size;
          (, size) = ProtoBufRuntime._decode_lendelim(pointer, bs);
          pointer += size;
        }
      }
    }
    return (r, sz);
  }

  // field readers

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_accountAddress(uint p, bytes memory bs, Data memory r, uint[3] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.accountAddress = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }

  /**
   * @dev The decoder for reading a field
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @param r The in-memory struct
   * @param counters The counters for repeated fields
   * @return The number of bytes decoded
   */
  function _read_balances(uint p, bytes memory bs, Data memory r, uint[3] memory counters) internal pure returns (uint) {
    /**
     * if `r` is NULL, then only counting the number of fields.
     */
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[2] += 1;
    } else {
      r.balances[r.balances.length - counters[2]] = x;
      if(counters[2] > 0) counters[2] -= 1;
    }
    return sz;
  }


  // Encoder section

  /**
   * @dev The main encoder for memory
   * @param r The struct to be encoded
   * @return The encoded byte array
   */
  function encode(Data memory r) internal pure returns (bytes memory) {
    bytes memory bs = new bytes(_estimate(r));
    uint sz = _encode(r, 32, bs);
    assembly {
      mstore(bs, sz)
    }
    return bs;
  }
  // inner encoder

  /**
   * @dev The encoder for internal usage
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode(Data memory r, uint p, bytes memory bs)
      internal pure returns (uint) {
    uint offset = p;
    uint pointer = p;
    uint i;
    pointer += ProtoBufRuntime._encode_key(1, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.accountAddress, pointer, bs);
    for(i = 0; i < r.balances.length; i++) {
      pointer += ProtoBufRuntime._encode_key(2, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
      pointer += ProtoBufRuntime._encode_sol_uint256(r.balances[i], pointer, bs);
    }
    return pointer - offset;
  }
  // nested encoder

  /**
   * @dev The encoder for inner struct
   * @param r The struct to be encoded
   * @param p The offset of bytes array to start decode
   * @param bs The bytes array to be decoded
   * @return The number of bytes encoded
   */
  function _encode_nested(Data memory r, uint p, bytes memory bs)
      internal pure returns (uint) {
    /**
     * First encoded `r` into a temporary array, and encode the actual size used.
     * Then copy the temporary array into `bs`.
     */
    uint offset = p;
    uint pointer = p;
    bytes memory tmp = new bytes(_estimate(r));
    uint tmpAddr = ProtoBufRuntime.getMemoryAddress(tmp);
    uint bsAddr = ProtoBufRuntime.getMemoryAddress(bs);
    uint size = _encode(r, 32, tmp);
    pointer += ProtoBufRuntime._encode_varint(size, pointer, bs);
    ProtoBufRuntime.copyBytes(tmpAddr + 32, bsAddr + pointer, size);
    pointer += size;
    delete tmp;
    return pointer - offset;
  }
  // estimator

  /**
   * @dev The estimator for a struct
   * @param r The struct to be encoded
   * @return The number of bytes encoded in estimation
   */
  function _estimate(Data memory r) internal pure returns (uint) {
    uint e;uint i;
    e += 1 + 23;
    for(i = 0; i < r.balances.length; i++) {
      e += 1 + 35;
    }
    return e;
  }

  //store function
  /**
   * @dev Store in-memory struct to storage
   * @param input The in-memory struct
   * @param output The in-storage struct
   */
  function store(Data memory input, Data storage output) internal {
    output.accountAddress = input.accountAddress;
    output.balances = input.balances;

  }


  //array helpers for Balances
  /**
   * @dev Add value to an array
   * @param self The in-memory struct
   * @param value The value to add
   */
  function addBalances(Data memory self, uint256  value) internal pure {
    /**
     * First resize the array. Then add the new element to the end.
     */
    uint256[] memory tmp = new uint256[](self.balances.length + 1);
    for (uint i = 0; i < self.balances.length; i++) {
      tmp[i] = self.balances[i];
    }
    tmp[self.balances.length] = value;
    self.balances = tmp;
  }


  //utility functions
  /**
   * @dev Return an empty struct
   * @return The empty struct
   */
  function nil() internal pure returns (Data memory r) {
    assembly {
      r := 0
    }
  }

  /**
   * @dev Test whether a struct is empty
   * @param x The struct to be tested
   * @return True if it is empty
   */
  function isNil(Data memory x) internal pure returns (bool r) {
    assembly {
      r := iszero(x)
    }
  }
}
//library Account
