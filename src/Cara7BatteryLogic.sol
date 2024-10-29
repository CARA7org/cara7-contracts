// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

enum BatteryStatus {
  UNINITIALIZED,
  INITIALIZED
}

struct Metadata {
  uint8 status;
  string model;
  string brand;
  uint256 year;
}

contract Cara7BatteryLogic is ERC721, Ownable {
  constructor() ERC721("", "") Ownable(msg.sender) {}

  function mint(address to) external onlyOwner {
    _safeMint(to, 1);
  }
}