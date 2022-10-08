// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IScorer {
    function score(address input) external pure returns (uint256);
}
