// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/utils/Create2.sol";
import "./IScorer.sol";

contract VanityFactory {
    // TODO: include deployAndCall maybe?
    struct Context {
        IScorer scorer;
        bytes32 initCodeHash;
        bytes32 salt;
        uint256 minScoreWinner;
        uint256 endTime;
        uint256 reward;
    }

    event Asked(
        uint256 deployId,
        IScorer scorer,
        bytes32 initCodeHash,
        bytes32 salt,
        uint256 minScoreWinner,
        uint256 endTime,
        uint256 reward
    );

    event Submited(uint256 deployId, uint256 score, bytes32 salt, address minedAddress);

    event Deployed(uint256 deployId, address minedAddress);

    Context[] public deploys;

    function ask(Context calldata ctx) external payable returns (uint256 id) {
        require(ctx.reward > 0, "VanityFactory: no reward set");
        require(msg.value >= ctx.reward, "VanityFactory: not enough reward sent");
        require(ctx.salt == bytes32(0), "VanityFactory: initial salt not zero");
        id = deploys.length;
        deploys.push(ctx);
        emit Asked(id, ctx.scorer, ctx.initCodeHash, ctx.salt, ctx.minScoreWinner, ctx.endTime, ctx.reward);
    }

    function submit(uint256 id, bytes32 salt) external {
        Context storage ctx = deploys[id];
        require(block.timestamp < ctx.endTime, "VanityFactory: bid time ended");
        address minedAddress = Create2.computeAddress(salt, ctx.initCodeHash);
        uint256 score = ctx.scorer.score(minedAddress);
        require(score >= ctx.minScoreWinner, "VanityFactory: not high enough score");

        ctx.endTime = block.timestamp;
        ctx.salt = salt;

        address winner = address(bytes20(salt));
        (bool res,) = payable(winner).call{value: ctx.reward}("");
        require(res, "VanityFactory: reward send fail");

        emit Submited(id, score, salt, minedAddress);
    }

    function deploy(uint256 id, bytes calldata initCode) external {
        Context storage ctx = deploys[id];
        require(block.timestamp > ctx.endTime, "VanityFactory: bid time ended");
        require(keccak256(initCode) == ctx.initCodeHash, "VanityFactory: wrong init code hash");
        address minedAddress = Create2.deploy(0, ctx.salt, initCode);
        emit Deployed(id, minedAddress);
    }
}
