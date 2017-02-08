function model = TrnHashMdl_SpH(dataMat, paraStr)
% INTRO
%   train a hashing model of SpH
% INPUT
%   dataMat: D x N (data matrix)
%   paraStr: struct (hyper-parameters)
% OUTPUT
%   model: struct (hashing model)

% display the greeting message
fprintf('[INFO] entering TrnHashMdl_SpH()\n');

% add path for all files under ./extern/SpH
addpath(genpath('./extern/SpH'));

% call <SphericalHashing> to obtain SpH parameters
smplCnt = size(dataMat, 2);
smplIdxLst = randsample(smplCnt, paraStr.smplCntTrn);
[param.cntrMat, param.radsVec] = ...
    SphericalHashing(dataMat(:, smplIdxLst)', paraStr.hashBitCnt);

% create the hashing function handler
model.hashFunc = @(dataMat)(HashFuncImpl(dataMat, param));

end

function codeMat = HashFuncImpl(dataMat, param)
% INTRO
%   calculate binary codes with pre-trained SpH parameters
% INPUT
%   dataMat: D x N (data matrix)
%   param: struct (pre-trained SpH parameters)
% OUTPUT
%   codeMat: R x N (binary code matrix)

% calculate binary codes
distMat = CalcDistMat(param.cntrMat', dataMat, 'ecld');
codeMat = uint8(bsxfun(@lt, distMat, param.radsVec));

end
