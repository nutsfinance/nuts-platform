pragma solidity ^0.5.0;
import "./runtime.sol";

library ProtoBufBalance {

  //enum definition
  

  //struct definition
  struct Data {
    bool isEther;
    address tokenAddress;
    uint256 amount;
    //non serialized field for map

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
  // innter decoder

  function _decode(uint p, bytes memory bs, uint sz)
      internal pure returns (Data memory, uint) {
    Data memory r;
    uint[5] memory counters;
    uint fieldId;
    ProtoBufParser.WireType wireType;
    uint bytesRead;
    uint offset = p;
    while(p < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufParser._decode_key(p, bs);
      p += bytesRead;
      
      if(fieldId == 1) {
        p += _read_isEther(p, bs, r, counters);
      }
      else if(fieldId == 2) {
        p += _read_tokenAddress(p, bs, r, counters);
      }
      else if(fieldId == 4) {
        p += _read_amount(p, bs, r, counters);
      }
    }
    
    return (r, sz);
  }

  // field readers

  function _read_isEther(uint p, bytes memory bs, Data memory r, uint[5] memory counters) internal pure returns (uint) {
    (bool x, uint sz) = ProtoBufParser._decode_bool(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.isEther = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }
  function _read_tokenAddress(uint p, bytes memory bs, Data memory r, uint[5] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufParser._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[2] += 1;
    } else {
      r.tokenAddress = x;
      if(counters[2] > 0) counters[2] -= 1;
    }
    return sz;
  }
  function _read_amount(uint p, bytes memory bs, Data memory r, uint[5] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufParser._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[4] += 1;
    } else {
      r.amount = x;
      if(counters[4] > 0) counters[4] -= 1;
    }
    return sz;
  }
  // struct decoder


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
    
    
    p += ProtoBufParser._encode_key(1, ProtoBufParser.WireType.Varint, p, bs);
    p += ProtoBufParser._encode_bool(r.isEther, p, bs);
    p += ProtoBufParser._encode_key(2, ProtoBufParser.WireType.LengthDelim, p, bs);
    p += ProtoBufParser._encode_sol_address(r.tokenAddress, p, bs);
    p += ProtoBufParser._encode_key(4, ProtoBufParser.WireType.LengthDelim, p, bs);
    p += ProtoBufParser._encode_sol_uint256(r.amount, p, bs);
    return p - offset;
  }
  // nested encoder

  function _encode_nested(Data memory r, uint p, bytes memory bs)
      internal pure returns (uint) {
    uint offset = p;
    p += ProtoBufParser._encode_varint(_estimate(r), p, bs);
    p += _encode(r, p, bs);
    return p - offset;
  }
  // estimator

  function _estimate(Data memory /* r */) internal pure returns (uint) {
    uint e;
    
    
    e += 1 + 1;
    e += 1 + 23;
    e += 1 + 35;
    return e;
  }

    //store function
  function store(Data memory input, Data storage output) internal {
    output.isEther = input.isEther;
    output.tokenAddress = input.tokenAddress;
    output.amount = input.amount;

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
//library ProtoBufBalance

library ProtoBufBalances {

  //enum definition
  

  //struct definition
  struct Data {
    ProtoBufBalance.Data[] balances;
    //non serialized field for map

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
  // innter decoder

  function _decode(uint p, bytes memory bs, uint sz)
      internal pure returns (Data memory, uint) {
    Data memory r;
    uint[2] memory counters;
    uint fieldId;
    ProtoBufParser.WireType wireType;
    uint bytesRead;
    uint offset = p;
    while(p < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufParser._decode_key(p, bs);
      p += bytesRead;
      
      if(fieldId == 1) {
        p += _read_balances(p, bs, nil(), counters);
      }
    }
    
    p = offset;
    
    r.balances = new ProtoBufBalance.Data[](counters[1]);

    while(p < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufParser._decode_key(p, bs);
      p += bytesRead;
      
      if(fieldId == 1) {
        p += _read_balances(p, bs, r, counters);
      }
    }
    return (r, sz);
  }

  // field readers

  function _read_balances(uint p, bytes memory bs, Data memory r, uint[2] memory counters) internal pure returns (uint) {
    (ProtoBufBalance.Data memory x, uint sz) = _decode_Balance(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.balances[ r.balances.length - counters[1] ] = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }
  // struct decoder

  function _decode_Balance(uint p, bytes memory bs)
      internal pure returns (ProtoBufBalance.Data memory, uint) {
    (uint sz, uint bytesRead) = ProtoBufParser._decode_varint(p, bs);
    p += bytesRead;
    (ProtoBufBalance.Data memory r,) = ProtoBufBalance._decode(p, bs, sz);
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
    uint i;
    
    for(i = 0; i < r.balances.length; i++) {
      p += ProtoBufParser._encode_key(1, ProtoBufParser.WireType.LengthDelim, p, bs);
      p += ProtoBufBalance._encode_nested(r.balances[i], p, bs);
    }
    return p - offset;
  }
  // nested encoder

  function _encode_nested(Data memory r, uint p, bytes memory bs)
      internal pure returns (uint) {
    uint offset = p;
    p += ProtoBufParser._encode_varint(_estimate(r), p, bs);
    p += _encode(r, p, bs);
    return p - offset;
  }
  // estimator

  function _estimate(Data memory r) internal pure returns (uint) {
    uint e;
    uint i;
    
    for(i = 0; i < r.balances.length; i++) {
      e+= 1 + ProtoBufParser._sz_lendelim(ProtoBufBalance._estimate(r.balances[i]));
    }
    return e;
  }

    //store function
  function store(Data memory input, Data storage output) internal {

    output.balances.length = input.balances.length;
    for(uint i1 = 0; i1 < input.balances.length; i1++) {
      ProtoBufBalance.store(input.balances[i1], output.balances[i1]);
    }
    

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
//library ProtoBufBalances