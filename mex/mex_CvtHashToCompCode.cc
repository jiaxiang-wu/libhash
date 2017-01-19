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
// 1. hashCode
// output parameters:
// 1. compCode
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
  if (nrhs != 1) {
      mexErrMsgTxt("invalid input parameters\n");
  }  // ENDIF: nrhs

  // check input parameters' class ID
  if (mxGetClassID(prhs[0]) != mxUINT8_CLASS) {
    mexErrMsgTxt("[MEX-FUNC] incorrect class ID for input #1\n");
  }  // ENDIF: prhs[0]

  // assign pointer for <hashCode>
  int cntRowHashCode = mxGetM(prhs[0]);
  int cntColHashCode = mxGetN(prhs[0]);
  uint8_t* pHashCode = reinterpret_cast<uint8_t*>(mxGetData(prhs[0]));

  // obtain basic variables' values
  int hashCodeLen = cntRowHashCode;
  int instCnt = cntColHashCode;
  int compCodeLen = (hashCodeLen - 1) / kCompCodeCap + 1;

  // assign pointer for <compCode>
  int cntRowCompCode = compCodeLen;
  int cntColCompCode = instCnt;
  plhs[0] = mxCreateNumericMatrix(
      cntRowCompCode, cntColCompCode, mxUINT64_CLASS, mxREAL);
  uint64_t* pCompCode = reinterpret_cast<uint64_t*>(mxGetPr(plhs[0]));
  #define compCode(r, c) pCompCode[(c) * cntRowCompCode + (r)]

  // convert original hash code into compact hash code
  #pragma omp parallel for num_threads(kNumOfThread)
  for (int instInd = 0; instInd < instCnt; instInd++) {
    // obtain pointers for the current instance
    const uint8_t* hashCodePtr = pHashCode + hashCodeLen * instInd;
    uint64_t* compCodePtr = pCompCode + compCodeLen * instInd;

    // scan through all compact code indexes
    for (int compCodeInd = 0; compCodeInd < compCodeLen; compCodeInd++) {
      uint64_t compCodeVal = 0;
      int hashCodeIndBeg = kCompCodeCap * compCodeInd;
      int hashCodeIndEnd = std::min(hashCodeLen, hashCodeIndBeg + kCompCodeCap);
      int loopCnt = hashCodeIndEnd - hashCodeIndBeg;

      for (int loopInd = loopCnt; loopInd > 0; loopInd--) {
        compCodeVal = (compCodeVal << 1) | *(hashCodePtr++);
      }  // ENDFOR: loopInd
      *(compCodePtr++) = compCodeVal;
    }  // ENDFOR: compCodeInd
  }  // ENDFOR: instInd
}
