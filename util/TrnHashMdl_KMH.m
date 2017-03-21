function model = TrnHashMdl_KMH(dataMat, paraStr, ~)
% INTRO
%   train a hashing model of KMH
% INPUT
%   dataMat: D x N (data matrix)
%   paraStr: struct (hyper-parameters)
% OUTPUT
%   model: struct (hashing model)

% display the greeting message
fprintf('[INFO] entering TrnHashMdl_KMH()\n');

% add path for all files under ./extern/KMH
addpath(genpath('./extern/KMH'));

% choose samples to constitute the training subset
smplCnt = size(dataMat, 2);
if smplCnt <= paraStr.smplCntTrn
  smplIdxsTrn = (1 : smplCnt);
else
  smplIdxsTrn = sort(randperm(smplCnt, paraStr.smplCntTrn));
end

% call <trainKMH> to obtain KMH parameters
assert(mod(paraStr.hashBitCnt, paraStr.sSpcDim) == 0);
param.sSpcDim = paraStr.sSpcDim;
param.sSpcCnt = paraStr.hashBitCnt / paraStr.sSpcDim;
assert(mod(size(dataMat, 1), param.sSpcCnt) == 0);
[param.ctrdLst, param.rotaMat, param.meanVec] = ...
    trainKMH(double(dataMat(:, smplIdxsTrn)'), ...
    param.sSpcCnt, param.sSpcDim, paraStr.iterCnt, paraStr.lambda);

% create the hashing function handler
model.hashFunc = @(dataMat)(HashFuncImpl(dataMat, param));

end

function codeMat = HashFuncImpl(dataMat, param)
% INTRO
%   calculate binary codes with pre-trained KMH parameters
% INPUT
%   dataMat: D x N (data matrix)
%   param: struct (pre-trained KMH parameters)
% OUTPUT
%   codeMat: R x N (binary code matrix)

% NOTE: <encode_KMH> returns the compressed hashing code, and cannot be
% directly used. Below the extracted code from the <encode_KMH> function,
% with the hashing code compression part removed.

% remove the mean vector, and then apply the rotation matrix
dataMatRota = project(dataMat', param.rotaMat, param.meanVec);

% generate a look-up table for the binary code
lkupTbl = generate_lut(param.sSpcDim);

% compute the binary code matrix
smplCnt = size(dataMatRota, 1);
featCnt = size(dataMatRota, 2);
featCntPerSSpc = featCnt / param.sSpcCnt;
codeMat = zeros(param.sSpcDim * param.sSpcCnt, smplCnt, 'uint8');
for sSpcIdx = 1 : param.sSpcCnt
  featIdxs = (1 : featCntPerSSpc) + featCntPerSSpc * (sSpcIdx - 1);
  codeIdxs = (1 : param.sSpcDim) + param.sSpcDim * (sSpcIdx - 1);
  distMat = sqdist(dataMatRota(:, featIdxs)', param.ctrdLst{sSpcIdx}');
  [~, ctrdIdxs] = min(distMat, [], 2);
  codeMat(codeIdxs, :) = lkupTbl(ctrdIdxs, :)';
end

end
