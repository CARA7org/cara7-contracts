// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

enum AuthorizationStatus {
  UNAUTHORIZED,
  AUTHORIZED
}

contract Authorization is Ownable {
  mapping (address => uint8) private _authorizations;

  constructor(address initialOwner) Ownable(initialOwner) {}

  function authorize(address account) external onlyOwner {
    _authorizations[account] = uint8(AuthorizationStatus.AUTHORIZED);
  }

  function unauthorize(address account) external onlyOwner {
    _authorizations[account] = uint8(AuthorizationStatus.UNAUTHORIZED);
  }

  function isAuthorized(address account) external view returns (bool) {
    return _authorizations[account] == uint8(AuthorizationStatus.AUTHORIZED);
  }
}