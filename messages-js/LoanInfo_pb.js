/**
 * @fileoverview
 * @enhanceable
 * @suppress {messageConventions} JS Compiler reports an error if a variable or
 *     field starts with 'MSG_' and isn't a translatable message.
 * @public
 */
// GENERATED CODE -- DO NOT EDIT!

var jspb = require('google-protobuf');
var goog = jspb;
var global = Function('return this')();

var SolidityTypes_pb = require('./SolidityTypes_pb.js');
goog.object.extend(proto, SolidityTypes_pb);
goog.exportSymbol('proto.LoanProperties', null, global);
goog.exportSymbol('proto.SellerParameters', null, global);
/**
 * Generated by JsPbCodeGenerator.
 * @param {Array=} opt_data Optional initial data array, typically from a
 * server response, or constructed directly in Javascript. The array is used
 * in place and becomes part of the constructed object. It is not cloned.
 * If no data is provided, the constructed object will be empty, but still
 * valid.
 * @extends {jspb.Message}
 * @constructor
 */
proto.SellerParameters = function(opt_data) {
  jspb.Message.initialize(this, opt_data, 0, -1, null, null);
};
goog.inherits(proto.SellerParameters, jspb.Message);
if (goog.DEBUG && !COMPILED) {
  /**
   * @public
   * @override
   */
  proto.SellerParameters.displayName = 'proto.SellerParameters';
}
/**
 * Generated by JsPbCodeGenerator.
 * @param {Array=} opt_data Optional initial data array, typically from a
 * server response, or constructed directly in Javascript. The array is used
 * in place and becomes part of the constructed object. It is not cloned.
 * If no data is provided, the constructed object will be empty, but still
 * valid.
 * @extends {jspb.Message}
 * @constructor
 */
proto.LoanProperties = function(opt_data) {
  jspb.Message.initialize(this, opt_data, 0, -1, null, null);
};
goog.inherits(proto.LoanProperties, jspb.Message);
if (goog.DEBUG && !COMPILED) {
  /**
   * @public
   * @override
   */
  proto.LoanProperties.displayName = 'proto.LoanProperties';
}



if (jspb.Message.GENERATE_TO_OBJECT) {
/**
 * Creates an object representation of this proto suitable for use in Soy templates.
 * Field names that are reserved in JavaScript and will be renamed to pb_name.
 * To access a reserved field use, foo.pb_<name>, eg, foo.pb_default.
 * For the list of reserved names please see:
 *     com.google.apps.jspb.JsClassTemplate.JS_RESERVED_WORDS.
 * @param {boolean=} opt_includeInstance Whether to include the JSPB instance
 *     for transitional soy proto support: http://goto/soy-param-migration
 * @return {!Object}
 */
proto.SellerParameters.prototype.toObject = function(opt_includeInstance) {
  return proto.SellerParameters.toObject(opt_includeInstance, this);
};


/**
 * Static version of the {@see toObject} method.
 * @param {boolean|undefined} includeInstance Whether to include the JSPB
 *     instance for transitional soy proto support:
 *     http://goto/soy-param-migration
 * @param {!proto.SellerParameters} msg The msg instance to transform.
 * @return {!Object}
 * @suppress {unusedLocalVariables} f is only used for nested messages
 */
proto.SellerParameters.toObject = function(includeInstance, msg) {
  var f, obj = {
    collateraltokenaddress: (f = msg.getCollateraltokenaddress()) && SolidityTypes_pb.address.toObject(includeInstance, f),
    collateraltokenamount: (f = msg.getCollateraltokenamount()) && SolidityTypes_pb.uint256.toObject(includeInstance, f),
    borrowamount: (f = msg.getBorrowamount()) && SolidityTypes_pb.uint256.toObject(includeInstance, f),
    depositduedays: (f = msg.getDepositduedays()) && SolidityTypes_pb.uint32.toObject(includeInstance, f),
    collateralduedays: (f = msg.getCollateralduedays()) && SolidityTypes_pb.uint32.toObject(includeInstance, f),
    engagementduedays: (f = msg.getEngagementduedays()) && SolidityTypes_pb.uint32.toObject(includeInstance, f),
    tenordays: (f = msg.getTenordays()) && SolidityTypes_pb.uint32.toObject(includeInstance, f),
    interestrate: (f = msg.getInterestrate()) && SolidityTypes_pb.uint32.toObject(includeInstance, f),
    graceperiod: (f = msg.getGraceperiod()) && SolidityTypes_pb.uint32.toObject(includeInstance, f)
  };

  if (includeInstance) {
    obj.$jspbMessageInstance = msg;
  }
  return obj;
};
}


