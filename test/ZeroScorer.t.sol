// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.16;

import "../src/ZeroScorer.sol";
import "forge-std/Test.sol";

contract ZeroScorerTest is Test {
    ZeroScorer scorer = new ZeroScorer();

    function testZeroScorer() public {
        assertEq(scorer.score(address(0x1000000000000000000000000000000000000000)), 0);
        assertEq(scorer.score(address(0x0100000000000000000000000000000000000000)), 1);
        assertEq(scorer.score(address(0x0010000000000000000000000000000000000000)), 2);
        assertEq(scorer.score(address(0x0001000000000000000000000000000000000000)), 3);
        assertEq(scorer.score(address(0x0000100000000000000000000000000000000000)), 4);
        assertEq(scorer.score(address(0x0000010000000000000000000000000000000000)), 5);
        assertEq(scorer.score(address(0x0000001000000000000000000000000000000000)), 6);
        assertEq(scorer.score(address(0x0000000100000000000000000000000000000000)), 7);
        assertEq(scorer.score(address(0x0000000010000000000000000000000000000000)), 8);
        assertEq(scorer.score(address(0x0000000001000000000000000000000000000000)), 9);
    }
}
