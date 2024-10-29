// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

enum VehicleStatus {
  UNINITIALIZED,
  INITIALIZED
}

struct VehicleMetatada {
  uint8 status;
  string model;
  string brand;
  uint256 year;
}

error InvalidCallerNotOwner();

contract Cara7VehicleLogic is Ownable, ERC721 {
  VehicleMetatada private _metadata;

  event VehicleMinted(address indexed to);

  constructor() ERC721("Cara7Vehicle", "C7V") Ownable(msg.sender) {}

  function initialize() external {
    _setMetadata();
  }

  function mint(address to) external onlyOwner {
    _safeMint(to, 1);
    _setMetadata();
  }

  function _setMetadata() internal {
    _metadata = VehicleMetatada(uint8(VehicleStatus.INITIALIZED), "Cara7", "Cara7", 2021);
  }

  function metadata() external view returns (VehicleMetatada memory) {
    return _metadata;
  }

  function transferERC721(address contractERC721, address to) external {
    if (ownerOf(1) != msg.sender) {
      revert InvalidCallerNotOwner();
    }
    ERC721(contractERC721).transferFrom(address(this), to, 1);
  }
}