/**
 * Deserializes binary data (in protobuf wire format).
 * @param {jspb.ByteSource} bytes The bytes to deserialize.
 * @return {!proto.SellerParameters}
 */
proto.SellerParameters.deserializeBinary = function(bytes) {
  var reader = new jspb.BinaryReader(bytes);
  var msg = new proto.SellerParameters;
  return proto.SellerParameters.deserializeBinaryFromReader(msg, reader);
};


/**
 * Deserializes binary data (in protobuf wire format) from the
 * given reader into the given message object.
 * @param {!proto.SellerParameters} msg The message object to deserialize into.
 * @param {!jspb.BinaryReader} reader The BinaryReader to use.
 * @return {!proto.SellerParameters}
 */
proto.SellerParameters.deserializeBinaryFromReader = function(msg, reader) {
  while (reader.nextField()) {
    if (reader.isEndGroup()) {
      break;
    }
    var field = reader.getFieldNumber();
    switch (field) {
    case 1:
      var value = new SolidityTypes_pb.address;
      reader.readMessage(value,SolidityTypes_pb.address.deserializeBinaryFromReader);
      msg.setCollateraltokenaddress(value);
      break;
    case 2:
      var value = new SolidityTypes_pb.uint256;
      reader.readMessage(value,SolidityTypes_pb.uint256.deserializeBinaryFromReader);
      msg.setCollateraltokenamount(value);
      break;
    case 3:
      var value = new SolidityTypes_pb.uint256;
      reader.readMessage(value,SolidityTypes_pb.uint256.deserializeBinaryFromReader);
      msg.setBorrowamount(value);
      break;
    case 4:
      var value = new SolidityTypes_pb.uint32;
      reader.readMessage(value,SolidityTypes_pb.uint32.deserializeBinaryFromReader);
      msg.setDepositduedays(value);
      break;
    case 5:
      var value = new SolidityTypes_pb.uint32;
      reader.readMessage(value,SolidityTypes_pb.uint32.deserializeBinaryFromReader);
      msg.setCollateralduedays(value);
      break;
    case 6:
      var value = new SolidityTypes_pb.uint32;
      reader.readMessage(value,SolidityTypes_pb.uint32.deserializeBinaryFromReader);
      msg.setEngagementduedays(value);
      break;
    case 7:
      var value = new SolidityTypes_pb.uint32;
      reader.readMessage(value,SolidityTypes_pb.uint32.deserializeBinaryFromReader);
      msg.setTenordays(value);
      break;
    case 8:
      var value = new SolidityTypes_pb.uint32;
      reader.readMessage(value,SolidityTypes_pb.uint32.deserializeBinaryFromReader);
      msg.setInterestrate(value);
      break;
    case 9:
      var value = new SolidityTypes_pb.uint32;
      reader.readMessage(value,SolidityTypes_pb.uint32.deserializeBinaryFromReader);
      msg.setGraceperiod(value);
      break;
    default:
      reader.skipField();
      break;
    }
  }
  return msg;
};


/**
 * Serializes the message to binary data (in protobuf wire format).
 * @return {!Uint8Array}
 */
proto.SellerParameters.prototype.serializeBinary = function() {
  var writer = new jspb.BinaryWriter();
  proto.SellerParameters.serializeBinaryToWriter(this, writer);
  return writer.getResultBuffer();
};


/**
 * Serializes the given message to binary data (in protobuf wire
 * format), writing to the given BinaryWriter.
 * @param {!proto.SellerParameters} message
 * @param {!jspb.BinaryWriter} writer
 * @suppress {unusedLocalVariables} f is only used for nested messages
 */
