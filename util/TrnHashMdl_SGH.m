function model = TrnHashMdl_SGH(dataMat, paraStr, ~)
% INTRO
%   train a hashing model of SGH
% INPUT
%   dataMat: D x N (data matrix)
%   paraStr: struct (hyper-parameters)
% OUTPUT
%   model: struct (hashing model)

% display the greeting message
fprintf('[INFO] entering TrnHashMdl_SGH()\n');

% add path for all files under ./extern/SGH
addpath(genpath('./extern/SGH'));

% pre-processing (scaling and zero-mean normalization)
meanVec = mean(dataMat, 2);
dataMat = bsxfun(@minus, dataMat, meanVec);
normAve = mean(sqrt(sum(dataMat .^ 2, 1)));
dataMat = dataMat / normAve;

% choose samples as anchor points in computing the RBF kernel
smplCnt = size(dataMat, 2);
assert(paraStr.rbfAnchCnt <= smplCnt);
smplIdxsAnch = sort(randperm(smplCnt, paraStr.rbfAnchCnt));
anchMat = dataMat(:, smplIdxsAnch);

% call <trainSGH> to obtain SGH parameters
[projMat, ~, param] = trainSGH(double(dataMat'), anchMat', paraStr.hashBitCnt);
param.meanVec = meanVec;
param.normAve = normAve;
param.anchMat = anchMat;
param.projMat = projMat;

% create the hashing function handler
model.hashFunc = @(dataMat)(HashFuncImpl(dataMat, param));

end

function codeMat = HashFuncImpl(dataMat, param)
% INTRO
%   calculate binary codes with pre-trained SGH parameters
% INPUT
%   dataMat: D x N (data matrix)
%   param: struct (pre-trained SGH parameters)
% OUTPUT
%   codeMat: R x N (binary code matrix)

% compute the RBF kernel
dataMat = bsxfun(@minus, dataMat, param.meanVec) / param.normAve;
distMat = CalcDistMat(param.anchMat, dataMat, 'ecld');
krnlMat = bsxfun(@minus, exp(-distMat .^ 2 / param.delta / 2), param.bias');

% compute the binary code matrix
codeMat = uint8(param.projMat' * krnlMat > 0);

end
