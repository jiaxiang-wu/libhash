# Introduction

This project aims at intergrating popular hashing-based ANN search methods
into one unified framework for more convenient performance comparison. At the
same time, some of our own exploration in this area will also be presented.

# Methods

In this repository, we include the following methods:

## Implemented Methods

* LSH: Locality Sensitive Hashing
* MCLSH (L2-LSH): Multi-cut Locality Sensitive Hashing
* ITQ: Iterative Quantization
* DITQ: Dual Iterative Quantization
* BPB: Binary Projection Bank
* SDH: Supervised Discrete Hashing
* TSH: Two-Step Hashing
* KSDH: Kernel-based Supervised Discrete Hashing

## Experimental Methods

* MCSDH: Multi-Cut Supervised Discrete Hashing
* IPH: Infinite Partition Hashing
* ITQ-IP: Iterative Quantization with Infinite Partition
* TSH-IP: Two-Step Hashing with Infinite Partition
* SHIP: Supervised Hashing with Infinite Partition
* HTPQ: Hashing with Triple Partition Quantization

# External Dependency

For the first-order gradient-based optimization, we rely on an external 
[GitHub repository](https://github.com/jiaxiang-wu/GradOpt), which implements
four optimization techniques: SGD, AdaGrad, AdaDelta, and Adam.

