# Introduction

This project aims at intergrating popular hashing-based ANN search methods into one unified framework for more convenient performance comparison and further improvement.

We have now included the following methods:

* **LSH**: Locality Sensitive Hashing (SCG '04)
* **SH**: Spectral Hashing (NIPS '08)
* **ITQ**: Iterative Quantization (CVPR '11)
* **AGH**: Anchor Graph Hashing (ICML '11)
* **SpH**: Spherical Hashing (CVPR '12)
* **IsoH**: Isotropic Hashing (NIPS '12)

Many thanks to the above methods' authors for their research and kindly provided source code.

# Evaluation Results

We report the MeanAP (Mean Average Precision) scores for above methods on SIFT-1M and GIST-1M data sets. The training process is carried out on the learning subset of each data set. For each query, the ground-truth matches are defined as its top-100/1K/10K nearest neighbors in the Euclidean space.

## SIFT-1M

The MeanAP scores for retrieving the top-100/1K/10K nearest neighbors:

| Method | 16-bit                | 32-bit                | 48-bit                | 64-bit                |
|--------|-----------------------|-----------------------|-----------------------|-----------------------|
| LSH    | .0050 / .0189 / .0934 | .0200 / .0513 / .1548 | .0364 / .0891 / .2276 | .0582 / .1261 / .2742 |
| SH     | .0145 / .0482 / .1551 | .0481 / .1038 / .2148 | .0778 / .1431 / .2521 | .1017 / .1662 / .2652 |
| ITQ    | .0084 / .0341 / .1647 | .0325 / .0933 / .2919 | .0588 / .1438 / .3729 | .0895 / .1923 / .4260 |
| AGH-1  | .0077 / .0364 / .1656 | .0212 / .0761 / .2442 | .0374 / .1030 / .2808 | .0506 / .1298 / .3091 |
| AGH-2  | .0031 / .0194 / .1168 | .0133 / .0480 / .1913 | .0221 / .0735 / .2314 | .0302 / .0940 / .2562 |
| SpH    | .0088 / .0329 / .1277 | .0308 / .0787 / .2197 | .0598 / .1320 / .2930 | .0870 / .1729 / .3359 |
| IsoH   | .0127 / .0426 / .1529 | .0420 / .1180 / .2501 | .0734 / .1510 / .3285 | .0911 / .1826 / .3554 |

## GIST-1M

To be added.
