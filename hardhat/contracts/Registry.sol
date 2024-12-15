// SPDX-License-Identifier: GPL-2.0
// Taken from https://github.com/Uniswap/v4-periphery/blob/main/src/base/Multicall_v4.sol
pragma solidity ^0.8.24;

import { IKYC } from "./interfaces/IKYC.sol";
import { KYC } from "./KYC.sol";

/// @title Registry
/// @notice Registry for authenticated users
/// @notice Main entrypoint for the feed via a multicall
contract Registry {
    mapping(address => IKYC) internal kycs;
    mapping(bytes => IKYC) internal accountKycs;
    uint internal kycInstances = 0;

    address internal st;

    constructor(address _st) {
        st = _st;
    }

    function createInstance() external returns (address) {
        IKYC kyc = new KYC(0, msg.sender, st);
        kycs[msg.sender] = kyc;
        kycInstances+= 1;
        return address(kyc);
    }

    function createInstance(uint sponsorPlatform, bytes memory accountProof) external {
        IKYC kyc = new KYC(sponsorPlatform, msg.sender, st);
        kyc.linkAccount(sponsorPlatform, accountProof);
        // ??
        accountKycs[accountProof] = kyc;
        kycInstances+= 1;
    }

    function getKyc(address user) external view returns (address) {
        address kycAddress = address(kycs[user]);
        require(kycAddress != address(0), "No KYC for user");
        return kycAddress;
    }

    function getKycForAccount(bytes memory account) external view returns (address) {
        address kycAddress = address(accountKycs[account]);
        require(kycAddress != address(0), "No KYC for user");
        return kycAddress;
    }

    function getNumberOfInstances() external view returns (uint) {
        return kycInstances;
    }
}
