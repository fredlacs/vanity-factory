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
        factory = VanityFactory(address(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45));
        vm.etch(address(factory), address(new VanityFactory()).code);

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

        bytes32 salt = 0x00000000000000000026cf80DAFEA492D9c6733ae3d56b7Ed1ADB60692c98Bc5;
        factory.submit(initCodeHash, salt);

        vm.warp(endTime + 1 days);

        factory.deploy(deploymentData);

        ERC20 deployed = ERC20(address(0x0000091B0604b834fD8e7652abea325FAF5a875D));
        assertEq(deployed.name(), "Testy", "Testy token not deployed");
    }
}
