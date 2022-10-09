// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./IScorer.sol";

contract ZeroScorer {
    function score(address input) external pure returns (uint256 res) {
        for (uint256 i = 0; i < 20; i++) {
            if (bytes20(input)[i] == 0x00) {
                res += 2;
            } else if (bytes20(input)[i] < 0x10) {
                res += 1;
                break;
            } else {
                break;
            }
        }
        return res;
    }
}
