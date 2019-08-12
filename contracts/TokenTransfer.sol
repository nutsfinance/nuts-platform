pragma solidity ^0.5.0;
import "./ProtoBufRuntime.sol";

library Transfer {


  //struct definition
  struct Data {
    bool isEther;
    address tokenAddress;
    address receiverAddress;
    uint256 amount;
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
    uint[5] memory counters;
    uint fieldId;
    ProtoBufRuntime.WireType wireType;
    uint bytesRead;
    uint offset = p;
    uint pointer = p;
    while(pointer < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if(fieldId == 1) {
        pointer += _read_isEther(pointer, bs, r, counters);
      }
      else if(fieldId == 2) {
        pointer += _read_tokenAddress(pointer, bs, r, counters);
      }
      else if(fieldId == 3) {
        pointer += _read_receiverAddress(pointer, bs, r, counters);
      }
      else if(fieldId == 4) {
        pointer += _read_amount(pointer, bs, r, counters);
      }
    }
    return (r, sz);
  }

  // field readers

  function _read_isEther(uint p, bytes memory bs, Data memory r, uint[5] memory counters) internal pure returns (uint) {
    (bool x, uint sz) = ProtoBufRuntime._decode_bool(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.isEther = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }

  function _read_tokenAddress(uint p, bytes memory bs, Data memory r, uint[5] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[2] += 1;
    } else {
      r.tokenAddress = x;
      if(counters[2] > 0) counters[2] -= 1;
    }
    return sz;
  }

  function _read_receiverAddress(uint p, bytes memory bs, Data memory r, uint[5] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[3] += 1;
    } else {
      r.receiverAddress = x;
      if(counters[3] > 0) counters[3] -= 1;
    }
    return sz;
  }

  function _read_amount(uint p, bytes memory bs, Data memory r, uint[5] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[4] += 1;
    } else {
      r.amount = x;
      if(counters[4] > 0) counters[4] -= 1;
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
    
    pointer += ProtoBufRuntime._encode_key(1, ProtoBufRuntime.WireType.Varint, pointer, bs);
    pointer += ProtoBufRuntime._encode_bool(r.isEther, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(2, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.tokenAddress, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(3, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.receiverAddress, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(4, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.amount, pointer, bs);
    return pointer - offset;
  }
  // nested encoder

  function _encode_nested(Data memory r, uint p, bytes memory bs)
      internal pure returns (uint) {
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

  function _estimate(Data memory /* r */) internal pure returns (uint) {
    uint e;
    e += 1 + 1;
    e += 1 + 23;
    e += 1 + 23;
    e += 1 + 35;
    return e;
  }

  //store function
  function store(Data memory input, Data storage output) internal {
    output.isEther = input.isEther;
    output.tokenAddress = input.tokenAddress;
    output.receiverAddress = input.receiverAddress;
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
//library Transfer

library Transfers {


  //struct definition
  struct Data {
    Transfer.Data[] actions;
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
        pointer += _read_actions(pointer, bs, nil(), counters);
      }
    }
    pointer = offset;
    r.actions = new Transfer.Data[](counters[1]);

    while(pointer < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if(fieldId == 1) {
        pointer += _read_actions(pointer, bs, r, counters);
      }
    }
    return (r, sz);
  }

  // field readers

  function _read_actions(uint p, bytes memory bs, Data memory r, uint[2] memory counters) internal pure returns (uint) {
    (Transfer.Data memory x, uint sz) = _decode_Transfer(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.actions[r.actions.length - counters[1]] = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }

  // struct decoder
  function _decode_Transfer(uint p, bytes memory bs)
      internal pure returns (Transfer.Data memory, uint) {
    uint pointer = p;
    (uint sz, uint bytesRead) = ProtoBufRuntime._decode_varint(pointer, bs);
    pointer += bytesRead;
    (Transfer.Data memory r,) = Transfer._decode(pointer, bs, sz);
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
    uint pointer = p;
    uint i;
    for(i = 0; i < r.actions.length; i++) {
      pointer += ProtoBufRuntime._encode_key(1, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
      pointer += Transfer._encode_nested(r.actions[i], pointer, bs);
    }
    return pointer - offset;
  }
  // nested encoder

  function _encode_nested(Data memory r, uint p, bytes memory bs)
      internal pure returns (uint) {
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

  function _estimate(Data memory r) internal pure returns (uint) {
    uint e;uint i;
    for(i = 0; i < r.actions.length; i++) {
      e += 1 + ProtoBufRuntime._sz_lendelim(Transfer._estimate(r.actions[i]));
    }
    return e;
  }

  //store function
  function store(Data memory input, Data storage output) internal {

    output.actions.length = input.actions.length;
    for(uint i1 = 0; i1 < input.actions.length; i1++) {
      Transfer.store(input.actions[i1], output.actions[i1]);
    }
    

  }


  //array helpers for Actions
  function addActions(Data memory self, Transfer.Data memory value) internal pure {
    Transfer.Data[] memory tmp = new Transfer.Data[](self.actions.length + 1);
    for (uint i = 0; i < self.actions.length; i++) {
      tmp[i] = self.actions[i];
    }
    tmp[self.actions.length] = value;
    self.actions = tmp;
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
//library Transfers