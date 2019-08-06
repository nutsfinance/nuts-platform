pragma solidity ^0.5.0;
import "./ProtoBufRuntime.sol";

library InstrumentStatus {


  //struct definition
  struct Data {
    address instrumentAddress;
    address fspAddress;
    bool active;
    uint256 creation;
    uint256 expiration;
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
    uint[6] memory counters;
    uint fieldId;
    ProtoBufRuntime.WireType wireType;
    uint bytesRead;
    uint offset = p;
    uint pointer = p;
    while(pointer < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if(fieldId == 1) {
        pointer += _read_instrumentAddress(pointer, bs, r, counters);
      }
      else if(fieldId == 2) {
        pointer += _read_fspAddress(pointer, bs, r, counters);
      }
      else if(fieldId == 3) {
        pointer += _read_active(pointer, bs, r, counters);
      }
      else if(fieldId == 4) {
        pointer += _read_creation(pointer, bs, r, counters);
      }
      else if(fieldId == 5) {
        pointer += _read_expiration(pointer, bs, r, counters);
      }
    }
    return (r, sz);
  }

  // field readers

  function _read_instrumentAddress(uint p, bytes memory bs, Data memory r, uint[6] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.instrumentAddress = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }

  function _read_fspAddress(uint p, bytes memory bs, Data memory r, uint[6] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[2] += 1;
    } else {
      r.fspAddress = x;
      if(counters[2] > 0) counters[2] -= 1;
    }
    return sz;
  }

  function _read_active(uint p, bytes memory bs, Data memory r, uint[6] memory counters) internal pure returns (uint) {
    (bool x, uint sz) = ProtoBufRuntime._decode_bool(p, bs);
    if(isNil(r)) {
      counters[3] += 1;
    } else {
      r.active = x;
      if(counters[3] > 0) counters[3] -= 1;
    }
    return sz;
  }

  function _read_creation(uint p, bytes memory bs, Data memory r, uint[6] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[4] += 1;
    } else {
      r.creation = x;
      if(counters[4] > 0) counters[4] -= 1;
    }
    return sz;
  }

  function _read_expiration(uint p, bytes memory bs, Data memory r, uint[6] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[5] += 1;
    } else {
      r.expiration = x;
      if(counters[5] > 0) counters[5] -= 1;
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
    uint pointer = p;
    pointer += ProtoBufRuntime._encode_key(1, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.instrumentAddress, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(2, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.fspAddress, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(3, ProtoBufRuntime.WireType.Varint, pointer, bs);
    pointer += ProtoBufRuntime._encode_bool(r.active, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(4, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.creation, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(5, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.expiration, pointer, bs);
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


  //struct definition
  struct Data {
    address fspAddress;
    address[] instrumentAddresses;
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
        pointer += _read_fspAddress(pointer, bs, r, counters);
      }
      else if(fieldId == 2) {
        pointer += _read_instrumentAddresses(pointer, bs, nil(), counters);
      }
    }
    pointer = offset;
    r.instrumentAddresses = new address[](counters[2]);

    while(pointer < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if(fieldId == 1) {
        pointer += _read_fspAddress(pointer, bs, nil(), counters);
      }
      else if(fieldId == 2) {
        pointer += _read_instrumentAddresses(pointer, bs, r, counters);
      }
    }
    return (r, sz);
  }

  // field readers

  function _read_fspAddress(uint p, bytes memory bs, Data memory r, uint[3] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.fspAddress = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }

  function _read_instrumentAddresses(uint p, bytes memory bs, Data memory r, uint[3] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[2] += 1;
    } else {
      r.instrumentAddresses[r.instrumentAddresses.length - counters[2]] = x;
      if(counters[2] > 0) counters[2] -= 1;
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
    pointer += ProtoBufRuntime._encode_key(1, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.fspAddress, pointer, bs);
    for(i = 0; i < r.instrumentAddresses.length; i++) {
      pointer += ProtoBufRuntime._encode_key(2, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
      pointer += ProtoBufRuntime._encode_sol_address(r.instrumentAddresses[i], pointer, bs);
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
    e += 1 + 23;
    for(i = 0; i < r.instrumentAddresses.length; i++) {
      e += 1 + 23;
    }
    return e;
  }

  //store function
  function store(Data memory input, Data storage output) internal {
    output.fspAddress = input.fspAddress;
    output.instrumentAddresses = input.instrumentAddresses;

  }


  //array helpers for InstrumentAddresses
  function addInstrumentAddresses(Data memory self, address  value) internal pure {
    address[] memory tmp = new address[](self.instrumentAddresses.length + 1);
    for (uint i = 0; i < self.instrumentAddresses.length; i++) {
      tmp[i] = self.instrumentAddresses[i];
    }
    tmp[self.instrumentAddresses.length] = value;
    self.instrumentAddresses = tmp;
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