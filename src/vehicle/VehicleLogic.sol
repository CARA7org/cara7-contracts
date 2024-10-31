// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { ERC721Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import { IMetadata } from "../interfaces/IMetadata.sol";
import { IAuthorization } from "../interfaces/IAuthorization.sol";

enum VehicleStatus {
  UNINITIALIZED,
  INITIALIZED
}

error InvalidAuthorization();
error InvalidCallerNotOwner();
error AlreadyMinted();
error InvalidIndex();

contract VehicleLogic is OwnableUpgradeable, ERC721Upgradeable {
  address private _authorizationContract;
  string private _vin;

  mapping (uint256 => IMetadata.Event) private _events;
  uint256 private _eventsCount;

  event VehicleMinted(address indexed to);

  modifier onlyAuthorized() {
    if (IAuthorization(_authorizationContract)
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

  function mint(address to, string memory vin) external onlyOwner {
    if (_ownerOf(1) != address(0)) revert AlreadyMinted();
    _mint(to, 1);
    _setMetadata(vin);
    emit VehicleMinted(to);
  }

  function _setMetadata(string memory vin) internal {
    _vin = vin;
  }

  function addEvent(string memory eventName, string[] memory dataNames, string[] memory dataValues) external onlyAuthorized {
    _events[_eventsCount] = IMetadata.Event(eventName, block.timestamp, dataNames, dataValues);
    unchecked {_eventsCount++;}
  }

  function transferERC721(address contractERC721, address to) external {
    if (ownerOf(1) != msg.sender) revert InvalidCallerNotOwner();
    IERC721(contractERC721).transferFrom(address(this), to, 1);
  }

  function metadata() external view returns (string memory) {
    return _vin;
  }

  function getEventsCount() external view returns (uint256) {
    return _eventsCount;
  }

  function getEvent(uint256 index) external view returns (IMetadata.Event memory) {
    if (index >= _eventsCount) revert InvalidIndex();
    return _events[index];
  }
}
