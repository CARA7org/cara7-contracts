// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import { IMetadata } from "../interfaces/IMetadata.sol";
import { ICara7Authorization } from "../interfaces/ICara7Authorization.sol";

enum BatteryStatus {
  UNINITIALIZED,
  INITIALIZED
}

struct Metadata {
  uint8 status;
  string batteryId;
  string manufacturer;
  string batteryStatus;
  uint256 productionDate;
}

error InvalidAuthorization();
error InvalidCallerNotOwner();
error InvalidIndex();

contract Cara7BatteryLogic is ERC721Upgradeable, OwnableUpgradeable {
  address private _authorizationContract;
  Metadata private _metadata;

  uint256 private _eventsCountCo2;
  uint256 private _eventsCountRawMaterialsPercent;
  uint256 private _eventsCountTracability;
  uint256 private _eventsCountStatesLifeCycle;

  mapping (uint256 => IMetadata.Event) private _eventsCo2;
  mapping (uint256 => IMetadata.Event) private _eventsRawMaterialsPercent;
  mapping (uint256 => IMetadata.Event) private _eventsTracability;
  mapping (uint256 => IMetadata.Event) private _eventsStatesLifeCycle;

  modifier onlyAuthorized() {
    if (ICara7Authorization(_authorizationContract)
      .isAuthorized(msg.sender) == false) revert InvalidAuthorization();
    _;
  }

  function initialize(
    address contractOwner,
    address authorizationContract,
    string memory name,
    string memory symbol
  ) external reinitializer(1) {
    __Ownable_init(contractOwner);
    __ERC721_init(name, symbol);
    _authorizationContract = authorizationContract;
  }

  function mint(
    address to,
    string memory batteryId,
    string memory manufacturer,
    string memory batteryStatus,
    uint256 productionDate
  ) external onlyOwner {
    _mint(to);
    _setMetadata(batteryId, manufacturer, batteryStatus, productionDate);
  }

  function addEventCo2(string memory eventName, string[] memory dataNames, string[] memory dataValues) external {
    if (ownerOf(1) != msg.sender) revert InvalidCallerNotOwner();
    _eventsCo2[_eventsCountCo2] = IMetadata.Event(eventName, block.timestamp, dataNames, dataValues);
    unchecked {_eventsCountCo2++;}
  }

  function addEventRawMaterialsPercent(string memory eventName, string[] memory dataNames, string[] memory dataValues) external {
    if (ownerOf(1) != msg.sender) revert InvalidCallerNotOwner();
    _eventsRawMaterialsPercent[_eventsCountRawMaterialsPercent] = IMetadata.Event(eventName, block.timestamp, dataNames, dataValues);
    unchecked {_eventsCountRawMaterialsPercent++;}
  }

  function addEventTracability(string memory eventName, string[] memory dataNames, string[] memory dataValues) external {
    if (ownerOf(1) != msg.sender) revert InvalidCallerNotOwner();
    _eventsTracability[_eventsCountTracability] = IMetadata.Event(eventName, block.timestamp, dataNames, dataValues);
    unchecked {_eventsCountTracability++;}
  }

  function addEventStatesLifeCycle(string memory eventName, string[] memory dataNames, string[] memory dataValues) external {
    _eventsStatesLifeCycle[_eventsCountStatesLifeCycle] = IMetadata.Event(eventName, block.timestamp, dataNames, dataValues);
    unchecked {_eventsCountStatesLifeCycle++;}
  }

  function _mint(address to) internal {
    _safeMint(to, 1);
  }

  function _setMetadata(
    string memory batteryId,
    string memory manufacturer,
    string memory batteryStatus,
    uint256 productionDate
  ) internal {
    _metadata = Metadata(uint8(BatteryStatus.INITIALIZED), batteryId, manufacturer, batteryStatus, productionDate);
  }

  function metadata() external view returns (Metadata memory) {
    return _metadata;
  }

  function getEventsCountCo2() external view returns (uint256) {
    return _eventsCountCo2;
  }

  function getEventsCountRawMaterialsPercent() external view returns (uint256) {
    return _eventsCountRawMaterialsPercent;
  }

  function getEventsCountTracability() external view returns (uint256) {
    return _eventsCountTracability;
  }

  function getEventsCountStatesLifeCycle() external view returns (uint256) {
    return _eventsCountStatesLifeCycle;
  }

  function getEventCo2(uint256 index) external view returns (IMetadata.Event memory) {
    if (index >= _eventsCountCo2) revert InvalidIndex();
    return _eventsCo2[index];
  }

  function getEventTracability(uint256 index) external view returns (IMetadata.Event memory) {
    if (index >= _eventsCountTracability) revert InvalidIndex();
    return _eventsTracability[index];
  }

  function getEventRawMaterialsPercent(uint256 index) external view returns (IMetadata.Event memory) {
    if (index >= _eventsCountRawMaterialsPercent) revert InvalidIndex();
    return _eventsRawMaterialsPercent[index];
  }

  function getEventStatesLifeCycle(uint256 index) external view returns (IMetadata.Event memory) {
    if (index >= _eventsCountStatesLifeCycle) revert InvalidIndex();
    return _eventsStatesLifeCycle[index];
  }
}