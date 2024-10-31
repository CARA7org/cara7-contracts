// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract ProxyVehicle is BeaconProxy {
  constructor(address _beacon, bytes memory _data) BeaconProxy(_beacon, _data) {}
}