pragma solidity ^0.5.0;

import "./ProtoBufParser.sol";

library InstrumentStatus {

  //enum definition


  //struct definition
  struct Data {
    address instrumentAddress;
    address fspAddress;
    bool active;
    uint256 creation;
    uint256 expiration;
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
    uint[6] memory counters;
    uint fieldId;
    ProtoBufParser.WireType wireType;
    uint bytesRead;
    uint offset = p;
    while(p < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufParser._decode_key(p, bs);
      p += bytesRead;

      if(fieldId == 1) {
        p += _read_instrumentAddress(p, bs, r, counters);
      }
      else if(fieldId == 2) {
        p += _read_fspAddress(p, bs, r, counters);
      }
      else if(fieldId == 3) {
        p += _read_active(p, bs, r, counters);
      }
      else if(fieldId == 4) {
        p += _read_creation(p, bs, r, counters);
      }
      else if(fieldId == 5) {
        p += _read_expiration(p, bs, r, counters);
      }
    }

    return (r, sz);
  }

  // field readers

  function _read_instrumentAddress(uint p, bytes memory bs, Data memory r, uint[6] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufParser._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.instrumentAddress = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }
  function _read_fspAddress(uint p, bytes memory bs, Data memory r, uint[6] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufParser._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[2] += 1;
    } else {
      r.fspAddress = x;
      if(counters[2] > 0) counters[2] -= 1;
    }
    return sz;
  }
  function _read_active(uint p, bytes memory bs, Data memory r, uint[6] memory counters) internal pure returns (uint) {
    (bool x, uint sz) = ProtoBufParser._decode_bool(p, bs);
    if(isNil(r)) {
      counters[3] += 1;
    } else {
      r.active = x;
      if(counters[3] > 0) counters[3] -= 1;
    }
    return sz;
  }
  function _read_creation(uint p, bytes memory bs, Data memory r, uint[6] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufParser._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[4] += 1;
    } else {
      r.creation = x;
      if(counters[4] > 0) counters[4] -= 1;
    }
    return sz;
  }
  function _read_expiration(uint p, bytes memory bs, Data memory r, uint[6] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufParser._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[5] += 1;
    } else {
      r.expiration = x;
      if(counters[5] > 0) counters[5] -= 1;
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


    p += ProtoBufParser._encode_key(1, ProtoBufParser.WireType.LengthDelim, p, bs);
    p += ProtoBufParser._encode_sol_address(r.instrumentAddress, p, bs);
    p += ProtoBufParser._encode_key(2, ProtoBufParser.WireType.LengthDelim, p, bs);
    p += ProtoBufParser._encode_sol_address(r.fspAddress, p, bs);
    p += ProtoBufParser._encode_key(3, ProtoBufParser.WireType.Varint, p, bs);
    p += ProtoBufParser._encode_bool(r.active, p, bs);
    p += ProtoBufParser._encode_key(4, ProtoBufParser.WireType.LengthDelim, p, bs);
    p += ProtoBufParser._encode_sol_uint256(r.creation, p, bs);
    p += ProtoBufParser._encode_key(5, ProtoBufParser.WireType.LengthDelim, p, bs);
    p += ProtoBufParser._encode_sol_uint256(r.expiration, p, bs);
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


    e += 1 + 23;
    e += 1 + 23;
    e += 1 + 1;
    e += 1 + 35;
    e += 1 + 35;
    return e;
  }

    //store function
  function store(Data memory input, Data storage output) internal {
    output.instrumentAddress = input.instrumentAddress;
    output.fspAddress = input.fspAddress;
    output.active = input.active;
    output.creation = input.creation;
    output.expiration = input.expiration;

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
//library InstrumentStatus

library FSPStatus {

  //enum definition


  //struct definition
  struct Data {
    address fspAddress;
    address[] instrumentAddresses;
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
    uint[3] memory counters;
    uint fieldId;
    ProtoBufParser.WireType wireType;
    uint bytesRead;
    uint offset = p;
    while(p < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufParser._decode_key(p, bs);
      p += bytesRead;

      if(fieldId == 1) {
        p += _read_fspAddress(p, bs, r, counters);
      }
      else if(fieldId == 2) {
        p += _read_instrumentAddresses(p, bs, nil(), counters);
      }
    }

    p = offset;

    r.instrumentAddresses = new address[](counters[2]);

    while(p < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufParser._decode_key(p, bs);
      p += bytesRead;

      if(fieldId == 1) {
        p += _read_fspAddress(p, bs, nil(), counters);
      }
      else if(fieldId == 2) {
        p += _read_instrumentAddresses(p, bs, r, counters);
      }
    }
    return (r, sz);
  }

  // field readers

  function _read_fspAddress(uint p, bytes memory bs, Data memory r, uint[3] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufParser._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.fspAddress = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }
  function _read_instrumentAddresses(uint p, bytes memory bs, Data memory r, uint[3] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufParser._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[2] += 1;
    } else {
      r.instrumentAddresses[ r.instrumentAddresses.length - counters[2] ] = x;
      if(counters[2] > 0) counters[2] -= 1;
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
    uint i;

    p += ProtoBufParser._encode_key(1, ProtoBufParser.WireType.LengthDelim, p, bs);
    p += ProtoBufParser._encode_sol_address(r.fspAddress, p, bs);
    for(i = 0; i < r.instrumentAddresses.length; i++) {
      p += ProtoBufParser._encode_key(2, ProtoBufParser.WireType.LengthDelim, p, bs);
      p += ProtoBufParser._encode_sol_address(r.instrumentAddresses[i], p, bs);
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

    e += 1 + 23;
    for(i = 0; i < r.instrumentAddresses.length; i++) {
      e+= 1 + 23;
    }
    return e;
  }

    //store function
  function store(Data memory input, Data storage output) internal {
    output.fspAddress = input.fspAddress;
    output.instrumentAddresses = input.instrumentAddresses;

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
//library FSPStatus
