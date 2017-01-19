/*
 * Copyright © CASIA 2015-2016.
 *
 * Authors: Jiaxiang Wu
 * E-mail: jiaxiang.wu.90@gmail.com
 */

#include <mex.h>

#include "TopKIndex.h"

// input paramters:
// 1. instDistLst
// 2. instCntRtrv
// output parameters:
// 1. instIndxLst
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
  if (nrhs != 2) {
    mexErrMsgTxt("[MEX-FUNC] invalid input parameters\n");
  }  // ENDIF: nrhs

  // check input parameters' class ID
  if (mxGetClassID(prhs[0]) != mxSINGLE_CLASS) {
    mexErrMsgTxt("[MEX-FUNC] incorrect class ID for input #1\n");
  }  // ENDIF: prhs[0]
  if (mxGetClassID(prhs[1]) != mxDOUBLE_CLASS) {
    mexErrMsgTxt("[MEX-FUNC] incorrect class ID for input #2\n");
  }  // ENDIF: prhs[1]

  // assign pointer for <instDistLst>
  std::size_t instCnt = mxGetNumberOfElements(prhs[0]);
  float* pInstDistLst = reinterpret_cast<float*>(mxGetData(prhs[0]));

  // obtain the value of <instCntRtrv>
  double* pInstCntRtrv = reinterpret_cast<double*>(mxGetData(prhs[1]));
  std::size_t instCntRtrv = static_cast<int>(*pInstCntRtrv + 0.5);

  // assign pointer for <instIndxLst>
  std::size_t cntRowInstIndxLst = 1;
  std::size_t cntColInstIndxLst = instCntRtrv;
  plhs[0] = mxCreateNumericMatrix(
      cntRowInstIndxLst, cntColInstIndxLst, mxUINT32_CLASS, mxREAL);
  uint32_t* pInstIndxLst = reinterpret_cast<uint32_t*>(mxGetPr(plhs[0]));

  // compute the indices of k smallest elements
  TopKIndex topKIndexObj;
  topKIndexObj.CalcTopKIndex(pInstDistLst, instCnt, instCntRtrv, pInstIndxLst);
}
