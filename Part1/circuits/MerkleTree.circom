pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/switcher.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    var numOfLeaves = 2**n;

    signal parents[numOfLeaves - 1];
    component poseidonHash[numOfLeaves - 1];

    for (var i = 0; i < (numOfLeaves - 1); i++) {
        poseidonHash[i] = Poseidon(2);
    }

    for (var i = 0; i < (numOfLeaves - 1); i += 2) {
        poseidonHash[i/2].inputs[0] <== leaves[i];
        poseidonHash[i/2].inputs[1] <== leaves[i+1];

        parents[i/2] <== poseidonHash[i/2].out;
    }

    var index = 0;
    var leafLength = numOfLeaves/2;

    for (var i = leafLength; i < (numOfLeaves - 1); i++) {
        poseidonHash[i].inputs[0] <== parents[index].out;
        poseidonHash[i].inputs[1] <== parents[index+1].out;

        index = index + 2;
        parents[i] <== poseidonHash[i].out;
    }

    root <== parents[numOfLeaves - 2].out;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component hash[n];
    component switch[n];

    for (var i = 0; i < n; i++) {
        switch[i] = Switcher();
        
        if (i == 0) {
            switch[i].L <== leaf;
        } else {
            switch[i].L <== hash[i-1].out;
        }

        switch[i].R <== path_elements[i];
        switch[i].sel <== path_index[i];

        hash[i] = Poseidon(2);
        hash[i].inputs[0] <== switch[i].outL;
        hash[i].inputs[1] <== switch[i].outR;
    }

    root <== hash[n-1].out;
}