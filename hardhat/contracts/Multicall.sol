// SPDX-License-Identifier: GPL-2.0
// Taken from https://github.com/Uniswap/v4-periphery/blob/main/src/base/Multicall_v4.sol
pragma solidity ^0.8.24;

import { IMulticall } from './interfaces/IMulticall.sol';

/// @title Multicall
/// @notice Enables calling multiple methods in a single call to the contract
contract Multicall is IMulticall {
    /// @inheritdoc IMulticall
    function multicall(
        bytes[] calldata data
    ) external payable override returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                // bubble up the revert reason
                assembly {
                    revert(add(result, 0x20), mload(result))
                }
            }

            results[i] = result;
        }
    }
}