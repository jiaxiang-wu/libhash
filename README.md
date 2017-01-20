# Introduction

This project aims at intergrating popular hashing-based ANN search methods
into one unified framework for more convenient performance comparison.

# Methods

We have now included the following methods:

* LSH: Locality Sensitive Hashing
* ITQ: Iterative Quantization
* SH: Spectral Hashing

# Evaluation

We report the MeanAP (Mean Average Precision) scores for above methods on SIFT-1M and GIST-1M data sets. For each query, the ground-truth matches are defined as the top-100/1K/10K nearest neighbors in the Euclidean space.

## SIFT1M

ANN Search of the top-100 nearest neighbors:

| Method | 16-bit | 32-bit | 48-bit | 64-bit |
|--------|--------|--------|--------|--------|
| LSH    | 0.0063 | 0.0214 | 0.0371 | 0.0627 |
| ITQ    | 0.0089 | 0.0311 | 0.0579 | 0.0880 |
| SH     | 0.0147 | 0.0481 | 0.0807 | 0.1012 |

ANN Search of the top-1K nearest neighbors:

| Method | 16-bit | 32-bit | 48-bit | 64-bit |
|--------|--------|--------|--------|--------|
| LSH    | 0.0202 | 0.0493 | 0.0879 | 0.1136 |
| ITQ    | 0.0360 | 0.0899 | 0.1425 | 0.1931 |
| SH     | 0.0483 | 0.1012 | 0.1452 | 0.1634 |

ANN Search of the top-10K nearest neighbors:

| Method | 16-bit | 32-bit | 48-bit | 64-bit |
|--------|--------|--------|--------|--------|
| LSH    | 0.0957 | 0.1654 | 0.2277 | 0.2851 |
| ITQ    | 0.1626 | 0.2878 | 0.3701 | 0.4271 |
| SH     | 0.1536 | 0.2089 | 0.2528 | 0.2614 |

## GIST1M

To be added.
