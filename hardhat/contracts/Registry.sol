// SPDX-License-Identifier: GPL-2.0
// Taken from https://github.com/Uniswap/v4-periphery/blob/main/src/base/Multicall_v4.sol
pragma solidity ^0.8.24;

import { IKYC } from "./interfaces/IKYC.sol";
import { KYC } from "./KYC.sol";

/// @title Registry
/// @notice Registry for authenticated users
/// @notice Main entrypoint for the feed via a multicall
contract Registry {
    mapping(address => IKYC) kycs;

    address st;

    constructor(address _st) {
        st = _st;
    }

    function createInstance() external {
        IKYC kyc = new KYC(0, msg.sender, st);
        kycs[msg.sender] = kyc;
    }
}