proto.SellerParameters.serializeBinaryToWriter = function(message, writer) {
  var f = undefined;
  f = message.getCollateraltokenaddress();
  if (f != null) {
    writer.writeMessage(
      1,
      f,
      SolidityTypes_pb.address.serializeBinaryToWriter
    );
  }
  f = message.getCollateraltokenamount();
  if (f != null) {
    writer.writeMessage(
      2,
      f,
      SolidityTypes_pb.uint256.serializeBinaryToWriter
    );
  }
  f = message.getBorrowamount();
  if (f != null) {
    writer.writeMessage(
      3,
      f,
      SolidityTypes_pb.uint256.serializeBinaryToWriter
    );
  }
  f = message.getDepositduedays();
  if (f != null) {
    writer.writeMessage(
      4,
      f,
      SolidityTypes_pb.uint32.serializeBinaryToWriter
    );
  }
  f = message.getCollateralduedays();
  if (f != null) {
    writer.writeMessage(
      5,
      f,
      SolidityTypes_pb.uint32.serializeBinaryToWriter
    );
  }
  f = message.getEngagementduedays();
  if (f != null) {
    writer.writeMessage(
      6,
      f,
      SolidityTypes_pb.uint32.serializeBinaryToWriter
    );
  }
  f = message.getTenordays();
  if (f != null) {
    writer.writeMessage(
      7,
      f,
      SolidityTypes_pb.uint32.serializeBinaryToWriter
    );
  }
  f = message.getInterestrate();
  if (f != null) {
    writer.writeMessage(
      8,
      f,
      SolidityTypes_pb.uint32.serializeBinaryToWriter
    );
  }
  f = message.getGraceperiod();
  if (f != null) {
    writer.writeMessage(
      9,
      f,
      SolidityTypes_pb.uint32.serializeBinaryToWriter
    );
  }
};


/**
 * optional solidity.address collateralTokenAddress = 1;
 * @return {?proto.solidity.address}
 */
