// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract Cara7ProxyVehicle is BeaconProxy, Ownable {
  constructor(address _beacon, bytes memory _data) BeaconProxy(_beacon, _data) Ownable(msg.sender) {}
}