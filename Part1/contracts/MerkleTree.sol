//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        for (uint8 i = 0; i < 8; i++) {
            hashes.push(0);
        }

        uint8 depth = 3;
        uint256 leaves = 2**depth;
        for (uint8 i = 0; i < leaves - 2; i++) {
            hashes.push(hashTwo(hashes[2*i], hashes[2*i + 1]));
        }
    }

    function hashTwo(uint256 _left, uint256 _right) internal pure returns (uint256) {
        uint256[2] memory hashInputs;
        hashInputs[0] = _left;
        hashInputs[1] = _right;
        return PoseidonT3.poseidon(hashInputs);
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        uint8 depth = 3;
        hashes[index] = hashedLeaf;

        uint256 idx = index;
        for (uint256 i = depth; i == 1; i--) {
            uint256 loc = 2**(depth + 1) - 2**i + idx/2;
            if (idx % 2 == 0) {
                hashes[loc] = hashTwo(hashes[idx], hashes[idx + 1]);
            } else {
                hashes[loc] = hashTwo(hashes[idx - 1], hashes[idx]);
            }   
            idx = idx / 2;
        }
        index = index + 1;
        return hashes[hashes.length - 1];
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return verifyProof(a, b, c, input);
    }
}
