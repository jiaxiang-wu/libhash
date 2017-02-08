# Introduction

This project aims at intergrating popular hashing-based ANN search methods into one unified framework for more convenient performance comparison and further improvement.

We have now included the following methods:

* **LSH**: Locality Sensitive Hashing (SCG '04)
* **SH**: Spectral Hashing (NIPS '08)
* **ITQ**: Iterative Quantization (CVPR '11)
* **AGH**: Anchor Graph Hashing (ICML '11)
* **SpH**: Spherical Hashing (CVPR '12)
* **IsoH**: Isotropic Hashing (NIPS '12)
* **IMH**: Inductive Manifold Hashing (CVPR '13)
* **KMH**: K-means Hashing (CVPR '13)
* **SGH**: Scalable Graph Hashing (IJCAI '15)

Many thanks to the above methods' authors for their research and kindly provided source code.

# Evaluation Results

We evaluate all the above methods on two commonly used ANN search data sets: SIFT1M and GIST1M. For each methods, we evaluate it with two ANN search strategies:

* Hamming ranking: sort all candidates w.r.t. their Hamming distance to the query.
* Hash look-up: retrieve candidates whose Hamming distance to the query is within 2.

We report the MeanAP (Mean Average Precision) scores for Hamming ranking, and recall scores for hash look-up. For each query, the ground-truth matches are defined as its top-100/1K/10K nearest neighbors in the Euclidean space. The training process is carried out on the learning subset of each data set.

Please note: The hyper-parameters of these hashing methods are not carefully tuned. Most hyper-parameters are the same as the author's choices in their original source code, although the corresponding data sets may differ. It is possible that the MeanAP scores of some methods can be further improved.

## SIFT-1M

### Hamming Ranking

| Method   | 16-bit                | 32-bit                | 48-bit                | 64-bit                |
|----------|:---------------------:|:---------------------:|:---------------------:|:---------------------:|
| LSH      | .0050 / .0189 / .0934 | .0200 / .0513 / .1548 | .0364 / .0891 / .2276 | .0582 / .1261 / .2742 |
| SH       | .0145 / .0482 / .1551 | .0481 / .1038 / .2148 | .0778 / .1431 / .2521 | .1017 / .1662 / .2652 |
| ITQ      | .0084 / .0341 / .1647 | .0325 / .0933 / .2919 | .0588 / .1438 / .3729 | .0895 / .1923 / .4260 |
| AGH-1    | .0077 / .0364 / .1656 | .0212 / .0761 / .2442 | .0374 / .1030 / .2808 | .0506 / .1298 / .3091 |
| AGH-2    | .0031 / .0194 / .1168 | .0133 / .0480 / .1913 | .0221 / .0735 / .2314 | .0302 / .0940 / .2562 |
| SpH      | .0088 / .0329 / .1277 | .0308 / .0787 / .2197 | .0598 / .1320 / .2930 | .0870 / .1729 / .3359 |
| IsoH-LP  | .0127 / .0426 / .1529 | .0420 / .1180 / .2501 | .0734 / .1510 / .3285 | .0911 / .1826 / .3554 |
| IsoH-GF  | .0101 / .0399 / .1491 | .0363 / .0921 / .2625 | .0662 / .1385 / .3240 | .0876 / .1746 / .3848 |
| IMH-LE   | .0036 / .0192 / .0965 | .0099 / .0427 / .1712 | .0164 / .0626 / .2294 | .0223 / .0756 / .2497 |
| IMH-tSNE | .0035 / .0208 / .1110 | .0046 / .0254 / .1278 | .0061 / .0310 / .1478 | .0078 / .0381 / .1709 |
| KMH      | .0100 / .0368 / .1505 | .0414 / .1018 / .2606 | N/A                   | .1166 / .2056 / .3540 |
| SGH      | .0086 / .0377 / .1623 | .0314 / .0939 / .2824 | .0562 / .1421 / .3523 | .0902 / .1914 / .4058 |

### Hash Look-up

| Method   | 16-bit                | 32-bit                | 48-bit                | 64-bit                |
|----------|:---------------------:|:---------------------:|:---------------------:|:---------------------:|
| LSH      | .3637 / .2761 / .1800 | .0714 / .0414 / .0160 | .0116 / .0034 / .0006 | .0027 / .0007 / .0001 |
| SH       | .4601 / .3348 / .1833 | .0343 / .0118 / .0021 | .0025 / .0006 / .0001 | .0006 / .0001 / .0000 |
| ITQ      | .8052 / .7438 / .6490 | .3083 / .2313 / .1449 | .1116 / .0780 / .0439 | .0577 / .0402 / .0191 |
| AGH-1    | .5833 / .4903 / .3541 | .1550 / .0933 / .0377 | .0349 / .0169 / .0041 | .0069 / .0022 / .0004 |
| AGH-2    | .7441 / .6785 / .5734 | .2598 / .1835 / .1001 | .0934 / .0513 / .0179 | .0306 / .0141 / .0037 |
| SpH      | .3813 / .2859 / .1764 | .0682 / .0395 / .0147 | .0206 / .0095 / .0018 | .0072 / .0027 / .0004 |
| IsoH-LP  | .5238 / .4078 / .2569 | .0913 / .0449 / .0137 | .0080 / .0021 / .0003 | .0047 / .0012 / .0002 |
| IsoH-GF  | .6641 / .5665 / .4262 | .1445 / .0848 / .0345 | .0306 / .0156 / .0038 | .0091 / .0037 / .0005 |
| IMH-LE   | .7074 / .6471 / .5473 | .4197 / .3499 / .2505 | .2296 / .1727 / .1064 | .1405 / .0987 / .0527 |
| IMH-tSNE | .8843 / .8494 / .7778 | .8012 / .7482 / .6521 | .5017 / .4263 / .3069 | .5130 / .4406 / .3310 |
| KMH      | .5699 / .4758 / .3539 | .0867 / .0485 / .0167 | N/A                   | .0011 / .0002 / .0000 |
| SGH      | .6823 / .5812 / .4294 | .1989 / .1250 / .0548 | .0559 / .0273 / .0066 | .0233 / .0138 / .0039 |

## GIST-1M

To be added.
