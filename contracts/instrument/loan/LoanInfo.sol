pragma solidity ^0.5.0;
import "../../ProtoBufRuntime.sol";

library SellerParameters {


  //struct definition
  struct Data {
    address collateralTokenAddress;
    uint256 collateralTokenAmount;
    uint256 borrowAmount;
    uint32 depositDueDays;
    uint32 collateralDueDays;
    uint32 engagementDueDays;
    uint32 tenorDays;
    uint32 interestRate;
    uint32 gracePeriod;
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
    uint[10] memory counters;
    uint fieldId;
    ProtoBufRuntime.WireType wireType;
    uint bytesRead;
    uint offset = p;
    uint pointer = p;
    while(pointer < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if(fieldId == 1) {
        pointer += _read_collateralTokenAddress(pointer, bs, r, counters);
      }
      else if(fieldId == 2) {
        pointer += _read_collateralTokenAmount(pointer, bs, r, counters);
      }
      else if(fieldId == 3) {
        pointer += _read_borrowAmount(pointer, bs, r, counters);
      }
      else if(fieldId == 4) {
        pointer += _read_depositDueDays(pointer, bs, r, counters);
      }
      else if(fieldId == 5) {
        pointer += _read_collateralDueDays(pointer, bs, r, counters);
      }
      else if(fieldId == 6) {
        pointer += _read_engagementDueDays(pointer, bs, r, counters);
      }
      else if(fieldId == 7) {
        pointer += _read_tenorDays(pointer, bs, r, counters);
      }
      else if(fieldId == 8) {
        pointer += _read_interestRate(pointer, bs, r, counters);
      }
      else if(fieldId == 9) {
        pointer += _read_gracePeriod(pointer, bs, r, counters);
      }
    }
    return (r, sz);
  }

  // field readers

  function _read_collateralTokenAddress(uint p, bytes memory bs, Data memory r, uint[10] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.collateralTokenAddress = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }

  function _read_collateralTokenAmount(uint p, bytes memory bs, Data memory r, uint[10] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[2] += 1;
    } else {
      r.collateralTokenAmount = x;
      if(counters[2] > 0) counters[2] -= 1;
    }
    return sz;
  }

  function _read_borrowAmount(uint p, bytes memory bs, Data memory r, uint[10] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[3] += 1;
    } else {
      r.borrowAmount = x;
      if(counters[3] > 0) counters[3] -= 1;
    }
    return sz;
  }

  function _read_depositDueDays(uint p, bytes memory bs, Data memory r, uint[10] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[4] += 1;
    } else {
      r.depositDueDays = x;
      if(counters[4] > 0) counters[4] -= 1;
    }
    return sz;
  }

  function _read_collateralDueDays(uint p, bytes memory bs, Data memory r, uint[10] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[5] += 1;
    } else {
      r.collateralDueDays = x;
      if(counters[5] > 0) counters[5] -= 1;
    }
    return sz;
  }

  function _read_engagementDueDays(uint p, bytes memory bs, Data memory r, uint[10] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[6] += 1;
    } else {
      r.engagementDueDays = x;
      if(counters[6] > 0) counters[6] -= 1;
    }
    return sz;
  }

  function _read_tenorDays(uint p, bytes memory bs, Data memory r, uint[10] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[7] += 1;
    } else {
      r.tenorDays = x;
      if(counters[7] > 0) counters[7] -= 1;
    }
    return sz;
  }

  function _read_interestRate(uint p, bytes memory bs, Data memory r, uint[10] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[8] += 1;
    } else {
      r.interestRate = x;
      if(counters[8] > 0) counters[8] -= 1;
    }
    return sz;
  }

  function _read_gracePeriod(uint p, bytes memory bs, Data memory r, uint[10] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[9] += 1;
    } else {
      r.gracePeriod = x;
      if(counters[9] > 0) counters[9] -= 1;
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
    pointer += ProtoBufRuntime._encode_sol_address(r.collateralTokenAddress, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(2, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.collateralTokenAmount, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(3, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.borrowAmount, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(4, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.depositDueDays, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(5, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.collateralDueDays, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(6, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.engagementDueDays, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(7, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.tenorDays, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(8, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.interestRate, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(9, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.gracePeriod, pointer, bs);
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
    e += 1 + 23;
    e += 1 + 35;
    e += 1 + 35;
    e += 1 + 7;
    e += 1 + 7;
    e += 1 + 7;
    e += 1 + 7;
    e += 1 + 7;
    e += 1 + 7;
    return e;
  }

  //store function
  function store(Data memory input, Data storage output) internal {
    output.collateralTokenAddress = input.collateralTokenAddress;
    output.collateralTokenAmount = input.collateralTokenAmount;
    output.borrowAmount = input.borrowAmount;
    output.depositDueDays = input.depositDueDays;
    output.collateralDueDays = input.collateralDueDays;
    output.engagementDueDays = input.engagementDueDays;
    output.tenorDays = input.tenorDays;
    output.interestRate = input.interestRate;
    output.gracePeriod = input.gracePeriod;

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
    address sellerAddress;
    uint256 startDate;
    address collateralTokenAddress;
    uint256 collateralTokenAmount;
    uint256 borrowAmount;
    uint32 collateralDueDays;
    uint32 engagementDueDays;
    uint32 tenorDays;
    uint32 interestRate;
    uint32 gracePeriod;
    bool collateralComplete;
    uint256 interest;
    address buyerAddress;
    uint256 engageDate;
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
    uint[15] memory counters;
    uint fieldId;
    ProtoBufRuntime.WireType wireType;
    uint bytesRead;
    uint offset = p;
    uint pointer = p;
    while(pointer < offset+sz) {
      (fieldId, wireType, bytesRead) = ProtoBufRuntime._decode_key(pointer, bs);
      pointer += bytesRead;
      if(fieldId == 1) {
        pointer += _read_sellerAddress(pointer, bs, r, counters);
      }
      else if(fieldId == 2) {
        pointer += _read_startDate(pointer, bs, r, counters);
      }
      else if(fieldId == 3) {
        pointer += _read_collateralTokenAddress(pointer, bs, r, counters);
      }
      else if(fieldId == 4) {
        pointer += _read_collateralTokenAmount(pointer, bs, r, counters);
      }
      else if(fieldId == 5) {
        pointer += _read_borrowAmount(pointer, bs, r, counters);
      }
      else if(fieldId == 6) {
        pointer += _read_collateralDueDays(pointer, bs, r, counters);
      }
      else if(fieldId == 7) {
        pointer += _read_engagementDueDays(pointer, bs, r, counters);
      }
      else if(fieldId == 8) {
        pointer += _read_tenorDays(pointer, bs, r, counters);
      }
      else if(fieldId == 9) {
        pointer += _read_interestRate(pointer, bs, r, counters);
      }
      else if(fieldId == 10) {
        pointer += _read_gracePeriod(pointer, bs, r, counters);
      }
      else if(fieldId == 11) {
        pointer += _read_collateralComplete(pointer, bs, r, counters);
      }
      else if(fieldId == 12) {
        pointer += _read_interest(pointer, bs, r, counters);
      }
      else if(fieldId == 13) {
        pointer += _read_buyerAddress(pointer, bs, r, counters);
      }
      else if(fieldId == 14) {
        pointer += _read_engageDate(pointer, bs, r, counters);
      }
    }
    return (r, sz);
  }

  // field readers

  function _read_sellerAddress(uint p, bytes memory bs, Data memory r, uint[15] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[1] += 1;
    } else {
      r.sellerAddress = x;
      if(counters[1] > 0) counters[1] -= 1;
    }
    return sz;
  }

  function _read_startDate(uint p, bytes memory bs, Data memory r, uint[15] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[2] += 1;
    } else {
      r.startDate = x;
      if(counters[2] > 0) counters[2] -= 1;
    }
    return sz;
  }

  function _read_collateralTokenAddress(uint p, bytes memory bs, Data memory r, uint[15] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[3] += 1;
    } else {
      r.collateralTokenAddress = x;
      if(counters[3] > 0) counters[3] -= 1;
    }
    return sz;
  }

  function _read_collateralTokenAmount(uint p, bytes memory bs, Data memory r, uint[15] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[4] += 1;
    } else {
      r.collateralTokenAmount = x;
      if(counters[4] > 0) counters[4] -= 1;
    }
    return sz;
  }

  function _read_borrowAmount(uint p, bytes memory bs, Data memory r, uint[15] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[5] += 1;
    } else {
      r.borrowAmount = x;
      if(counters[5] > 0) counters[5] -= 1;
    }
    return sz;
  }

  function _read_collateralDueDays(uint p, bytes memory bs, Data memory r, uint[15] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[6] += 1;
    } else {
      r.collateralDueDays = x;
      if(counters[6] > 0) counters[6] -= 1;
    }
    return sz;
  }

  function _read_engagementDueDays(uint p, bytes memory bs, Data memory r, uint[15] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[7] += 1;
    } else {
      r.engagementDueDays = x;
      if(counters[7] > 0) counters[7] -= 1;
    }
    return sz;
  }

  function _read_tenorDays(uint p, bytes memory bs, Data memory r, uint[15] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[8] += 1;
    } else {
      r.tenorDays = x;
      if(counters[8] > 0) counters[8] -= 1;
    }
    return sz;
  }

  function _read_interestRate(uint p, bytes memory bs, Data memory r, uint[15] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[9] += 1;
    } else {
      r.interestRate = x;
      if(counters[9] > 0) counters[9] -= 1;
    }
    return sz;
  }

  function _read_gracePeriod(uint p, bytes memory bs, Data memory r, uint[15] memory counters) internal pure returns (uint) {
    (uint32 x, uint sz) = ProtoBufRuntime._decode_sol_uint32(p, bs);
    if(isNil(r)) {
      counters[10] += 1;
    } else {
      r.gracePeriod = x;
      if(counters[10] > 0) counters[10] -= 1;
    }
    return sz;
  }

  function _read_collateralComplete(uint p, bytes memory bs, Data memory r, uint[15] memory counters) internal pure returns (uint) {
    (bool x, uint sz) = ProtoBufRuntime._decode_bool(p, bs);
    if(isNil(r)) {
      counters[11] += 1;
    } else {
      r.collateralComplete = x;
      if(counters[11] > 0) counters[11] -= 1;
    }
    return sz;
  }

  function _read_interest(uint p, bytes memory bs, Data memory r, uint[15] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[12] += 1;
    } else {
      r.interest = x;
      if(counters[12] > 0) counters[12] -= 1;
    }
    return sz;
  }

  function _read_buyerAddress(uint p, bytes memory bs, Data memory r, uint[15] memory counters) internal pure returns (uint) {
    (address x, uint sz) = ProtoBufRuntime._decode_sol_address(p, bs);
    if(isNil(r)) {
      counters[13] += 1;
    } else {
      r.buyerAddress = x;
      if(counters[13] > 0) counters[13] -= 1;
    }
    return sz;
  }

  function _read_engageDate(uint p, bytes memory bs, Data memory r, uint[15] memory counters) internal pure returns (uint) {
    (uint256 x, uint sz) = ProtoBufRuntime._decode_sol_uint256(p, bs);
    if(isNil(r)) {
      counters[14] += 1;
    } else {
      r.engageDate = x;
      if(counters[14] > 0) counters[14] -= 1;
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
    pointer += ProtoBufRuntime._encode_sol_address(r.sellerAddress, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(2, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.startDate, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(3, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.collateralTokenAddress, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(4, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.collateralTokenAmount, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(5, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.borrowAmount, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(6, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.collateralDueDays, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(7, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.engagementDueDays, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(8, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.tenorDays, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(9, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.interestRate, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(10, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint32(r.gracePeriod, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(11, ProtoBufRuntime.WireType.Varint, pointer, bs);
    pointer += ProtoBufRuntime._encode_bool(r.collateralComplete, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(12, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.interest, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(13, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_address(r.buyerAddress, pointer, bs);
    pointer += ProtoBufRuntime._encode_key(14, ProtoBufRuntime.WireType.LengthDelim, pointer, bs);
    pointer += ProtoBufRuntime._encode_sol_uint256(r.engageDate, pointer, bs);
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
    e += 1 + 1;
    e += 1 + 35;
    e += 1 + 23;
    e += 1 + 35;
    return e;
  }

  //store function
  function store(Data memory input, Data storage output) internal {
    output.sellerAddress = input.sellerAddress;
    output.startDate = input.startDate;
    output.collateralTokenAddress = input.collateralTokenAddress;
    output.collateralTokenAmount = input.collateralTokenAmount;
    output.borrowAmount = input.borrowAmount;
    output.collateralDueDays = input.collateralDueDays;
    output.engagementDueDays = input.engagementDueDays;
    output.tenorDays = input.tenorDays;
    output.interestRate = input.interestRate;
    output.gracePeriod = input.gracePeriod;
    output.collateralComplete = input.collateralComplete;
    output.interest = input.interest;
    output.buyerAddress = input.buyerAddress;
    output.engageDate = input.engageDate;

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
