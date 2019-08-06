pragma solidity ^0.5.0;
import "../../ProtoBufRuntime.sol";

library SellerParameters {


  //struct definition
  struct Data {
    address seller_address;
    uint256 start_date;
    address collateral_token_address;
    uint256 collateral_token_amount;
    uint256 borrow_amount;
    uint32 collateral_due_days;
    uint32 engagement_due_days;
    uint32 tenor_days;
    uint32 interest_rate;
    uint32 grace_period;
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
        pointer += _read_seller_address(pointer, bs, r, counters);
      }
      else if(fieldId == 2) {
        pointer += _read_start_date(pointer, bs, r, counters);
      }
      else if(fieldId == 3) {
        pointer += _read_collateral_token_address(pointer, bs, r, counters);
      }
      else if(fieldId == 4) {
        pointer += _read_collateral_token_amount(pointer, bs, r, counters);
      }
      else if(fieldId == 5) {
        pointer += _read_borrow_amount(pointer, bs, r, counters);
      }
      else if(fieldId == 6) {
        pointer += _read_collateral_due_days(pointer, bs, r, counters);
      }
      else if(fieldId == 7) {
        pointer += _read_engagement_due_days(pointer, bs, r, counters);
      }
      else if(fieldId == 8) {
        pointer += _read_tenor_days(pointer, bs, r, counters);
      }
      else if(fieldId == 9) {
        pointer += _read_interest_rate(pointer, bs, r, counters);
      }
      else if(fieldId == 10) {
        pointer += _read_grace_period(pointer, bs, r, counters);
      }
    }
    return (r, sz);
  }

  // field readers

  function _read_seller_address(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.seller_address = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }

  function _read_start_date(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[2] += 1;
    } else {
      r.start_date = x;
      if(counters[2] > 0) counters[2] -= 1;
    }
    return sz;
  }

  function _read_collateral_token_address(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[3] += 1;
    } else {
      r.collateral_token_address = x;
      if(counters[3] > 0) counters[3] -= 1;
    }
    return sz;
  }

  function _read_collateral_token_amount(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[4] += 1;
    } else {
      r.collateral_token_amount = x;
      if(counters[4] > 0) counters[4] -= 1;
    }
    return sz;
  }

  function _read_borrow_amount(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[5] += 1;
    } else {
      r.borrow_amount = x;
      if(counters[5] > 0) counters[5] -= 1;
    }
    return sz;
  }

  function _read_collateral_due_days(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[6] += 1;
    } else {
      r.collateral_due_days = x;
      if(counters[6] > 0) counters[6] -= 1;
    }
    return sz;
  }

  function _read_engagement_due_days(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[7] += 1;
    } else {
      r.engagement_due_days = x;
      if(counters[7] > 0) counters[7] -= 1;
    }
    return sz;
  }

  function _read_tenor_days(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[8] += 1;
    } else {
      r.tenor_days = x;
      if(counters[8] > 0) counters[8] -= 1;
    }
    return sz;
  }

  function _read_interest_rate(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[9] += 1;
    } else {
      r.interest_rate = x;
      if(counters[9] > 0) counters[9] -= 1;
    }
    return sz;
  }

  function _read_grace_period(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[10] += 1;
    } else {
      r.grace_period = x;
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
    uint pointer = p;
    pointer += ProtoBufRuntime._encode_key(1, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.seller_address, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(2, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.start_date, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(3, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.collateral_token_address, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(4, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.collateral_token_amount, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(5, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.borrow_amount, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(6, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.collateral_due_days, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(7, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.engagement_due_days, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(8, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.tenor_days, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(9, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.interest_rate, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(10, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.grace_period, pointer, bs);
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
    e += 1 + 35;
    e += 1 + 23;
    e += 1 + 35;
    e += 1 + 35;
    e += 1 + 7;
    e += 1 + 7;
    e += 1 + 7;
    e += 1 + 7;
    e += 1 + 7;
    return e;
  }

  //store function
  function store(Data memory input, Data storage output) internal {
    output.seller_address = input.seller_address;
    output.start_date = input.start_date;
    output.collateral_token_address = input.collateral_token_address;
    output.collateral_token_amount = input.collateral_token_amount;
    output.borrow_amount = input.borrow_amount;
    output.collateral_due_days = input.collateral_due_days;
    output.engagement_due_days = input.engagement_due_days;
    output.tenor_days = input.tenor_days;
    output.interest_rate = input.interest_rate;
    output.grace_period = input.grace_period;

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
//library SellerParameters

library LoanProperties {


  //struct definition
  struct Data {
    address collateral_token_address;
    uint256 collateral_token_amount;
    uint256 borrow_amount;
    uint32 deposit_due_days;
    uint32 collateral_due_days;
    uint32 engagement_due_days;
    uint32 tenor_days;
    uint32 interest_rate;
    uint32 grace_period;
    bool collateral_complete;
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
        pointer += _read_collateral_token_address(pointer, bs, r, counters);
      }
      else if(fieldId == 2) {
        pointer += _read_collateral_token_amount(pointer, bs, r, counters);
      }
      else if(fieldId == 3) {
        pointer += _read_borrow_amount(pointer, bs, r, counters);
      }
      else if(fieldId == 4) {
        pointer += _read_deposit_due_days(pointer, bs, r, counters);
      }
      else if(fieldId == 5) {
        pointer += _read_collateral_due_days(pointer, bs, r, counters);
      }
      else if(fieldId == 6) {
        pointer += _read_engagement_due_days(pointer, bs, r, counters);
      }
      else if(fieldId == 7) {
        pointer += _read_tenor_days(pointer, bs, r, counters);
      }
      else if(fieldId == 8) {
        pointer += _read_interest_rate(pointer, bs, r, counters);
      }
      else if(fieldId == 9) {
        pointer += _read_grace_period(pointer, bs, r, counters);
      }
      else if(fieldId == 10) {
        pointer += _read_collateral_complete(pointer, bs, r, counters);
      }
    }
    return (r, sz);
  }

  // field readers

  function _read_collateral_token_address(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.collateral_token_address = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }

  function _read_collateral_token_amount(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[2] += 1;
    } else {
      r.collateral_token_amount = x;
      if(counters[2] > 0) counters[2] -= 1;
    }
    return sz;
  }

  function _read_borrow_amount(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[3] += 1;
    } else {
      r.borrow_amount = x;
      if(counters[3] > 0) counters[3] -= 1;
    }
    return sz;
  }

  function _read_deposit_due_days(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[4] += 1;
    } else {
      r.deposit_due_days = x;
      if(counters[4] > 0) counters[4] -= 1;
    }
    return sz;
  }

  function _read_collateral_due_days(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[5] += 1;
    } else {
      r.collateral_due_days = x;
      if(counters[5] > 0) counters[5] -= 1;
    }
    return sz;
  }

  function _read_engagement_due_days(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[6] += 1;
    } else {
      r.engagement_due_days = x;
      if(counters[6] > 0) counters[6] -= 1;
    }
    return sz;
  }

  function _read_tenor_days(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[7] += 1;
    } else {
      r.tenor_days = x;
      if(counters[7] > 0) counters[7] -= 1;
    }
    return sz;
  }

  function _read_interest_rate(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[8] += 1;
    } else {
      r.interest_rate = x;
      if(counters[8] > 0) counters[8] -= 1;
    }
    return sz;
  }

  function _read_grace_period(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[9] += 1;
    } else {
      r.grace_period = x;
      if(counters[9] > 0) counters[9] -= 1;
    }
    return sz;
  }

  function _read_collateral_complete(uint p, bytes memory bs, Data memory r, uint[11] memory counters) internal pure returns (uint) {
    (bool x, uint sz) = ProtoBufRuntime._decode_bool(p, bs);
    if(isNil(r)) {
      counters[10] += 1;
    } else {
      r.collateral_complete = x;
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
    uint pointer = p;
    pointer += ProtoBufRuntime._encode_key(1, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.collateral_token_address, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(2, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.collateral_token_amount, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(3, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.borrow_amount, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(4, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.deposit_due_days, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(5, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.collateral_due_days, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(6, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.engagement_due_days, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(7, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.tenor_days, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(8, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.interest_rate, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(9, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.grace_period, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(10, ProtoBufRuntime.WireType.Varint, pointer, bs);
    pointer += ProtoBufRuntime._encode_bool(r.collateral_complete, pointer, bs);
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
    e += 1 + 35;
    e += 1 + 35;
    e += 1 + 7;
    e += 1 + 7;
    e += 1 + 7;
    e += 1 + 7;
    e += 1 + 7;
    e += 1 + 7;
    e += 1 + 1;
    return e;
  }

  //store function
  function store(Data memory input, Data storage output) internal {
    output.collateral_token_address = input.collateral_token_address;
    output.collateral_token_amount = input.collateral_token_amount;
    output.borrow_amount = input.borrow_amount;
    output.deposit_due_days = input.deposit_due_days;
    output.collateral_due_days = input.collateral_due_days;
    output.engagement_due_days = input.engagement_due_days;
    output.tenor_days = input.tenor_days;
    output.interest_rate = input.interest_rate;
    output.grace_period = input.grace_period;
    output.collateral_complete = input.collateral_complete;

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
//library LoanProperties