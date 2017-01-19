function distMat = CalcDistMat_Ecld(dataMatQry, dataMatDtb)
% INTRO
%   compute the pair-wise Euclidean distance matrix
% INPUT
%   dataMatQry: D x N_Q (data matrix of all query instances)
%   dataMatDtb: D x N_D (data matrix of all database instances)
% OUTPUT
%   distMat: N_Q x N_D (pair-wise Euclidean distance matrix)

% define constant variables
kDataCntPerBatch = 100000; % number of samples per batch

% obtain basic variables
dataCntQry = size(dataMatQry, 2);
dataCntDtb = size(dataMatDtb, 2);
batchCnt = ceil(dataCntDtb / kDataCntPerBatch);

% compute the distance matrix
dataMatQryNrm = sum(dataMatQry .^ 2, 1);
distMat = zeros(dataCntQry, dataCntDtb, 'single');
for batchIdx = 1 : batchCnt
  dataIdxBeg = (batchIdx - 1) * kDataCntPerBatch + 1;
  dataIdxEnd = min(dataCntDtb, dataIdxBeg + kDataCntPerBatch - 1);
  dataIdxLst = (dataIdxBeg : dataIdxEnd);
  dataMatDtbSel = dataMatDtb(:, dataIdxLst);
  dataMatDtbNrm = sum(dataMatDtbSel .^ 2, 1);
  distMatSel = bsxfun(@plus, bsxfun(@plus, ...
      -2 * dataMatQry' * dataMatDtbSel, dataMatQryNrm'), dataMatDtbNrm);
  distMat(:, dataIdxLst) = real(sqrt(distMatSel));
end

end
