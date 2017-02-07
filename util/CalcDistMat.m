function distMat = CalcDistMat(dataMatQry, dataMatDtb, dstPrtl)
% INTRO
%   compute the pair-wise distance matrix
% INPUT
%   dataMatQry: D x N_Q (data matrix of all query instances)
%   dataMatDtb: D x N_D (data matrix of all database instances)
%   dstPrtl: string (distance computation protocal: 'ecld' or 'cosn')
% OUTPUT
%   distMat: N_Q x N_D (pair-wise distance matrix)

switch dstPrtl
  case 'ecld'
    distMat = CalcDistMat_Ecld(dataMatQry, dataMatDtb);
  case 'cosn'
    distMat = CalcDistMat_Cosn(dataMatQry, dataMatDtb);
  otherwise
    fprintf('[ERROR] unsupported distance computation protocal\n');
    return;
end

end

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
