// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

contract Cara7UpgradeableProxyVehicle is UpgradeableBeacon {
  constructor(address _implementation) UpgradeableBeacon(_implementation, msg.sender) {}
}