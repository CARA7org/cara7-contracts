// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

interface IAuthorization {
  function isAuthorized(address _account) external view returns (bool);
}