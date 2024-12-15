// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "fhevm/lib/TFHE.sol";
import { SepoliaZamaFHEVMConfig } from "fhevm/config/ZamaFHEVMConfig.sol";
import { IStrategy } from "../interfaces/IStrategy.sol";
import { Storage } from "../Storage.sol";

contract BasicIdentityStrategy is IStrategy, SepoliaZamaFHEVMConfig {
    Storage internal st;

    address internal owner;
    ebytes256 internal firstname;
    ebytes256 internal lastname;
    ebool internal gender;
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

    function submitFirstname(einput encryptedFirstname, bytes calldata inputProof) external {
        firstname = TFHE.asEbytes256(encryptedFirstname, inputProof);
    }

    function submitLastname(einput encryptedFirstname, bytes calldata inputProof) external {
        lastname = TFHE.asEbytes256(encryptedFirstname, inputProof);
    }

    function submitDob(einput _dateOfBirth, bytes calldata inputProof) external {
        dateOfBirth = TFHE.asEuint256(_dateOfBirth, inputProof);
    }

    function submitGender(einput _dateOfBirth, bytes calldata inputProof) external {
        gender = TFHE.asEbool(_dateOfBirth, inputProof);
    }

    function submitNationality(einput _dateOfBirth, bytes calldata inputProof) external {
        nationality = TFHE.asEbytes64(_dateOfBirth, inputProof);
        lastDataSubmissionTimestamp = block.timestamp;
    }

    function submitData(
        einput encryptedFirstname,
        einput encryptedLastname,
        einput encryptedGender,
        einput encryptedDateOfBirth,
        einput encryptedNationality,
        bytes calldata inputProof
    ) external {
        firstname = TFHE.asEbytes256(encryptedFirstname, inputProof);
        lastname = TFHE.asEbytes256(encryptedLastname, inputProof);
        dateOfBirth = TFHE.asEuint256(encryptedDateOfBirth, inputProof);
        gender = TFHE.asEbool(encryptedGender, inputProof);
        nationality = TFHE.asEbytes64(encryptedNationality, inputProof);
        lastDataSubmissionTimestamp = block.timestamp;
    }

    function submitResult(bool _result) external payable {
        lastResultSubmissionTimestamp = block.timestamp;
        _isVerified = _result;
        lastVerifier = msg.sender;
    }

    function verify() external view returns (string memory, bytes memory) {
        require(lastDataSubmissionTimestamp > 0, "No data to verify");
        bytes memory data = st.getPassportOrId(owner);
        require(data.length > 0, "Empty passport or id");

        string memory script = "function verify(bytes document, string userAddress)"
        "const metadata = extractMetadataFromDocument(document)"
        "const submittedMetadata = contract.getSubmittedMetadata(userAddress)"
        "return compareObject(metadata, submittedMetadata)";

        return (script, data);
    }

    function isVerified() external view returns (bool) {
        return _isVerified;
    }
}
