// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "fhevm/lib/TFHE.sol";
import { IStrategy } from "../interfaces/IStrategy.sol";
import { Storage } from "../Storage.sol";

contract IDStrategy is IStrategy {
    address internal owner;

    bytes internal selfie;

    uint256 lastDataSubmissionTimestamp;
    uint256 lastResultSubmissionTimestamp;
    address lastVerifier;

    bool internal _isVerified;

    constructor(address _owner) {
        if (_owner == address(0)) {
            owner = msg.sender;
        } else {
            owner = _owner;
        }
    }

    function submitDocument(bytes calldata _selfie) external {
        selfie = _selfie;
        lastDataSubmissionTimestamp = block.timestamp;
    }

    function submitResult(bool _result) external {
        lastResultSubmissionTimestamp = block.timestamp;
        _isVerified = _result;
        lastVerifier = msg.sender;
    }

    function verify() external view returns (string memory, bytes memory) {
        string memory guide = "function verify(bytes document, string userAddress)"
        "return isEncryptedDocumentValid(document)";

        return (guide, selfie);
    }

    function isVerified() external view override returns (bool) {
        return _isVerified;
    }
}
