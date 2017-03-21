function model = TrnHashMdl_ITQ(featMat, paraStr, ~)
% INTRO
%   train a hashing model of ITQ
% INPUT
%   featMat: D x N (feature matrix)
%   paraStr: struct (hyper-parameters)
% OUTPUT
%   model: struct (hashing model)

% display the greeting message
fprintf('[INFO] entering TrnHashMdl_ITQ()\n');

% obtain basic variables
smplCnt = size(featMat, 2);

% calculate the mean feature vector and covariance matrix
meanVec = mean(featMat, 2);
smplIdxsCovr = sort(randperm(smplCnt, min(smplCnt, paraStr.smplCntCovr)));
covrMat = cov(single(featMat(:, smplIdxsCovr))');

% determine the initial projection matrix
[eigVecLst, ~] = eigs(double(covrMat), paraStr.hashBitCnt, 'la');
projMatPri = eigVecLst';

% apply the initial projection in a mini-batch manner
batcSiz = 100000;
batcCnt = ceil(smplCnt / batcSiz);
dataMatPrj = zeros(paraStr.hashBitCnt, smplCnt, 'single');
for batcIdx = 1 : batcCnt
  smplIdxBeg = (batcIdx - 1) * batcSiz + 1;
  smplIdxEnd = min(batcIdx * batcSiz, smplCnt);
  smplIdxs = (smplIdxBeg : smplIdxEnd);
  dataMatPrj(:, smplIdxs) = ...
    projMatPri * bsxfun(@minus, single(featMat(:, smplIdxs)), meanVec);
end

% run block coordinate descent to update <B> and <R>
projMatSec = orth(randn(paraStr.hashBitCnt));
for iterIdx = 1 : paraStr.iterCnt
  % display heart-beat message
  fprintf('[INFO] iterIdx = %3d / %3d: ', iterIdx, paraStr.iterCnt);

  % update the rotation matrix
  codeMat = (projMatSec * dataMatPrj > 0) * 2 - 1;
  [u, ~, v] = svd(dataMatPrj * codeMat', 'econ');
  projMatSec = v * u';

  % compute the residual error
  resdMat = codeMat - projMatSec * dataMatPrj;
  resdErr = mean(resdMat(:) .^ 2);
  fprintf('residual error (AVE) = %.4e\n', resdErr);
end

% create the hashing function handler
param.meanVec = meanVec;
param.projMat = projMatSec * projMatPri;
model.hashFunc = @(featMat)(HashFuncImpl_Std(featMat, param));

end