proto.SellerParameters.prototype.getCollateraltokenaddress = function() {
  return /** @type{?proto.solidity.address} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.address, 1));
};


/** @param {?proto.solidity.address|undefined} value */
proto.SellerParameters.prototype.setCollateraltokenaddress = function(value) {
  jspb.Message.setWrapperField(this, 1, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.SellerParameters.prototype.clearCollateraltokenaddress = function() {
  this.setCollateraltokenaddress(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.SellerParameters.prototype.hasCollateraltokenaddress = function() {
  return jspb.Message.getField(this, 1) != null;
};


/**
 * optional solidity.uint256 collateralTokenAmount = 2;
 * @return {?proto.solidity.uint256}
 */
proto.SellerParameters.prototype.getCollateraltokenamount = function() {
  return /** @type{?proto.solidity.uint256} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint256, 2));
};


/** @param {?proto.solidity.uint256|undefined} value */
proto.SellerParameters.prototype.setCollateraltokenamount = function(value) {
  jspb.Message.setWrapperField(this, 2, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.SellerParameters.prototype.clearCollateraltokenamount = function() {
  this.setCollateraltokenamount(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.SellerParameters.prototype.hasCollateraltokenamount = function() {
  return jspb.Message.getField(this, 2) != null;
};


/**
 * optional solidity.uint256 borrowAmount = 3;
 * @return {?proto.solidity.uint256}
 */
proto.SellerParameters.prototype.getBorrowamount = function() {
  return /** @type{?proto.solidity.uint256} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint256, 3));
};


/** @param {?proto.solidity.uint256|undefined} value */
proto.SellerParameters.prototype.setBorrowamount = function(value) {
  jspb.Message.setWrapperField(this, 3, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.SellerParameters.prototype.clearBorrowamount = function() {
  this.setBorrowamount(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.SellerParameters.prototype.hasBorrowamount = function() {
  return jspb.Message.getField(this, 3) != null;
};


/**
 * optional solidity.uint32 depositDueDays = 4;
 * @return {?proto.solidity.uint32}
 */
proto.SellerParameters.prototype.getDepositduedays = function() {
  return /** @type{?proto.solidity.uint32} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint32, 4));
};


/** @param {?proto.solidity.uint32|undefined} value */
proto.SellerParameters.prototype.setDepositduedays = function(value) {
  jspb.Message.setWrapperField(this, 4, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.SellerParameters.prototype.clearDepositduedays = function() {
  this.setDepositduedays(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.SellerParameters.prototype.hasDepositduedays = function() {
  return jspb.Message.getField(this, 4) != null;
};


/**
 * optional solidity.uint32 collateralDueDays = 5;
 * @return {?proto.solidity.uint32}
 */
proto.SellerParameters.prototype.getCollateralduedays = function() {
  return /** @type{?proto.solidity.uint32} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint32, 5));
};


/** @param {?proto.solidity.uint32|undefined} value */
proto.SellerParameters.prototype.setCollateralduedays = function(value) {
  jspb.Message.setWrapperField(this, 5, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.SellerParameters.prototype.clearCollateralduedays = function() {
  this.setCollateralduedays(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.SellerParameters.prototype.hasCollateralduedays = function() {
  return jspb.Message.getField(this, 5) != null;
};


/**
 * optional solidity.uint32 engagementDueDays = 6;
 * @return {?proto.solidity.uint32}
 */
proto.SellerParameters.prototype.getEngagementduedays = function() {
  return /** @type{?proto.solidity.uint32} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint32, 6));
};


/** @param {?proto.solidity.uint32|undefined} value */
proto.SellerParameters.prototype.setEngagementduedays = function(value) {
  jspb.Message.setWrapperField(this, 6, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.SellerParameters.prototype.clearEngagementduedays = function() {
  this.setEngagementduedays(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.SellerParameters.prototype.hasEngagementduedays = function() {
  return jspb.Message.getField(this, 6) != null;
};


/**
 * optional solidity.uint32 tenorDays = 7;
 * @return {?proto.solidity.uint32}
 */
proto.SellerParameters.prototype.getTenordays = function() {
  return /** @type{?proto.solidity.uint32} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint32, 7));
};


/** @param {?proto.solidity.uint32|undefined} value */
proto.SellerParameters.prototype.setTenordays = function(value) {
  jspb.Message.setWrapperField(this, 7, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.SellerParameters.prototype.clearTenordays = function() {
  this.setTenordays(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.SellerParameters.prototype.hasTenordays = function() {
  return jspb.Message.getField(this, 7) != null;
};


/**
 * optional solidity.uint32 interestRate = 8;
 * @return {?proto.solidity.uint32}
 */
proto.SellerParameters.prototype.getInterestrate = function() {
  return /** @type{?proto.solidity.uint32} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint32, 8));
};


/** @param {?proto.solidity.uint32|undefined} value */
proto.SellerParameters.prototype.setInterestrate = function(value) {
  jspb.Message.setWrapperField(this, 8, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.SellerParameters.prototype.clearInterestrate = function() {
  this.setInterestrate(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.SellerParameters.prototype.hasInterestrate = function() {
  return jspb.Message.getField(this, 8) != null;
};


/**
 * optional solidity.uint32 gracePeriod = 9;
 * @return {?proto.solidity.uint32}
 */
proto.SellerParameters.prototype.getGraceperiod = function() {
  return /** @type{?proto.solidity.uint32} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint32, 9));
};


/** @param {?proto.solidity.uint32|undefined} value */
proto.SellerParameters.prototype.setGraceperiod = function(value) {
  jspb.Message.setWrapperField(this, 9, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.SellerParameters.prototype.clearGraceperiod = function() {
  this.setGraceperiod(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.SellerParameters.prototype.hasGraceperiod = function() {
  return jspb.Message.getField(this, 9) != null;
};





if (jspb.Message.GENERATE_TO_OBJECT) {
/**
 * Creates an object representation of this proto suitable for use in Soy templates.
 * Field names that are reserved in JavaScript and will be renamed to pb_name.
 * To access a reserved field use, foo.pb_<name>, eg, foo.pb_default.
 * For the list of reserved names please see:
 *     com.google.apps.jspb.JsClassTemplate.JS_RESERVED_WORDS.
 * @param {boolean=} opt_includeInstance Whether to include the JSPB instance
 *     for transitional soy proto support: http://goto/soy-param-migration
 * @return {!Object}
 */
proto.LoanProperties.prototype.toObject = function(opt_includeInstance) {
  return proto.LoanProperties.toObject(opt_includeInstance, this);
};


/**
 * Static version of the {@see toObject} method.
 * @param {boolean|undefined} includeInstance Whether to include the JSPB
 *     instance for transitional soy proto support:
 *     http://goto/soy-param-migration
 * @param {!proto.LoanProperties} msg The msg instance to transform.
 * @return {!Object}
 * @suppress {unusedLocalVariables} f is only used for nested messages
 */
proto.LoanProperties.toObject = function(includeInstance, msg) {
  var f, obj = {
    selleraddress: (f = msg.getSelleraddress()) && SolidityTypes_pb.address.toObject(includeInstance, f),
    startdate: (f = msg.getStartdate()) && SolidityTypes_pb.uint256.toObject(includeInstance, f),
    collateraltokenaddress: (f = msg.getCollateraltokenaddress()) && SolidityTypes_pb.address.toObject(includeInstance, f),
    collateraltokenamount: (f = msg.getCollateraltokenamount()) && SolidityTypes_pb.uint256.toObject(includeInstance, f),
    borrowamount: (f = msg.getBorrowamount()) && SolidityTypes_pb.uint256.toObject(includeInstance, f),
    collateralduedays: (f = msg.getCollateralduedays()) && SolidityTypes_pb.uint32.toObject(includeInstance, f),
    engagementduedays: (f = msg.getEngagementduedays()) && SolidityTypes_pb.uint32.toObject(includeInstance, f),
    tenordays: (f = msg.getTenordays()) && SolidityTypes_pb.uint32.toObject(includeInstance, f),
    interestrate: (f = msg.getInterestrate()) && SolidityTypes_pb.uint32.toObject(includeInstance, f),
    graceperiod: (f = msg.getGraceperiod()) && SolidityTypes_pb.uint32.toObject(includeInstance, f),
    collateralcomplete: jspb.Message.getFieldWithDefault(msg, 11, false),
    interest: (f = msg.getInterest()) && SolidityTypes_pb.uint256.toObject(includeInstance, f),
    buyeraddress: (f = msg.getBuyeraddress()) && SolidityTypes_pb.address.toObject(includeInstance, f),
    engagedate: (f = msg.getEngagedate()) && SolidityTypes_pb.uint256.toObject(includeInstance, f)
  };

  if (includeInstance) {
    obj.$jspbMessageInstance = msg;
  }
  return obj;
};
}


/**
 * Deserializes binary data (in protobuf wire format).
 * @param {jspb.ByteSource} bytes The bytes to deserialize.
 * @return {!proto.LoanProperties}
 */
proto.LoanProperties.deserializeBinary = function(bytes) {
  var reader = new jspb.BinaryReader(bytes);
  var msg = new proto.LoanProperties;
  return proto.LoanProperties.deserializeBinaryFromReader(msg, reader);
};


/**
 * Deserializes binary data (in protobuf wire format) from the
 * given reader into the given message object.
 * @param {!proto.LoanProperties} msg The message object to deserialize into.
 * @param {!jspb.BinaryReader} reader The BinaryReader to use.
 * @return {!proto.LoanProperties}
 */
proto.LoanProperties.deserializeBinaryFromReader = function(msg, reader) {
  while (reader.nextField()) {
    if (reader.isEndGroup()) {
      break;
    }
    var field = reader.getFieldNumber();
    switch (field) {
    case 1:
      var value = new SolidityTypes_pb.address;
      reader.readMessage(value,SolidityTypes_pb.address.deserializeBinaryFromReader);
      msg.setSelleraddress(value);
      break;
    case 2:
      var value = new SolidityTypes_pb.uint256;
      reader.readMessage(value,SolidityTypes_pb.uint256.deserializeBinaryFromReader);
      msg.setStartdate(value);
      break;
    case 3:
      var value = new SolidityTypes_pb.address;
      reader.readMessage(value,SolidityTypes_pb.address.deserializeBinaryFromReader);
      msg.setCollateraltokenaddress(value);
      break;
    case 4:
      var value = new SolidityTypes_pb.uint256;
      reader.readMessage(value,SolidityTypes_pb.uint256.deserializeBinaryFromReader);
      msg.setCollateraltokenamount(value);
      break;
    case 5:
      var value = new SolidityTypes_pb.uint256;
      reader.readMessage(value,SolidityTypes_pb.uint256.deserializeBinaryFromReader);
      msg.setBorrowamount(value);
      break;
    case 6:
      var value = new SolidityTypes_pb.uint32;
      reader.readMessage(value,SolidityTypes_pb.uint32.deserializeBinaryFromReader);
      msg.setCollateralduedays(value);
      break;
    case 7:
      var value = new SolidityTypes_pb.uint32;
      reader.readMessage(value,SolidityTypes_pb.uint32.deserializeBinaryFromReader);
      msg.setEngagementduedays(value);
      break;
    case 8:
      var value = new SolidityTypes_pb.uint32;
      reader.readMessage(value,SolidityTypes_pb.uint32.deserializeBinaryFromReader);
      msg.setTenordays(value);
      break;
    case 9:
      var value = new SolidityTypes_pb.uint32;
      reader.readMessage(value,SolidityTypes_pb.uint32.deserializeBinaryFromReader);
      msg.setInterestrate(value);
      break;
    case 10:
      var value = new SolidityTypes_pb.uint32;
      reader.readMessage(value,SolidityTypes_pb.uint32.deserializeBinaryFromReader);
      msg.setGraceperiod(value);
      break;
    case 11:
      var value = /** @type {boolean} */ (reader.readBool());
      msg.setCollateralcomplete(value);
      break;
    case 12:
      var value = new SolidityTypes_pb.uint256;
      reader.readMessage(value,SolidityTypes_pb.uint256.deserializeBinaryFromReader);
      msg.setInterest(value);
      break;
    case 13:
      var value = new SolidityTypes_pb.address;
      reader.readMessage(value,SolidityTypes_pb.address.deserializeBinaryFromReader);
      msg.setBuyeraddress(value);
      break;
    case 14:
      var value = new SolidityTypes_pb.uint256;
      reader.readMessage(value,SolidityTypes_pb.uint256.deserializeBinaryFromReader);
      msg.setEngagedate(value);
      break;
    default:
      reader.skipField();
      break;
    }
  }
  return msg;
};


/**
 * Serializes the message to binary data (in protobuf wire format).
 * @return {!Uint8Array}
 */
proto.LoanProperties.prototype.serializeBinary = function() {
  var writer = new jspb.BinaryWriter();
  proto.LoanProperties.serializeBinaryToWriter(this, writer);
  return writer.getResultBuffer();
};


/**
 * Serializes the given message to binary data (in protobuf wire
 * format), writing to the given BinaryWriter.
 * @param {!proto.LoanProperties} message
 * @param {!jspb.BinaryWriter} writer
 * @suppress {unusedLocalVariables} f is only used for nested messages
 */
proto.LoanProperties.serializeBinaryToWriter = function(message, writer) {
  var f = undefined;
  f = message.getSelleraddress();
  if (f != null) {
    writer.writeMessage(
      1,
      f,
      SolidityTypes_pb.address.serializeBinaryToWriter
    );
  }
  f = message.getStartdate();
  if (f != null) {
    writer.writeMessage(
      2,
      f,
      SolidityTypes_pb.uint256.serializeBinaryToWriter
    );
  }
  f = message.getCollateraltokenaddress();
  if (f != null) {
    writer.writeMessage(
      3,
      f,
      SolidityTypes_pb.address.serializeBinaryToWriter
    );
  }
  f = message.getCollateraltokenamount();
  if (f != null) {
    writer.writeMessage(
      4,
      f,
      SolidityTypes_pb.uint256.serializeBinaryToWriter
    );
  }
  f = message.getBorrowamount();
  if (f != null) {
    writer.writeMessage(
      5,
      f,
      SolidityTypes_pb.uint256.serializeBinaryToWriter
    );
  }
  f = message.getCollateralduedays();
  if (f != null) {
    writer.writeMessage(
      6,
      f,
      SolidityTypes_pb.uint32.serializeBinaryToWriter
    );
  }
  f = message.getEngagementduedays();
  if (f != null) {
    writer.writeMessage(
      7,
      f,
      SolidityTypes_pb.uint32.serializeBinaryToWriter
    );
  }
  f = message.getTenordays();
  if (f != null) {
    writer.writeMessage(
      8,
      f,
      SolidityTypes_pb.uint32.serializeBinaryToWriter
    );
  }
  f = message.getInterestrate();
  if (f != null) {
    writer.writeMessage(
      9,
      f,
      SolidityTypes_pb.uint32.serializeBinaryToWriter
    );
  }
  f = message.getGraceperiod();
  if (f != null) {
    writer.writeMessage(
      10,
      f,
      SolidityTypes_pb.uint32.serializeBinaryToWriter
    );
  }
  f = message.getCollateralcomplete();
  if (f) {
    writer.writeBool(
      11,
      f
    );
  }
  f = message.getInterest();
  if (f != null) {
    writer.writeMessage(
      12,
      f,
      SolidityTypes_pb.uint256.serializeBinaryToWriter
    );
  }
  f = message.getBuyeraddress();
  if (f != null) {
    writer.writeMessage(
      13,
      f,
      SolidityTypes_pb.address.serializeBinaryToWriter
    );
  }
  f = message.getEngagedate();
  if (f != null) {
    writer.writeMessage(
      14,
      f,
      SolidityTypes_pb.uint256.serializeBinaryToWriter
    );
  }
};


/**
 * optional solidity.address sellerAddress = 1;
 * @return {?proto.solidity.address}
 */
proto.LoanProperties.prototype.getSelleraddress = function() {
  return /** @type{?proto.solidity.address} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.address, 1));
};


/** @param {?proto.solidity.address|undefined} value */
proto.LoanProperties.prototype.setSelleraddress = function(value) {
  jspb.Message.setWrapperField(this, 1, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.LoanProperties.prototype.clearSelleraddress = function() {
  this.setSelleraddress(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.LoanProperties.prototype.hasSelleraddress = function() {
  return jspb.Message.getField(this, 1) != null;
};


/**
 * optional solidity.uint256 startDate = 2;
 * @return {?proto.solidity.uint256}
 */
proto.LoanProperties.prototype.getStartdate = function() {
  return /** @type{?proto.solidity.uint256} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint256, 2));
};


/** @param {?proto.solidity.uint256|undefined} value */
proto.LoanProperties.prototype.setStartdate = function(value) {
  jspb.Message.setWrapperField(this, 2, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.LoanProperties.prototype.clearStartdate = function() {
  this.setStartdate(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.LoanProperties.prototype.hasStartdate = function() {
  return jspb.Message.getField(this, 2) != null;
};


/**
 * optional solidity.address collateralTokenAddress = 3;
 * @return {?proto.solidity.address}
 */
proto.LoanProperties.prototype.getCollateraltokenaddress = function() {
  return /** @type{?proto.solidity.address} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.address, 3));
};


/** @param {?proto.solidity.address|undefined} value */
proto.LoanProperties.prototype.setCollateraltokenaddress = function(value) {
  jspb.Message.setWrapperField(this, 3, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.LoanProperties.prototype.clearCollateraltokenaddress = function() {
  this.setCollateraltokenaddress(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.LoanProperties.prototype.hasCollateraltokenaddress = function() {
  return jspb.Message.getField(this, 3) != null;
};


/**
 * optional solidity.uint256 collateralTokenAmount = 4;
 * @return {?proto.solidity.uint256}
 */
proto.LoanProperties.prototype.getCollateraltokenamount = function() {
  return /** @type{?proto.solidity.uint256} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint256, 4));
};


/** @param {?proto.solidity.uint256|undefined} value */
proto.LoanProperties.prototype.setCollateraltokenamount = function(value) {
  jspb.Message.setWrapperField(this, 4, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.LoanProperties.prototype.clearCollateraltokenamount = function() {
  this.setCollateraltokenamount(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.LoanProperties.prototype.hasCollateraltokenamount = function() {
  return jspb.Message.getField(this, 4) != null;
};


/**
 * optional solidity.uint256 borrowAmount = 5;
 * @return {?proto.solidity.uint256}
 */
proto.LoanProperties.prototype.getBorrowamount = function() {
  return /** @type{?proto.solidity.uint256} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint256, 5));
};


/** @param {?proto.solidity.uint256|undefined} value */
proto.LoanProperties.prototype.setBorrowamount = function(value) {
  jspb.Message.setWrapperField(this, 5, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.LoanProperties.prototype.clearBorrowamount = function() {
  this.setBorrowamount(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.LoanProperties.prototype.hasBorrowamount = function() {
  return jspb.Message.getField(this, 5) != null;
};


/**
 * optional solidity.uint32 collateralDueDays = 6;
 * @return {?proto.solidity.uint32}
 */
proto.LoanProperties.prototype.getCollateralduedays = function() {
  return /** @type{?proto.solidity.uint32} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint32, 6));
};


/** @param {?proto.solidity.uint32|undefined} value */
proto.LoanProperties.prototype.setCollateralduedays = function(value) {
  jspb.Message.setWrapperField(this, 6, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.LoanProperties.prototype.clearCollateralduedays = function() {
  this.setCollateralduedays(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.LoanProperties.prototype.hasCollateralduedays = function() {
  return jspb.Message.getField(this, 6) != null;
};


/**
 * optional solidity.uint32 engagementDueDays = 7;
 * @return {?proto.solidity.uint32}
 */
proto.LoanProperties.prototype.getEngagementduedays = function() {
  return /** @type{?proto.solidity.uint32} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint32, 7));
};


/** @param {?proto.solidity.uint32|undefined} value */
proto.LoanProperties.prototype.setEngagementduedays = function(value) {
  jspb.Message.setWrapperField(this, 7, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.LoanProperties.prototype.clearEngagementduedays = function() {
  this.setEngagementduedays(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.LoanProperties.prototype.hasEngagementduedays = function() {
  return jspb.Message.getField(this, 7) != null;
};


/**
 * optional solidity.uint32 tenorDays = 8;
 * @return {?proto.solidity.uint32}
 */
proto.LoanProperties.prototype.getTenordays = function() {
  return /** @type{?proto.solidity.uint32} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint32, 8));
};


/** @param {?proto.solidity.uint32|undefined} value */
proto.LoanProperties.prototype.setTenordays = function(value) {
  jspb.Message.setWrapperField(this, 8, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.LoanProperties.prototype.clearTenordays = function() {
  this.setTenordays(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.LoanProperties.prototype.hasTenordays = function() {
  return jspb.Message.getField(this, 8) != null;
};


/**
 * optional solidity.uint32 interestRate = 9;
 * @return {?proto.solidity.uint32}
 */
proto.LoanProperties.prototype.getInterestrate = function() {
  return /** @type{?proto.solidity.uint32} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint32, 9));
};


/** @param {?proto.solidity.uint32|undefined} value */
proto.LoanProperties.prototype.setInterestrate = function(value) {
  jspb.Message.setWrapperField(this, 9, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.LoanProperties.prototype.clearInterestrate = function() {
  this.setInterestrate(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.LoanProperties.prototype.hasInterestrate = function() {
  return jspb.Message.getField(this, 9) != null;
};


/**
 * optional solidity.uint32 gracePeriod = 10;
 * @return {?proto.solidity.uint32}
 */
proto.LoanProperties.prototype.getGraceperiod = function() {
  return /** @type{?proto.solidity.uint32} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint32, 10));
};


/** @param {?proto.solidity.uint32|undefined} value */
proto.LoanProperties.prototype.setGraceperiod = function(value) {
  jspb.Message.setWrapperField(this, 10, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.LoanProperties.prototype.clearGraceperiod = function() {
  this.setGraceperiod(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.LoanProperties.prototype.hasGraceperiod = function() {
  return jspb.Message.getField(this, 10) != null;
};


/**
 * optional bool collateralComplete = 11;
 * Note that Boolean fields may be set to 0/1 when serialized from a Java server.
 * You should avoid comparisons like {@code val === true/false} in those cases.
 * @return {boolean}
 */
proto.LoanProperties.prototype.getCollateralcomplete = function() {
  return /** @type {boolean} */ (jspb.Message.getFieldWithDefault(this, 11, false));
};


/** @param {boolean} value */
proto.LoanProperties.prototype.setCollateralcomplete = function(value) {
  jspb.Message.setProto3BooleanField(this, 11, value);
};


/**
 * optional solidity.uint256 interest = 12;
 * @return {?proto.solidity.uint256}
 */
proto.LoanProperties.prototype.getInterest = function() {
  return /** @type{?proto.solidity.uint256} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint256, 12));
};


/** @param {?proto.solidity.uint256|undefined} value */
proto.LoanProperties.prototype.setInterest = function(value) {
  jspb.Message.setWrapperField(this, 12, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.LoanProperties.prototype.clearInterest = function() {
  this.setInterest(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.LoanProperties.prototype.hasInterest = function() {
  return jspb.Message.getField(this, 12) != null;
};


/**
 * optional solidity.address buyerAddress = 13;
 * @return {?proto.solidity.address}
 */
proto.LoanProperties.prototype.getBuyeraddress = function() {
  return /** @type{?proto.solidity.address} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.address, 13));
};


/** @param {?proto.solidity.address|undefined} value */
proto.LoanProperties.prototype.setBuyeraddress = function(value) {
  jspb.Message.setWrapperField(this, 13, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.LoanProperties.prototype.clearBuyeraddress = function() {
  this.setBuyeraddress(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.LoanProperties.prototype.hasBuyeraddress = function() {
  return jspb.Message.getField(this, 13) != null;
};


/**
 * optional solidity.uint256 engageDate = 14;
 * @return {?proto.solidity.uint256}
 */
proto.LoanProperties.prototype.getEngagedate = function() {
  return /** @type{?proto.solidity.uint256} */ (
    jspb.Message.getWrapperField(this, SolidityTypes_pb.uint256, 14));
};


/** @param {?proto.solidity.uint256|undefined} value */
proto.LoanProperties.prototype.setEngagedate = function(value) {
  jspb.Message.setWrapperField(this, 14, value);
};


/**
 * Clears the message field making it undefined.
 */
proto.LoanProperties.prototype.clearEngagedate = function() {
  this.setEngagedate(undefined);
};


/**
 * Returns whether this field is set.
 * @return {boolean}
 */
proto.LoanProperties.prototype.hasEngagedate = function() {
  return jspb.Message.getField(this, 14) != null;
};


goog.object.extend(exports, proto);
