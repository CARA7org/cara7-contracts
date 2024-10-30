// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

interface IMetadata {
  struct Event {
    string eventName;
    uint256 timestamp;
    string[] dataNames;
    string[] dataValues;
  }
}