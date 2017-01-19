function distMat = CalcDistMat_Cosn(dataMatQry, dataMatDtb)
% INTRO
%   compute the pair-wise cosine distance matrix
% INPUT
%   dataMatQry: D x N_Q (data matrix of all query instances)
%   dataMatDtb: D x N_D (data matrix of all database instances)
% OUTPUT
%   distMat: N_Q x N_D (pair-wise cosine distance matrix)

% define constant variables
kDataCntPerBatch = 100000; % number of samples per batch

% obtain basic variables
dataCntQry = size(dataMatQry, 2);
dataCntDtb = size(dataMatDtb, 2);
batchCnt = ceil(dataCntDtb / kDataCntPerBatch);

% apply L2-normalization to all instances
dataMatQryNrm = sqrt(sum(dataMatQry .^ 2, 1));
dataMatQry = bsxfun(@times, dataMatQry, 1 ./ dataMatQryNrm);
dataMatDtbNrm = sqrt(sum(dataMatDtb .^ 2, 1));
dataMatDtb = bsxfun(@times, dataMatDtb, 1 ./ dataMatDtbNrm);

% compute the distance matrix
distMat = zeros(dataCntQry, dataCntDtb, 'single');
for batchIdx = 1 : batchCnt
  dataIdxBeg = (batchIdx - 1) * kDataCntPerBatch + 1;
  dataIdxEnd = min(dataCntDtb, dataIdxBeg + kDataCntPerBatch - 1);
  dataIdxLst = (dataIdxBeg : dataIdxEnd);
  dataMatDtbSel = dataMatDtb(:, dataIdxLst);
  simiMatSel = dataMatQry' * dataMatDtbSel;
  distMat(:, dataIdxLst) = (1 - simiMatSel) / 2;
end

end
