// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "../src/VanityFactory.sol";
import "../src/ZeroScorer.sol";


contract VanityFactoryTest is Test {
    VanityFactory factory;
    ZeroScorer scorer;

    function setUp() public {
        factory = new VanityFactory();
        scorer = new ZeroScorer();
    }

    function testCanCreateAndClaimBounty() public {
        bytes memory deploymentData = abi.encode(type(ERC20).creationCode, "Testy", "TST");
        bytes32 initCodeHash = keccak256(deploymentData);

        assertEq(initCodeHash, 0x6e6e07ece4a5117ed3a7fd5ea290e3919cbe5526656b80c824420ed397c4ae4e, "wrong init code");

        uint256 endTime = block.timestamp + 5 days;
        uint256 reward = 1 ether;

        factory.ask{ value: reward }(
            scorer,
            initCodeHash,
            endTime
        );

        address miner = 0xDAFEA492D9c6733ae3d56b7Ed1ADB60692c98Bc5;
        vm.prank(miner);

        bytes32 salt = 0x000000000000000000029ae4DAFEA492D9c6733ae3d56b7Ed1ADB60692c98Bc5;
        factory.submit(initCodeHash, salt);

        vm.warp(endTime + 1 days);

        factory.deploy(deploymentData);

        ERC20 deployed = ERC20(address(0x000000D41e48506dd46a927CC7946F8cdF19003d));
        assertEq(deployed.name(), "Testy", "Testy token not deployed");
    }
}
