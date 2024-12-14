// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "fhevm/lib/TFHE.sol";
import { IStrategy } from "../interfaces/IStrategy.sol";
import { Storage } from "../Storage.sol";

contract BasicIdentityStrategy is IStrategy {
    Storage internal st;

    address internal owner;
    ebytes256 internal firstname;
    ebytes256 internal lastname;
    ebool internal isFemale;
    euint256 internal dateOfBirth;
    ebytes64 internal nationality;

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

    function submitData(
        einput encryptedFirstname,
        einput encryptedLastname,
        einput encryptedIsFemale,
        einput encryptedDateOfBirth,
        einput encryptedNationality,
        bytes calldata inputProof
    ) external {
        firstname = TFHE.asEbytes256(encryptedFirstname, inputProof);
        lastname = TFHE.asEbytes256(encryptedLastname, inputProof);
        dateOfBirth = TFHE.asEuint256(encryptedDateOfBirth, inputProof);
        isFemale = TFHE.asEbool(encryptedIsFemale, inputProof);
        nationality = TFHE.asEbytes64(encryptedNationality, inputProof);
        lastDataSubmissionTimestamp = block.timestamp;
    }

    function submitResult(bool _result) external {
        lastResultSubmissionTimestamp = block.timestamp;
        _isVerified = _result;
        lastVerifier = msg.sender;
    }

    function verify() external view returns (string memory, bytes memory) {
        string memory guide = "function verify(bytes document, string userAddress)"
        "const metadata = extractMetadataFromDocument(document)"
        "const submittedMetadata = contract.getSubmittedMetadata(userAddress)"
        "return compareObject(metadata, submittedMetadata)";

        bytes memory data = st.getPassportOrId(owner);

        require(data.length > 0, "Empty passport or id");

        return (guide, data);
    }

    function isVerified() external view override returns (bool) {
        return _isVerified;
    }
}
