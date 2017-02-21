function model = TrnHashMdl_ITQ(featMat, paraStr)
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
param.meanVec = mean(featMat, 2);
smplIdxsCovr = sort(randperm(smplCnt, paraStr.smplCntCovr));
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
    projMatPri * bsxfun(@minus, single(featMat(:, smplIdxs)), param.meanVec);
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
param.projMat = projMatSec * projMatPri;

% create the hashing function handler
model.hashFunc = @(featMat)(HashFuncImpl(featMat, param));

end

function codeMat = HashFuncImpl(featMat, param)
% INTRO
%   calculate binary codes with pre-trained LSH parameters
% INPUT
%   featMat: D x N (feature matrix)
%   param: struct (pre-trained LSH parameters)
% OUTPUT
%   codeMat: R x N (binary code matrix)

% obtain basic variables
hashBitCnt = size(param.projMat, 1);
smplCnt = size(featMat, 2);

% compute the binary code matrix in a mini-batch manner
batcSiz = 100000;
batcCnt = ceil(smplCnt / batcSiz);
codeMat = zeros(hashBitCnt, smplCnt, 'uint8');
for batcIdx = 1 : batcCnt
  smplIdxBeg = (batcIdx - 1) * batcSiz + 1;
  smplIdxEnd = min(batcIdx * batcSiz, smplCnt);
  smplIdxs = (smplIdxBeg : smplIdxEnd);
  codeMat(:, smplIdxs) = param.projMat ...
    * bsxfun(@minus, single(featMat(:, smplIdxs)), param.meanVec) > 0;
end

end
