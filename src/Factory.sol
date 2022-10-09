// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Scorer {
    function score(address input) external pure returns (uint256) {
        return 0;
    }
}

contract Factory {
    struct TBD {
        bytes initCode;
        Scorer scorer;
    }

    TBD[] public deploys;

    function ask(TBD calldata toBeDeployed) payable external returns (uint256 id) {
        id = deploys.length;
        deploys.push(toBeDeployed);
    }

    function bid(uint256 id, uint256 salt) external {
        TBD storage curr = deploys[id];
        address res = address(bytes20(keccak256(abi.encode(salt, curr.initCode))));
           
    }
}
