/*
 * Copyright © CASIA 2015-2016.
 *
 * Authors: Jiaxiang Wu
 * E-mail: jiaxiang.wu.90@gmail.com
 */

#include <mex.h>

#include <omp.h>
#include <stdint.h>

#include <iostream>

#include "Shared.h"

// input paramters:
// 1. compCodePri
// 2. compCodeSec
// output parameters:
// 1. distMat
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
  if (nrhs != 2) {
      mexErrMsgTxt("invalid input parameters\n");
  }  // ENDIF: nrhs

  // check input parameters' class ID
  if (mxGetClassID(prhs[0]) != mxUINT64_CLASS) {
    mexErrMsgTxt("[MEX-FUNC] incorrect class ID for input #1\n");
  }  // ENDIF: prhs[0]
  if (mxGetClassID(prhs[1]) != mxUINT64_CLASS) {
    mexErrMsgTxt("[MEX-FUNC] incorrect class ID for input #2\n");
  }  // ENDIF: prhs[1]

  // assign pointer for <compCodePri>
  int cntRowCompCodePri = mxGetM(prhs[0]);
  int cntColCompCodePri = mxGetN(prhs[0]);
  uint64_t* pCompCodePri = reinterpret_cast<uint64_t*>(mxGetData(prhs[0]));

  // assign pointer for <compCodeSec>
  int cntRowCompCodeSec = mxGetM(prhs[1]);
  int cntColCompCodeSec = mxGetN(prhs[1]);
  uint64_t* pCompCodeSec = reinterpret_cast<uint64_t*>(mxGetData(prhs[1]));

  // check if the compact code length is the same
  if (cntRowCompCodePri != cntRowCompCodeSec) {
      mexErrMsgTxt("input data's compact code length must be the same\n");
  }  // ENDIF: cntRowCompCodePri

  // obtain basic variables' values
  int compCodeLen = cntRowCompCodePri;
  int instCntPri = cntColCompCodePri;
  int instCntSec = cntColCompCodeSec;

  // assign pointer for <distMat>
  int cntRowDistMat = instCntPri;
  int cntColDistMat = instCntSec;
  plhs[0] = mxCreateNumericMatrix(
      cntRowDistMat, cntColDistMat, mxUINT16_CLASS, mxREAL);
  uint16_t* pDistMat = reinterpret_cast<uint16_t*>(mxGetPr(plhs[0]));
  #define distMat(r, c) pDistMat[(c) * cntRowDistMat + (r)]

  // compute pairwise Hamming distance
  #pragma omp parallel for num_threads(kNumOfThread)
  for (int instIndPri = 0; instIndPri < instCntPri; instIndPri++) {
    for (int instIndSec = 0; instIndSec < instCntSec; instIndSec++) {
      // obtain pointers
      const uint64_t* compCodePtrPri = pCompCodePri + compCodeLen * instIndPri;
      const uint64_t* compCodePtrSec = pCompCodeSec + compCodeLen * instIndSec;

      // compute the Hamming distance
      uint16_t distVal = 0;
      for (int compCodeInd = 0; compCodeInd < compCodeLen; compCodeInd++) {
        distVal += __builtin_popcountll(
            compCodePtrPri[compCodeInd] ^ compCodePtrSec[compCodeInd]);
      }  // ENDFOR: compCodeInd
      distMat(instIndPri, instIndSec) = distVal;
    }  // ENDFOR: instIndSec
  }  // ENDFOR: instIndPri
}
