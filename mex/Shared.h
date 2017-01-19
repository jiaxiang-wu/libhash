/*
 * Copyright © CASIA 2015-2016.
 *
 * Authors: Jiaxiang Wu
 * E-mail: jiaxiang.wu.90@gmail.com
 */

#ifndef MEX_SHARED_H_
#define MEX_SHARED_H_

// initialize shared constant variables
const int kNumOfThread = 8;  // number of threads been used
const int kCompCodeCap = 64;  // the capacity of each compact hash code bit
const double kEpsilon = 0.00000001;  // float-point number's error limit

#endif  // MEX_SHARED_H_
