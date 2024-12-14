// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "fhevm/lib/TFHE.sol";

contract Storage {
    mapping(address => bytes) ids;
    mapping(address => bytes) passports;

    function savePassport(bytes memory data) external {
        require(passports[msg.sender].length == 0, "Use already has passport");
        passports[msg.sender] = data;
    }

    function saveId(bytes memory data) external {
        require(ids[msg.sender].length == 0, "Use already has id");
        ids[msg.sender] = data;
    }

    function getPassportOrId(address _owner) external view returns (bytes memory) {
        bytes memory passport = passports[_owner];
        if (passport.length > 0) {
            return passport;
        }
        bytes memory id = ids[_owner];
        if (id.length > 0) {
            return id;
        }
        revert("No id or passport");
    }
}
