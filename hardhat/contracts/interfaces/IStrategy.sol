// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface IStrategy {
    // Get the instructions and data to run the verification
    function verify() external returns (string memory, bytes memory);
    // Submit the result
    function submitResult(bool) external;
    function isVerified() external view returns (bool);
}
