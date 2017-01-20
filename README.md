# Introduction

This project aims at intergrating popular hashing-based ANN search methods
into one unified framework for more convenient performance comparison.

# Methods

We have now included the following methods:

* LSH: Locality Sensitive Hashing
* ITQ: Iterative Quantization
* SH: Spectral Hashing

# Evaluation

We report the MeanAP (Mean Average Precision) scores for above methods on SIFT-1M and GIST-1M data sets. For each query, the ground-truth matches are defined as the top-100 nearest neighbors in the Euclidean space.

| SIFT-1M | 16-bit | 32-bit | 48-bit | 64-bit |
|---------|--------|--------|--------|--------|
| LSH     | 0.0063 | 0.0214 | 0.0371 | 0.0627 |
| ITQ     | 0.0089 | 0.0311 | 0.0579 | 0.0880 |
| SH      | 0.0147 | 0.0481 | 0.0807 | 0.1012 |

Note: results on the GIST-1M data set shall be provided soon.