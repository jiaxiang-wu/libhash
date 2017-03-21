function model = TrnHashMdl_SDH(dataMat, paraStr, extrInfo)
% INTRO
%   train a hashing model of SGH
% INPUT
%   dataMat: D x N (data matrix)
%   paraStr: struct (hyper-parameters)
%   extrInfo: 1 x 2 (cell array of label vector and affinity matrix)
% OUTPUT
%   model: struct (hashing model)

% display the greeting message
fprintf('[INFO] entering TrnHashMdl_SDH()\n');

% randomly select a subset of instances for training
smplCnt = size(dataMat, 2);
smplCntTrn = min(smplCnt, paraStr.smplCntTrn);
smplIdxLstTrn = sort(randperm(smplCnt, smplCntTrn));
dataMatTrn = dataMat(:, smplIdxLstTrn);
lablVecTrn = extrInfo{1}(smplIdxLstTrn);

% expand the label vector into a 0/1 indicator matrix
clssIdLst = unique(lablVecTrn);
clssIdCnt = numel(clssIdLst);
lablMatTrn = zeros(clssIdCnt, smplCntTrn);
for clssIdIdx = 1 : clssIdCnt
  lablMatTrn(clssIdIdx, lablVecTrn == clssIdLst(clssIdIdx)) = 1;
end

% remove the mean vector from the data matrix
meanVec = mean(dataMatTrn, 2);
dataMatCen = bsxfun(@minus, dataMatTrn, meanVec);

% randomly initialize binary codes for all training instances
codeMat = (randn(paraStr.hashBitCnt, smplCntTrn) > 0) * 2 - 1;

% update the SDH model through iterations
clssReguMat = paraStr.reguCoeffClss * eye(paraStr.hashBitCnt);
projReguMat = paraStr.reguCoeffProj * eye(size(dataMat, 1));
for iterIdx = 1 : paraStr.iterCnt
  % display heart-beat message
  fprintf('[INFO] iterIdx = %3d / %3d\n', iterIdx, paraStr.iterCnt);
  
  % update the classification weighting matrix
  clssMat = (codeMat * codeMat' + clssReguMat) \ (codeMat * lablMatTrn');
  
  % update hashing functions and predicted binary codes
  projMat = (dataMatCen * dataMatCen' + projReguMat) \ (dataMatCen * codeMat');
  
  % update binary codes in a bit-wise style
  codeMat = zeros(paraStr.hashBitCnt, smplCntTrn);
  pMat = codeMat' * clssMat;
  qMat = clssMat * lablMatTrn + paraStr.pnltCoeffQuan * projMat' * dataMatCen;
  for iterIdxCode = 1 : paraStr.iterCntCode
    for hashBitIdx = 1 : paraStr.hashBitCnt
      zVec = codeMat(hashBitIdx, :)';
      vVec = clssMat(hashBitIdx, :)';
      pMat = pMat - zVec * vVec';
      zVec = (qMat(hashBitIdx, :)' - pMat * vVec > 0) * 2 - 1;
      pMat = pMat + zVec * vVec';
      codeMat(hashBitIdx, :) = zVec';
    end
  end
  
  % evaluate the objective function's value
  clssLssVal = norm(lablMatTrn - clssMat' * codeMat, 'fro');
  reguLssVal = paraStr.reguCoeffClss * norm(clssMat, 'fro');
  quanLssVal = ...
      paraStr.pnltCoeffQuan * norm(codeMat - projMat' * dataMatCen, 'fro');
  objFuncVal = clssLssVal + reguLssVal + quanLssVal;
  fprintf('[INFO] clssLssVal = %.4e\n', clssLssVal);
  fprintf('[INFO] reguLssVal = %.4e\n', reguLssVal);
  fprintf('[INFO] quanLssVal = %.4e\n', quanLssVal);
  fprintf('[INFO] objFuncVal = %.4e\n', objFuncVal);
  
  % check for the early-break condition
  if iterIdx ~= 1
    projMatDiff = projMat - projMatPrev;
    updtRat = norm(projMatDiff, 'fro') / norm(projMat, 'fro');
    fprintf('[INFO] update ratio: %.4f%%\n', updtRat * 100);
    if updtRat < paraStr.optTlrtLmt
      fprintf('[INFO] early break at %d-th iteration\n', iterIdx);
      break;
    end
  end
  projMatPrev = projMat;
end

% create the hashing function handler
param.meanVec = meanVec;
param.projMat = projMat';
model.hashFunc = @(dataMat)(HashFuncImpl_Std(dataMat, param));

end
