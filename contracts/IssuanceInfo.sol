pragma solidity ^0.5.0;
import "./ProtoBufRuntime.sol";

library CommonProperties {


  //struct definition
  struct Data {
    uint256 issuanceId;
    address instrumentAddress;
    address sellerAddress;
    address storageAddress;
    uint256 created;
    uint256 state;
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
    uint[7] memory counters;
    uint fieldId;
    ProtoBufRuntime.WireType wireType;
    uint bytesRead;
    uint offset = p;
    uint pointer = p;
    while(pointer < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if(fieldId == 1) {
        pointer += _read_issuanceId(pointer, bs, r, counters);
      }
      else if(fieldId == 2) {
        pointer += _read_instrumentAddress(pointer, bs, r, counters);
      }
      else if(fieldId == 3) {
        pointer += _read_sellerAddress(pointer, bs, r, counters);
      }
      else if(fieldId == 4) {
        pointer += _read_storageAddress(pointer, bs, r, counters);
      }
      else if(fieldId == 5) {
        pointer += _read_created(pointer, bs, r, counters);
      }
      else if(fieldId == 6) {
        pointer += _read_state(pointer, bs, r, counters);
      }
    }
    return (r, sz);
  }

  // field readers

  function _read_issuanceId(uint p, bytes memory bs, Data memory r, uint[7] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.issuanceId = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }

  function _read_instrumentAddress(uint p, bytes memory bs, Data memory r, uint[7] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[2] += 1;
    } else {
      r.instrumentAddress = x;
      if(counters[2] > 0) counters[2] -= 1;
    }
    return sz;
  }

  function _read_sellerAddress(uint p, bytes memory bs, Data memory r, uint[7] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[3] += 1;
    } else {
      r.sellerAddress = x;
      if(counters[3] > 0) counters[3] -= 1;
    }
    return sz;
  }

  function _read_storageAddress(uint p, bytes memory bs, Data memory r, uint[7] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[4] += 1;
    } else {
      r.storageAddress = x;
      if(counters[4] > 0) counters[4] -= 1;
    }
    return sz;
  }

  function _read_created(uint p, bytes memory bs, Data memory r, uint[7] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[5] += 1;
    } else {
      r.created = x;
      if(counters[5] > 0) counters[5] -= 1;
    }
    return sz;
  }

  function _read_state(uint p, bytes memory bs, Data memory r, uint[7] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[6] += 1;
    } else {
      r.state = x;
      if(counters[6] > 0) counters[6] -= 1;
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
    pointer += ProtoBufRuntime._encode_sol_uint256(r.issuanceId, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(2, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.instrumentAddress, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(3, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.sellerAddress, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(4, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.storageAddress, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(5, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.created, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(6, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.state, pointer, bs);
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
    e += 1 + 35;
    e += 1 + 23;
    e += 1 + 23;
    e += 1 + 23;
    e += 1 + 35;
    e += 1 + 35;
    return e;
  }

  //store function
  function store(Data memory input, Data storage output) internal {
    output.issuanceId = input.issuanceId;
    output.instrumentAddress = input.instrumentAddress;
    output.sellerAddress = input.sellerAddress;
    output.storageAddress = input.storageAddress;
    output.created = input.created;
    output.state = input.state;

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
//library CommonProperties