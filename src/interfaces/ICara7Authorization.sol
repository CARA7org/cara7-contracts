// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

interface ICara7Authorization {
  function isAuthorized(address _account) external view returns (bool);
}