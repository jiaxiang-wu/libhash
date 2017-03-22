function model = TrnHashMdl_SDH(featMat, paraStr, extrInfo)
% INTRO
%   train a hashing model of SGH
% INPUT
%   featMat: D x N (feature matrix)
%   paraStr: struct (hyper-parameters)
%   extrInfo: 1 x 2 (cell array of label vector and affinity matrix)
% OUTPUT
%   model: struct (hashing model)

% display the greeting message
fprintf('[INFO] entering TrnHashMdl_SDH()\n');

% perform feature normalization and kernelization
smplCnt = size(featMat, 2);
normFunc = @(x)(bsxfun(@times, x, 1 ./ sqrt(sum(x .^ 2, 1))));
featMat = normFunc(featMat);
anchMat = featMat(:, randperm(smplCnt, paraStr.kernAnchCnt));
kernFunc = @(x)(...
  exp(-CalcDistMat(anchMat, x, 'ecld') .^ 2 / (2 * paraStr.kernBandWid ^ 2)));
featMat = kernFunc(featMat);
preProcFunc = @(x)(kernFunc(normFunc(x)));

% randomly select a subset of instances for training
smplCntTrn = min(smplCnt, paraStr.smplCntTrn);
smplIdxLstTrn = sort(randperm(smplCnt, smplCntTrn));
featMatTrn = featMat(:, smplIdxLstTrn);
lablVecTrn = extrInfo{1}(smplIdxLstTrn);

% expand the label vector into a 0/1 indicator matrix
clssIdLst = unique(lablVecTrn);
clssIdCnt = numel(clssIdLst);
lablMatTrn = zeros(clssIdCnt, smplCntTrn);
for clssIdIdx = 1 : clssIdCnt
  lablMatTrn(clssIdIdx, lablVecTrn == clssIdLst(clssIdIdx)) = 1;
end

% remove the mean vector from the data matrix
meanVec = mean(featMatTrn, 2);
featMatCen = bsxfun(@minus, featMatTrn, meanVec);

% randomly initialize binary codes for all training instances
codeMat = (randn(paraStr.hashBitCnt, smplCntTrn) > 0) * 2 - 1;

% update the SDH model through iterations
clssReguMat = paraStr.reguCoeffClss * eye(paraStr.hashBitCnt);
projReguMat = paraStr.reguCoeffProj * eye(size(featMat, 1));
for iterIdx = 1 : paraStr.iterCnt
  % display heart-beat message
  fprintf('[INFO] iterIdx = %3d / %3d\n', iterIdx, paraStr.iterCnt);
  
  % update the classification weighting matrix
  clssMat = (codeMat * codeMat' + clssReguMat) \ (codeMat * lablMatTrn');
  
  % update hashing functions and predicted binary codes
  projMat = (featMatCen * featMatCen' + projReguMat) \ (featMatCen * codeMat');
  
  % update binary codes in a bit-wise style
  codeMat = zeros(paraStr.hashBitCnt, smplCntTrn);
  pMat = codeMat' * clssMat;
  qMat = clssMat * lablMatTrn + paraStr.pnltCoeffQuan * projMat' * featMatCen;
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
      paraStr.pnltCoeffQuan * norm(codeMat - projMat' * featMatCen, 'fro');
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
model.hashFunc = @(featMat)(HashFuncImpl_Std(preProcFunc(featMat), param));

end
