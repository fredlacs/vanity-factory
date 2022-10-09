// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/utils/Create2.sol";
import "./IScorer.sol";

contract VanityFactory {
    struct Context {
        IScorer scorer;
        bytes32 initCodeHash;
        bytes32 salt;
        uint256 minScoreWinner;
        uint256 endTime;
        uint256 reward;
    }

    event Asked(
        IScorer scorer,
        bytes32 initCodeHash,
        uint256 minScoreWinner,
        uint256 endTime,
        uint256 reward
    );

    event Submited(uint256 score, bytes32 salt, address minedAddress);

    event Deployed(address minedAddress);

    mapping(bytes32 => Context) public pendingDeploys;

    function ask(IScorer scorer, bytes32 initCodeHash, uint256 endTime) external payable returns (uint256 id) {
        require(pendingDeploys[initCodeHash].endTime == 0, "VanityFactory: already created pending deploy");
        require(msg.value > 0, "VanityFactory: no reward set");
        require(endTime > block.timestamp, "VanityFactory: endTime before timestamp");
        pendingDeploys[initCodeHash] = Context({
            scorer: scorer,
            initCodeHash: initCodeHash,
            salt: bytes32(bytes20(msg.sender)),
            minScoreWinner: 0,
            endTime: endTime,
            reward: msg.value
        });
        emit Asked(scorer, initCodeHash, 0, endTime, msg.value);
    }

    function submit(bytes32 initCodeHash, bytes32 salt) external {
        Context storage ctx = pendingDeploys[initCodeHash];
        require(block.timestamp < ctx.endTime, "VanityFactory: bid time ended");
        address minedAddress = Create2.computeAddress(salt, ctx.initCodeHash);
        uint256 score = ctx.scorer.score(minedAddress);
        require(score > ctx.minScoreWinner, "VanityFactory: not high enough score");

        ctx.minScoreWinner = score;
        ctx.salt = salt;

        emit Submited(score, salt, minedAddress);
    }

    function deploy(bytes calldata initCode) external {
        bytes32 initCodeHash = keccak256(initCode);
        Context memory ctx = pendingDeploys[initCodeHash];
        require(ctx.endTime != 0, "VanityFactory: not valid pending deploy");
        require(block.timestamp > ctx.endTime, "VanityFactory: bid time not yet ended");
        address winner = address(bytes20(ctx.salt));

        delete pendingDeploys[initCodeHash];

        (bool res,) = winner.call{value: ctx.reward}("");
        require(res, "VanityFactory: reward send fail");

        address minedAddress = Create2.deploy(0, ctx.salt, initCode);
        emit Deployed(minedAddress);
    }
}
