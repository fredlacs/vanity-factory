// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/utils/Create2.sol";
import "../src/VanityFactory.sol";
import "../src/ZeroScorer.sol";

contract VanityFactoryTest is Test {
    VanityFactory factory;
    ZeroScorer scorer;

    function setUp() public {
        factory = new VanityFactory();
        scorer = new ZeroScorer();
    }

    function testCastingBytes32ToAddress() public {
        bytes32 salt = 0x0000000000000000000000000d97395c7a652b0f908e65f950532322ab0f7723;
        bytes32 actualUpcast = 0x0d97395c7a652b0f908e65f950532322ab0f7723000000000000000000000000;
        address addr = 0x0D97395c7A652B0f908e65F950532322Ab0f7723;
        address actualDownCast = 0x0000000000000000000000000d97395C7a652B0f;


        assertEq(address(bytes20(salt << 96)), addr, "wrong down cast");
        assertEq(address(bytes20(salt)), actualDownCast, "wrong down cast");

        assertEq(bytes32(bytes20(addr)) >> 96, salt, "wrong up cast");
        assertEq(bytes32(bytes20(addr)), actualUpcast, "wrong up cast");
    }

    function testNoOneSubmitAnswer() public {
        address deployer = address(0x123000000000000000000000000000000000007B);
        vm.deal(deployer, 5 ether);

        bytes memory deploymentData = bytes.concat(type(ERC20).creationCode, abi.encode("Testy", "TST"));
        bytes32 initCodeHash = keccak256(deploymentData);

        assertEq(initCodeHash, 0xa91ac850d836e851294d59cc0d97395c7a652b0f908e65f950532322ab0f7723, "wrong init code");

        uint256 endTime = block.timestamp + 5 days;
        uint256 reward = 1 ether;
        uint256 minScore = 4;

        vm.prank(deployer);
        factory.ask{value: reward}(scorer, initCodeHash, endTime, minScore);

        vm.warp(endTime + 1 days);

        // deployer gets funds back
        uint256 prevBal = deployer.balance;
        factory.claim(initCodeHash);
        assertEq(deployer.balance, prevBal+reward, "miner did not receive funds");

        factory.deploy(deploymentData);

        ERC20 deployed = ERC20(address(0x7954ab943E87c696bcfa046FF77AeD5582a83b40));
        assertEq(deployed.name(), "Testy", "Testy token not deployed");
    }

    function testCanCreateAndClaimBounty() public {
        bytes memory deploymentData = bytes.concat(type(ERC20).creationCode, abi.encode("Testy", "TST"));
        bytes32 initCodeHash = keccak256(deploymentData);

        assertEq(initCodeHash, 0xa91ac850d836e851294d59cc0d97395c7a652b0f908e65f950532322ab0f7723, "wrong init code");

        uint256 endTime = block.timestamp + 5 days;
        uint256 reward = 1 ether;
        uint256 minScore = 4;

        factory.ask{value: reward}(scorer, initCodeHash, endTime, minScore);

        address miner = 0xDAFEA492D9c6733ae3d56b7Ed1ADB60692c98Bc5;
        vm.prank(miner);

        bytes32 salt = 0x000000000000000000071a97DAFEA492D9c6733ae3d56b7Ed1ADB60692c98Bc5;
        factory.submit(initCodeHash, salt);

        vm.warp(endTime + 1 days);

        assertEq(miner.balance, 0, "miner not expected to hold prev funds");
        factory.claim(initCodeHash);
        assertEq(miner.balance, reward, "miner did not receive funds");

        factory.deploy(deploymentData);

        ERC20 deployed = ERC20(address(0x00000bbEc92598358Bce4d71f9B5382CE9CCf254));
        assertEq(deployed.name(), "Testy", "Testy token not deployed");
    }

    function testCannotSubmitBelowMinScore() public {
        bytes memory deploymentData = bytes.concat(type(ERC20).creationCode, abi.encode("Testy", "TST"));
        bytes32 initCodeHash = keccak256(deploymentData);

        uint256 endTime = block.timestamp + 5 days;
        uint256 reward = 1 ether;
        uint256 minScore = 8;

        factory.ask{value: reward}(scorer, initCodeHash, endTime, minScore);

        address miner = 0xDAFEA492D9c6733ae3d56b7Ed1ADB60692c98Bc5;
        vm.prank(miner);

        bytes32 salt = 0x000000000000000000071a97DAFEA492D9c6733ae3d56b7Ed1ADB60692c98Bc5;
        vm.expectRevert("VanityFactory: not high enough score");
        factory.submit(initCodeHash, salt);
    }

    function testMine(bytes32 salt) public {
        bytes memory deploymentData = bytes.concat(type(ERC20).creationCode, abi.encode("Testy", "TST"));
        bytes32 initCodeHash = keccak256(deploymentData);

        uint256 endTime = block.timestamp + 5 days;
        uint256 reward = 1 ether;
        uint256 minScore = 5;

        factory.ask{value: reward}(scorer, initCodeHash, endTime, minScore);

        address miner = 0xDAFEA492D9c6733ae3d56b7Ed1ADB60692c98Bc5;
        vm.prank(miner);

        address expectedMinedAddress = Create2.computeAddress(salt, initCodeHash, address(factory));
        if (scorer.score(expectedMinedAddress) <= minScore) vm.expectRevert("VanityFactory: not high enough score");
        factory.submit(initCodeHash, salt);
    }
}
