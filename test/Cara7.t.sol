// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {Cara7BatteryLogic} from "../src/battery/Cara7BatteryLogic.sol";
import {Cara7VehicleLogic} from "../src/vehicle/Cara7VehicleLogic.sol";
import {Cara7ProxyBattery} from "../src/battery/Cara7ProxyBattery.sol";
import {Cara7ProxyVehicle} from "../src/vehicle/Cara7ProxyVehicle.sol";
import {Cara7UpgradeableProxyBattery} from "../src/battery/Cara7UpgradeableProxyBattery.sol";
import {Cara7UpgradeableProxyVehicle} from "../src/vehicle/Cara7UpgradeableProxyVehicle.sol";
import {Cara7Authorization} from "../src/Cara7Authorization.sol";
import {Cara7Deployer} from "../src/Cara7Deployer.sol";

import {IMetadata} from "../src/interfaces/IMetadata.sol";

contract Cara7 is Test {
  Cara7BatteryLogic private _batteryLogic;
  Cara7VehicleLogic private _vehicleLogic;

  Cara7UpgradeableProxyBattery private _upgradeableProxyBattery;
  Cara7UpgradeableProxyVehicle private _upgradeableProxyVehicle;

  Cara7ProxyBattery private _proxyBattery;
  Cara7ProxyVehicle private _proxyVehicle;

  Cara7Authorization private _authorization;

  Cara7Deployer private _deployer;

  address private owner = makeAddr("owner");
  address private user1 = makeAddr("user1");
  address private user2 = makeAddr("user2");
  address private user3 = makeAddr("user3");
  address private verifier = makeAddr("verifier");

  string constant proxyVehicleName = "Cara7Vehicle";
  string constant proxyVehicleSymbol = "C7V";

  function setUp() public {
    vm.startPrank(owner);

    _batteryLogic = new Cara7BatteryLogic();
    _vehicleLogic = new Cara7VehicleLogic();

    _upgradeableProxyBattery = new Cara7UpgradeableProxyBattery(address(_batteryLogic));
    _upgradeableProxyVehicle = new Cara7UpgradeableProxyVehicle(address(_vehicleLogic));

    _authorization = new Cara7Authorization(owner);

    _deployer = new Cara7Deployer(owner, address(_upgradeableProxyVehicle));

    vm.stopPrank();
  }

  function testCreateProxyVehicleWithDeployer() public {
    vm.startPrank(owner);

    bytes memory data = abi.encodeWithSignature("initialize(address,address,string,string)", owner, address(_authorization), proxyVehicleName, proxyVehicleSymbol);
    address proxyVehicle = _deployer.deployProxyVehicle(data, "VIN123");
    assertTrue(proxyVehicle != address(0), "ProxyVehicle is not created");

    address computeAddress = _deployer.computeProxyVehicleAddress("VIN123");
    assertTrue(proxyVehicle == computeAddress, "ProxyVehicle address is not correct");

    vm.stopPrank();
  }

  function testCreateProxyBatteryWithDeployer() public {
    vm.startPrank(owner);

    bytes memory data = abi.encodeWithSignature("initialize(address,address,string,string)", owner, address(_authorization), "Cara7Battery", "C7B");
    address proxyBattery = _deployer.deployProxyBattery(data, "Battery123");
    assertTrue(proxyBattery != address(0), "ProxyBattery is not created");

    address computeAddress = _deployer.computeProxyBatteryAddress("Battery123");
    assertTrue(proxyBattery == computeAddress, "ProxyBattery address is not correct");

    vm.stopPrank();
  }

  function testCreateProxyVehicleWithInitializeAfterDeployment() public {
    vm.startPrank(owner);

    _proxyVehicle = new Cara7ProxyVehicle(address(_upgradeableProxyVehicle), "");
    assertTrue(address(_proxyVehicle) != address(0), "ProxyVehicle is not created");

    Cara7VehicleLogic(address(_proxyVehicle)).initialize(owner, address(_authorization), proxyVehicleName, proxyVehicleSymbol);

    vm.stopPrank();
  }

  function testCreateProxyVehicle() public returns (address) {
    vm.startPrank(owner);

    _proxyVehicle = new Cara7ProxyVehicle(address(_upgradeableProxyVehicle), abi.encodeWithSignature("initialize(address,address,string,string)", owner, address(_authorization), proxyVehicleName, proxyVehicleSymbol));
    assertTrue(address(_proxyVehicle) != address(0), "ProxyVehicle is not created");

    vm.stopPrank();

    return address(_proxyVehicle);
  }

  function testCreateProxyBattery() public returns (address) {
    vm.startPrank(owner);

    _proxyBattery = new Cara7ProxyBattery(address(_upgradeableProxyBattery), abi.encodeWithSignature("initialize(address,address,string,string)", owner, address(_authorization), "Cara7Battery", "C7B"));
    assertTrue(address(_proxyBattery) != address(0), "ProxyBattery is not created");

    vm.stopPrank();

    return address(_proxyBattery);
  }

  function testCreateAndCheckInitializationVahicle() public {
    Cara7ProxyVehicle proxyVehicle = Cara7ProxyVehicle(payable(testCreateProxyVehicle()));
    vm.startPrank(owner);

    string memory name = Cara7VehicleLogic(address(proxyVehicle)).name();
    string memory symbol = Cara7VehicleLogic(address(proxyVehicle)).symbol();
    assertTrue(keccak256(bytes(name)) == keccak256(bytes(proxyVehicleName)), "Name is not correct");
    assertTrue(keccak256(bytes(symbol)) == keccak256(bytes(proxyVehicleSymbol)), "Symbol is not correct");

    vm.stopPrank();
  }

  function testCreateAndCheckInitializationBattery() public {
    address proxyBattery = testCreateProxyBattery();
    vm.startPrank(owner);

    string memory name = Cara7BatteryLogic(address(proxyBattery)).name();
    string memory symbol = Cara7BatteryLogic(address(proxyBattery)).symbol();
    assertTrue(keccak256(bytes(name)) == keccak256(bytes("Cara7Battery")), "Name is not correct");
    assertTrue(keccak256(bytes(symbol)) == keccak256(bytes("C7B")), "Symbol is not correct");

    vm.stopPrank();
  }

  function testAddEventVehicle() public {
    Cara7ProxyVehicle proxyVehicle = Cara7ProxyVehicle(payable(testCreateProxyVehicle()));
    vm.startPrank(owner);

    _authorization.authorize(owner);

    Cara7VehicleLogic(address(proxyVehicle)).mint(user1, "VIN123");

    string[] memory dataNames = new string[](2);
    dataNames[0] = "Data1";
    dataNames[1] = "Data2";
    string[] memory dataValues = new string[](2);
    dataValues[0] = "Value1";
    dataValues[1] = "Value2";

    Cara7VehicleLogic(address(proxyVehicle)).addEvent("Event1", dataNames, dataValues);

    string[] memory dataNames2 = new string[](2);
    dataNames2[0] = "Data3";
    dataNames2[1] = "Data4";
    string[] memory dataValues2 = new string[](2);
    dataValues2[0] = "Value3";
    dataValues2[1] = "Value4";

    Cara7VehicleLogic(address(proxyVehicle)).addEvent("Event2", dataNames2, dataValues2);

    uint256 eventsCount = Cara7VehicleLogic(address(proxyVehicle)).getEventsCount();
    assertTrue(eventsCount == 2, "Events count is not correct");

    IMetadata.Event memory event1 = Cara7VehicleLogic(address(proxyVehicle)).getEvent(0);
    assertTrue(keccak256(bytes(event1.eventName)) == keccak256(bytes("Event1")), "Event1 name is not correct");
    assertTrue(event1.timestamp > 0, "Event1 timestamp is not correct");
    assertTrue(keccak256(bytes(event1.dataNames[0])) == keccak256(bytes("Data1")), "Event1 dataNames[0] is not correct");
    assertTrue(keccak256(bytes(event1.dataValues[0])) == keccak256(bytes("Value1")), "Event1 dataValues[0] is not correct");
    assertTrue(keccak256(bytes(event1.dataNames[1])) == keccak256(bytes("Data2")), "Event1 dataNames[1] is not correct");
    assertTrue(keccak256(bytes(event1.dataValues[1])) == keccak256(bytes("Value2")), "Event1 dataValues[1] is not correct");

    IMetadata.Event memory event2 = Cara7VehicleLogic(address(proxyVehicle)).getEvent(1);
    assertTrue(keccak256(bytes(event2.eventName)) == keccak256(bytes("Event2")), "Event2 name is not correct");
    assertTrue(event2.timestamp > 0, "Event2 timestamp is not correct");
    assertTrue(keccak256(bytes(event2.dataNames[0])) == keccak256(bytes("Data3")), "Event2 dataNames[0] is not correct");
    assertTrue(keccak256(bytes(event2.dataValues[0])) == keccak256(bytes("Value3")), "Event2 dataValues[0] is not correct");
    assertTrue(keccak256(bytes(event2.dataNames[1])) == keccak256(bytes("Data4")), "Event2 dataNames[1] is not correct");
    assertTrue(keccak256(bytes(event2.dataValues[1])) == keccak256(bytes("Value4")), "Event2 dataValues[1] is not correct");

    vm.stopPrank();
  }

  function testAddEventBatteryCo2() public {

  }
}
