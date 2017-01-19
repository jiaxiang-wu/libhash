/*
 * Copyright © CASIA 2015-2016.
 *
 * Authors: Jiaxiang Wu
 * E-mail: jiaxiang.wu.90@gmail.com
 */

#ifndef MEX_TOPKINDEX_H_
#define MEX_TOPKINDEX_H_

#include <float.h>
#include <stdint.h>

#include <vector>

typedef struct {
  std::size_t ind;
  float val;
} HeapNodeStr;
typedef std::vector<HeapNodeStr> HeapNodeLst;

class TopKIndex {
 public:
  // find the top-k minimal elements
  void CalcTopKIndex(const float* valLst,
      const int valCnt, const int heapNodeCnt, uint32_t* indLst);

 private:
  // vector array representing the max-heap
  HeapNodeLst heapNodeLst_;
  // number of nodes in the max-heap
  int heapNodeCnt_;

 private:
  // initialize the max-heap
  void InitMaxHeap(const float* valLst, const int valCnt);
  // maintain the max-heap
  void KeepMaxHeap(const int heapNodeIndRoot);
};

// implementation of member functions

void TopKIndex::CalcTopKIndex(const float* valLst,
    const int valCnt, const int heapNodeCnt, uint32_t* indLst) {
  // construct a max-heap using the first k elements
  heapNodeCnt_ = heapNodeCnt;
  InitMaxHeap(valLst, valCnt);

  // scan through the remaining elements
  for (int valInd = heapNodeCnt_; valInd < valCnt; valInd++) {
    // only insert elements smaller than the root node value
    if (valLst[valInd] < heapNodeLst_[0].val) {
      // replace the root node
      heapNodeLst_[0].ind = valInd;
      heapNodeLst_[0].val = valLst[valInd];

      // let the max-heap keep its property
      KeepMaxHeap(0);
    }  // ENDIF: valLst
  }  // ENDFOR: valInd

  // extract the indices of the top-k minimal elements
  for (int heapNodeInd = 0; heapNodeInd < heapNodeCnt_; heapNodeInd++) {
    // record the current element at the heap top
    indLst[heapNodeCnt_ - heapNodeInd - 1] = heapNodeLst_[0].ind;

    // replace the root node with a small value and then keep it as a max-heap
    heapNodeLst_[0].val = -FLT_MAX;
    KeepMaxHeap(0);
  }  // ENDFOR: heapNodeInd
}

void TopKIndex::InitMaxHeap(const float* valLst, const int valCnt) {
  // allocate space for <heapNodeLst_>
  heapNodeLst_.resize(heapNodeCnt_);

  // add the first k elements to the max-heap
  for (int heapNodeInd = 0; heapNodeInd < heapNodeCnt_; heapNodeInd++) {
    heapNodeLst_[heapNodeInd].ind = heapNodeInd;
    heapNodeLst_[heapNodeInd].val = valLst[heapNodeInd];
  }  // ENDFOR: heapNodeInd

  // make <heapNodeLst_> become a max-heap
  for (int heapNodeInd = heapNodeCnt_ - 1; heapNodeInd >= 0; heapNodeInd--) {
    KeepMaxHeap(heapNodeInd);
  }  // ENDFOR: heapNodeInd
}

void TopKIndex::KeepMaxHeap(const int heapNodeIndRoot) {
  // get the indices of root/left-child/right-child nodes
  int heapNodeIndMax = heapNodeIndRoot;
  int heapNodeIndLChd = (heapNodeIndRoot << 1) + 1;
  int heapNodeIndRChd = heapNodeIndLChd + 1;

  // update <heapNodeIndMin> with <heapNodeIndLChd> if needed
  if ((heapNodeIndLChd < heapNodeCnt_) &&
      (heapNodeLst_[heapNodeIndMax].val < heapNodeLst_[heapNodeIndLChd].val)) {
    heapNodeIndMax = heapNodeIndLChd;
  }  // ENDIF: heapNodeIndLChd

  // update <heapNodeIndMin> with <heapNodeIndRChd> if needed
  if ((heapNodeIndRChd < heapNodeCnt_) &&
      (heapNodeLst_[heapNodeIndMax].val < heapNodeLst_[heapNodeIndRChd].val)) {
    heapNodeIndMax = heapNodeIndRChd;
  }  // ENDIF: heapNodeIndRChd

  // swap min-heap node if needed
  if (heapNodeIndMax != heapNodeIndRoot) {
    // swap two elements
    HeapNodeStr heapNodeStr = heapNodeLst_[heapNodeIndMax];
    heapNodeLst_[heapNodeIndMax] = heapNodeLst_[heapNodeIndRoot];
    heapNodeLst_[heapNodeIndRoot] = heapNodeStr;

    // recover the heap property of the child tree
    KeepMaxHeap(heapNodeIndMax);
  }  // ENDFOR: heapNodeIndMax
}

#endif  // MEX_TOPKINDEX_H_
