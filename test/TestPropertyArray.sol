pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "../contracts/common/property/Property.sol";

contract TestPropertyArray {
    using Property for Property.Properties;

    Property.Properties private _properties1;
    Property.Properties private _properties2;

    function testShouldLoadAndSaveBytesArray() public {
        _properties1.clear();
        _properties2.clear();
        bytes[] memory data = new bytes[](4);
        data[0] = bytes("value1");
        data[1] = bytes("value2");
        data[2] = bytes("value3");
        data[3] = bytes("value4");
        _properties1.setBytesArrayValue("key1", data);

        _properties2.load(_properties1.save());
        bytes[] memory data2 = _properties2.getBytesArrayValue("key1");
        Assert.equal(string(data2[0]), "value1", "Bytes value should be the same");
        Assert.equal(string(data2[1]), "value2", "Bytes value should be the same");
        Assert.equal(string(data2[2]), "value3", "Bytes value should be the same");
        Assert.equal(string(data2[3]), "value4", "Bytes value should be the same");
    }

    function testShouldLoadAndSaveStringArray() public {
        _properties1.clear();
        _properties2.clear();
        string[] memory data = new string[](4);
        data[0] = "value1";
        data[1] = "value2";
        data[2] = "value3";
        data[3] = "value4";
        _properties1.setStringArrayValue("key1", data);

        _properties2.load(_properties1.save());
        string[] memory data2 = _properties2.getStringArrayValue("key1");
        Assert.equal(data2[0], "value1", "String value should be the same");
        Assert.equal(data2[1], "value2", "String value should be the same");
        Assert.equal(data2[2], "value3", "String value should be the same");
        Assert.equal(data2[3], "value4", "String value should be the same");
    }

    function testShouldLoadAndSaveUintArray() public {
        _properties1.clear();
        _properties2.clear();
        uint[] memory data = new uint[](4);
        data[0] = 100;
        data[1] = 200;
        data[2] = 300;
        data[3] = 400;
        _properties1.setUintArrayValue("key1", data);

        _properties2.load(_properties1.save());
        uint[] memory data2 = _properties2.getUintArrayValue("key1");
        Assert.equal(data2[0], 100, "Uint value should be the same");
        Assert.equal(data2[1], 200, "Uint value should be the same");
        Assert.equal(data2[2], 300, "Uint value should be the same");
        Assert.equal(data2[3], 400, "Uint value should be the same");
    }

    function testShouldLoadAndSaveIntArray() public {
        _properties1.clear();
        _properties2.clear();
        int[] memory data = new int[](4);
        data[0] = 100;
        data[1] = -200;
        data[2] = 300;
        data[3] = -400;
        _properties1.setIntArrayValue("key1", data);

        _properties2.load(_properties1.save());
        int[] memory data2 = _properties2.getIntArrayValue("key1");
        Assert.equal(data2[0], 100, "Int value should be the same");
        Assert.equal(data2[1], -200, "Int value should be the same");
        Assert.equal(data2[2], 300, "Int value should be the same");
        Assert.equal(data2[3], -400, "Int value should be the same");
    }

    function testShouldParseParameters() public {
        _properties1.clear();
        _properties1.parseParameters("aaa=bbb&ccc=ddd&ee=11");
        Assert.equal(_properties1.getStringValue("aaa"), "bbb", "String parameter should be the same");
        Assert.equal(_properties1.getStringValue("ccc"), "ddd", "String parameter should be the same");
        Assert.equal(_properties1.getUintValue("ee"), 11, "String parameter should be the same");
    }
}