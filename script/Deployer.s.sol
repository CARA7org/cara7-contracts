// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {BatteryLogic} from "../src/battery/BatteryLogic.sol";
import {BatteryBeacon} from "../src/battery/BatteryBeacon.sol";
import {ProxyBattery} from "../src/battery/ProxyBattery.sol";

import {VehicleLogic} from "../src/vehicle/VehicleLogic.sol";
import {VehicleBeacon} from "../src/vehicle/VehicleBeacon.sol";
import {ProxyVehicle} from "../src/vehicle/ProxyVehicle.sol";

import {Authorization} from "../src/Authorization.sol";
import {Deployer} from "../src/Deployer.sol";

contract DeployerScript is Script {
  BatteryLogic private _batteryLogic;
  VehicleLogic private _vehicleLogic;

  BatteryBeacon private _upgradeableProxyBattery;
  VehicleBeacon private _upgradeableProxyVehicle;

  ProxyBattery private _proxyBattery;
  ProxyVehicle private _proxyVehicle;

  Authorization private _authorization;

  Deployer private _deployer;

  function setUp() public {}

  function run() public {
    address owner = 0xDdc539B305bAE3687CFb41CE13f27399e9F1A499;
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    _batteryLogic = new BatteryLogic();
    _vehicleLogic = new VehicleLogic();

    _upgradeableProxyBattery = new BatteryBeacon(address(_batteryLogic));
    _upgradeableProxyVehicle = new VehicleBeacon(address(_vehicleLogic));

    _authorization = new Authorization(owner);

    _deployer = new Deployer(owner, address(_upgradeableProxyVehicle), address(_upgradeableProxyBattery));

    vm.stopBroadcast();
  }
}
