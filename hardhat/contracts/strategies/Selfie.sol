// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "fhevm/lib/TFHE.sol";
import { IStrategy } from "../interfaces/IStrategy.sol";
import { Storage } from "../Storage.sol";

contract SelfieStrategy is IStrategy {
    Storage internal st;

    address internal owner;

    uint256 lastDataSubmissionTimestamp;
    uint256 lastResultSubmissionTimestamp;
    address lastVerifier;

    bool internal _isVerified;

    constructor(address _st, address _owner) {
        if (_owner == address(0)) {
            owner = msg.sender;
        } else {
            owner = _owner;
        }
        st = Storage(_st);
    }

    function submitSelfie(bytes calldata encryptedPassportOrId, bool isPassport) external {
        if (isPassport) {
            st.savePassport(encryptedPassportOrId);
        } else {
            st.saveId(encryptedPassportOrId);
        }
        lastDataSubmissionTimestamp = block.timestamp;
    }

    // This will be payable and user gets back eth if result is not disputed
    function submitResult(bool _result) external {
        lastResultSubmissionTimestamp = block.timestamp;
        _isVerified = _result;
        lastVerifier = msg.sender;
    }

    function verify() external view returns (string memory, bytes memory) {
        string memory guide = "function verify(bytes document, string userAddress)"
        "return isEncryptedDocumentValid(document)";

        bytes memory data = st.getPassportOrId(owner);

        require(data.length > 0, "Empty passport or id");

        return (guide, data);
    }

    function isVerified() external view override returns (bool) {
        return _isVerified;
    }
}
