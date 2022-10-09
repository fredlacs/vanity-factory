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
        bytes memory deploymentData = bytes.concat(type(ERC20).creationCode, abi.encode("Testy", "TST"));
        bytes32 initCodeHash = keccak256(deploymentData);

        assertEq(initCodeHash, 0xa91ac850d836e851294d59cc0d97395c7a652b0f908e65f950532322ab0f7723, "wrong init code");

        uint256 endTime = block.timestamp + 5 days;
        uint256 reward = 1 ether;

        factory.ask{ value: reward }(
            scorer,
            initCodeHash,
            endTime
        );

        address miner = 0xDAFEA492D9c6733ae3d56b7Ed1ADB60692c98Bc5;
        vm.prank(miner);

        bytes32 salt = 0x000000000000000000071a97DAFEA492D9c6733ae3d56b7Ed1ADB60692c98Bc5;
        factory.submit(initCodeHash, salt);

        vm.warp(endTime + 1 days);

        factory.deploy(deploymentData);

        ERC20 deployed = ERC20(address(0x00000bbEc92598358Bce4d71f9B5382CE9CCf254));
        assertEq(deployed.name(), "Testy", "Testy token not deployed");
    }
}
