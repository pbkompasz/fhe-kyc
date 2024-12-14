// SPDX-License-Identifier: GPL-2.0
// Taken from https://github.com/Uniswap/v4-periphery/blob/main/src/base/Multicall_v4.sol
pragma solidity ^0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IKYC } from "./interfaces/IKYC.sol";
import { IStrategy } from "./interfaces/IStrategy.sol";

import { BasicIdentityStrategy } from "./strategies/BasicIdentity.sol";
import { IDStrategy } from "./strategies/ID.sol";
import { SelfieStrategy } from "./strategies/Selfie.sol";

/// @title KYC
/// @notice Contains KYC strategies
contract KYC is IKYC, Ownable {
    // 12-digit unique identification
    uint256 id;
    bool isSponsored = false;

    IStrategy[] internal strategies;
    address st;

    constructor(uint sponsorPlatform, address originalOwner, address _st) Ownable(originalOwner) {
        // Generate unique id
        if (sponsorPlatform > 0) {
            isSponsored = true;
        }
        st = _st;
    }

    function addStrategy(uint8 strategyType) external onlyOwner {
        IStrategy newStrategy;
        if (strategyType == 0) {
            newStrategy = new BasicIdentityStrategy(st, owner());
        } else if (strategyType == 1) {
            newStrategy = new SelfieStrategy(st, owner());
        } else if (strategyType == 2) {
            newStrategy = new IDStrategy(owner());
        } else {
            revert("Strategy not supported");
        }
        strategies.push(newStrategy);
    }

    function getStrategy(uint index) public view returns (address) {
        return address(strategies[index]);
    }

    function link(uint256 accountId, bytes memory accountProof) public onlyOwner returns (bool, uint) {
        // Validate proof
        // Get KYC item
        // Link account
    }

    function isKycCompleted() public view returns (bool) {
        uint completed = 0;
        for (uint i = 0; i < strategies.length; i++) {
            if (IStrategy(strategies[i]).isVerified()) {
                completed += 1;
            }
        }

        return completed == strategies.length;
    }
}
