// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {ProxyBattery} from "./battery/ProxyBattery.sol";
import {ProxyVehicle} from "./vehicle/ProxyVehicle.sol";

error InitializationFailed();

contract Deployer is Ownable {
  address private _vehicleBeacon;
  address private _batteryBeacon;

  event ProxyVehicleDeployed(address addr, string vin);
  event ProxyBatteryDeployed(address addr, string batteryId);

  constructor(address initialOwner, address vehicleBeaconAddress, address batteryBeaconAddress) Ownable(initialOwner) {
    _vehicleBeacon = vehicleBeaconAddress;
    _batteryBeacon = batteryBeaconAddress;
  }

  function deployProxyVehicle(bytes memory data, string memory vin) external onlyOwner returns (address addr) {
    bytes memory code = _getProxyVehicleCode(_vehicleBeacon);
    uint256 salt = uint256(_computeVehicleSalt(vin));

    assembly {
      addr := create2(0, add(code, 0x20), mload(code), salt)
      if iszero(extcodesize(addr)) { revert(0, 0) }
    }

    (bool success, ) = addr.call(data);
    if (!success) revert InitializationFailed();

    emit ProxyVehicleDeployed(addr, vin);
  }

  function deployProxyBattery(bytes memory data, string memory batteryId) external onlyOwner returns (address addr) {
    bytes memory code = _getProxyBatteryCode(_batteryBeacon);
    bytes32 salt = _computeBatterySalt(batteryId);

    assembly {
      addr := create2(0, add(code, 0x20), mload(code), salt)
      if iszero(extcodesize(addr)) { revert(0, 0) }
    }

    (bool success, ) = addr.call(data);
    if (!success) revert InitializationFailed();

    emit ProxyBatteryDeployed(addr, batteryId);
  }

  function computeProxyVehicleAddress(string memory vin) public view returns (address) {
    bytes32 salt = _computeVehicleSalt(vin);
    bytes memory bytecode = _getProxyVehicleCode(_vehicleBeacon);
    bytes32 bytecodeHash = keccak256(bytecode);
    return address(uint160(uint(keccak256(abi.encodePacked(
      bytes1(0xff),
      address(this),
      salt,
      bytecodeHash
    )))));
  }

  function computeProxyBatteryAddress(string memory batteryId) public view returns (address) {
    bytes32 salt = _computeBatterySalt(batteryId);
    bytes memory bytecode = _getProxyBatteryCode(_batteryBeacon);
    bytes32 bytecodeHash = keccak256(bytecode);
    return address(uint160(uint(keccak256(abi.encodePacked(
      bytes1(0xff),
      address(this),
      salt,
      bytecodeHash
    )))));
  }

  function _computeVehicleSalt(string memory vin) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(vin));
  }

  function _computeBatterySalt(string memory batteryId) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(batteryId));
  }

  function _getProxyBatteryCode(address beacon) internal pure returns (bytes memory) {
    return abi.encodePacked(
      type(ProxyBattery).creationCode,
      abi.encode(beacon, "")
    );
  }

  function _getProxyVehicleCode(address beacon) internal pure returns (bytes memory) {
    return abi.encodePacked(
      type(ProxyVehicle).creationCode,
      abi.encode(beacon, "")
    );
  }
}