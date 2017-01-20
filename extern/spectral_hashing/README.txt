----------------------------------------------------------
Spectral Hashing
Y. Weiss, A. Torralba, R. Fergus
Advances in Neural Information Processing Systems, 2008.
----------------------------------------------------------

CONVENTIONS: Data are row vectors.

MATLAB FUNCTIONS:

Spectral Hashing:
 trainSH.m - script to train code
 compressSH.m - function to compress data

Distances:
 distMat.m - function to compute euclidean distance between vector sets
 hammingDist.m - function to compute hamming distance between compressed vector sets

Evaluation:
 evaluation.m - function that plots precision - recall graphs

Visualization: 
 show2dfun.m - visualized eigen functions for 2D data


Hashing: 
 semantic_hash.m - semantic hashing implementation
 hash_ham6.cpp - MEX file that does core routine
 test_semantic_hash.m - test routine that compares semantic hashing
                        implemetation to exhaustive search
 ndx2bit.m - utility function that converts binary vectors to uint8 blocks