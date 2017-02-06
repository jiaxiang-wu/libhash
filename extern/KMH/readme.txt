
***************************************************************************************
***************************************************************************************

Matlab demo code for "K-means Hashing: an Affinity-Preserving Quantization Method

for Learning Binary Compact Codes" (CVPR 2013)

by Kaiming He (kahe@microsoft.com), Mar. 2013

If you use/adapt our code, please appropriately cite our CVPR 2013 paper.

This code is for academic purpose only. Not for commercial/industrial activities.

***************************************************************************************
***************************************************************************************

Usage:

1. Compile the cpp file in \mex (run compile_mex.m).
   This allows fast hamming ranking (for evaluation only) using SSE and openmp.
2. Run main_demo.m. This should reproduce Fig. 5.
3. Run main_demo_geometric.m. This should illustrate Fig. 3.

Notice:
1. The attached SIFT dataset is from Herve Jegou et al.(corpus-texmex.irisa.fr/).
2. The ITQ implementation is due to Gong and Lazebnik (www.unc.edu/~yunchao/itq.htm).

Any bug report or discussion is highly appreciated.
