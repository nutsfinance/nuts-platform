pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "../../contracts/common/property/Property.sol";

contract TestPropertyValue {
    using Property for Property.Properties;

    Property.Properties private _properties1;
    Property.Properties private _properties2;

    function testShouldSetAndGetStringValues() public {
        _properties1.clear();
        _properties1.setStringValue("key1", "value1");
        _properties1.setStringValue("key2", "value2");
        _properties1.setStringValue("key3", "value3");
        _properties1.setStringValue("key4", "value4");
        Assert.equal(_properties1.getStringValue("key1"), "value1", "Should get the same string value");
        Assert.equal(_properties1.getStringValue("key2"), "value2", "Should get the same string value");
        Assert.equal(_properties1.getStringValue("key3"), "value3", "Should get the same string value");
        Assert.equal(_properties1.getStringValue("key4"), "value4", "Should get the same string value");
    }

    function testShouldSetAndGetUintValues() public {
        _properties1.clear();
        _properties1.setUintValue("key1", 100);
        _properties1.setUintValue("key2", 200);
        _properties1.setUintValue("key3", 300);
        _properties1.setUintValue("key4", 400);
        Assert.equal(_properties1.getUintValue("key1"), 100, "Should get the same uint value");
        Assert.equal(_properties1.getUintValue("key2"), 200, "Should get the same uint value");
        Assert.equal(_properties1.getUintValue("key3"), 300, "Should get the same uint value");
        Assert.equal(_properties1.getUintValue("key4"), 400, "Should get the same uint value");
    }

    function testShouldSetAndGetIntValues() public {
        _properties1.clear();
        _properties1.setIntValue("key1", -100);
        _properties1.setIntValue("key2", -200);
        _properties1.setIntValue("key3", -300);
        _properties1.setIntValue("key4", -400);
        Assert.equal(_properties1.getIntValue("key1"), -100, "Should get the same int value");
        Assert.equal(_properties1.getIntValue("key2"), -200, "Should get the same int value");
        Assert.equal(_properties1.getIntValue("key3"), -300, "Should get the same int value");
        Assert.equal(_properties1.getIntValue("key4"), -400, "Should get the same int value");
    }

    function testShouldSetAndGetBoolValues() public {
        _properties1.clear();
        _properties1.setBoolValue("key1", true);
        _properties1.setBoolValue("key2", false);
        _properties1.setBoolValue("key3", false);
        _properties1.setBoolValue("key4", true);
        Assert.equal(_properties1.getBoolValue("key1"), true, "Should get the same bool value");
        Assert.equal(_properties1.getBoolValue("key2"), false, "Should get the same bool value");
        Assert.equal(_properties1.getBoolValue("key3"), false, "Should get the same bool value");
        Assert.equal(_properties1.getBoolValue("key4"), true, "Should get the same bool value");
    }

    function testShouldSetAndGetAddressValues() public {
        _properties1.clear();
        _properties1.setAddressValue("key1", 0xe157eAD80476c28bF2bF026e71b2415E19450f6E);
        _properties1.setAddressValue("key2", 0x1bE9F49158f3DD54315C68149d511d5e45a03595);
        _properties1.setAddressValue("key3", 0xC8aA2431fb1DfDd93dd228e908AD9D705DA82473);
        _properties1.setAddressValue("key4", 0x655d3828c419606e673a33cDda87CA2848f031f0);
        Assert.equal(_properties1.getAddressValue("key1"), 0xe157eAD80476c28bF2bF026e71b2415E19450f6E, "Should get the same address value");
        Assert.equal(_properties1.getAddressValue("key2"), 0x1bE9F49158f3DD54315C68149d511d5e45a03595, "Should get the same address value");
        Assert.equal(_properties1.getAddressValue("key3"), 0xC8aA2431fb1DfDd93dd228e908AD9D705DA82473, "Should get the same address value");
        Assert.equal(_properties1.getAddressValue("key4"), 0x655d3828c419606e673a33cDda87CA2848f031f0, "Should get the same address value");
    }

    function testShouldLoadAndSaveStringValues() public {
        _properties1.clear();
        _properties2.clear();
        _properties1.setStringValue("key1", "value1");
        _properties1.setStringValue("key2", "value2");
        _properties1.setStringValue("key3", "value3");
        _properties1.setStringValue("key4", "value4");

        _properties2.load(_properties1.save());
        Assert.equal(_properties2.getStringValue("key1"), "value1", "Should get the same string value");
        Assert.equal(_properties2.getStringValue("key2"), "value2", "Should get the same string value");
        Assert.equal(_properties2.getStringValue("key3"), "value3", "Should get the same string value");
        Assert.equal(_properties2.getStringValue("key4"), "value4", "Should get the same string value");
    }

    function testShouldLoadAndSaveUintValues() public {
        _properties1.clear();
        _properties2.clear();
        _properties1.setUintValue("key1", 100);
        _properties1.setUintValue("key2", 200);
        _properties1.setUintValue("key3", 300);
        _properties1.setUintValue("key4", 400);

        _properties2.load(_properties1.save());
        Assert.equal(_properties2.getUintValue("key1"), 100, "Should get the same uint value");
        Assert.equal(_properties2.getUintValue("key2"), 200, "Should get the same uint value");
        Assert.equal(_properties2.getUintValue("key3"), 300, "Should get the same uint value");
        Assert.equal(_properties2.getUintValue("key4"), 400, "Should get the same uint value");
    }

    function testShouldLoadAndSaveIntValues() public {
        _properties1.clear();
        _properties2.clear();
        _properties1.setIntValue("key1", -100);
        _properties1.setIntValue("key2", -200);
        _properties1.setIntValue("key3", -300);
        _properties1.setIntValue("key4", -400);

        _properties2.load(_properties1.save());
        Assert.equal(_properties2.getIntValue("key1"), -100, "Should get the same int value");
        Assert.equal(_properties2.getIntValue("key2"), -200, "Should get the same int value");
        Assert.equal(_properties2.getIntValue("key3"), -300, "Should get the same int value");
        Assert.equal(_properties2.getIntValue("key4"), -400, "Should get the same int value");
    }

    function testShouldLoadAndSaveBoolValues() public {
        _properties1.clear();
        _properties2.clear();
        _properties1.setBoolValue("key1", true);
        _properties1.setBoolValue("key2", false);
        _properties1.setBoolValue("key3", false);
        _properties1.setBoolValue("key4", true);

        _properties2.load(_properties1.save());
        Assert.equal(_properties2.getBoolValue("key1"), true, "Should get the same bool value");
        Assert.equal(_properties2.getBoolValue("key2"), false, "Should get the same bool value");
        Assert.equal(_properties2.getBoolValue("key3"), false, "Should get the same bool value");
        Assert.equal(_properties2.getBoolValue("key4"), true, "Should get the same bool value");
    }

    function testShouldLoadAndSaveAddressValues() public {
        _properties1.clear();
        _properties2.clear();
        _properties1.setAddressValue("key1", 0xe157eAD80476c28bF2bF026e71b2415E19450f6E);
        _properties1.setAddressValue("key2", 0x1bE9F49158f3DD54315C68149d511d5e45a03595);
        _properties1.setAddressValue("key3", 0xC8aA2431fb1DfDd93dd228e908AD9D705DA82473);
        _properties1.setAddressValue("key4", 0x655d3828c419606e673a33cDda87CA2848f031f0);

        _properties2.load(_properties1.save());
        Assert.equal(_properties2.getAddressValue("key1"), 0xe157eAD80476c28bF2bF026e71b2415E19450f6E, "Should get the same address value");
        Assert.equal(_properties2.getAddressValue("key2"), 0x1bE9F49158f3DD54315C68149d511d5e45a03595, "Should get the same address value");
        Assert.equal(_properties2.getAddressValue("key3"), 0xC8aA2431fb1DfDd93dd228e908AD9D705DA82473, "Should get the same address value");
        Assert.equal(_properties2.getAddressValue("key4"), 0x655d3828c419606e673a33cDda87CA2848f031f0, "Should get the same address value");
    }
}