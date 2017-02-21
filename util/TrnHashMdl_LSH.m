function model = TrnHashMdl_LSH(featMat, paraStr)
% INTRO
%   train a hashing model of LSH
% INPUT
%   featMat: D x N (feature matrix)
%   paraStr: struct (hyper-parameters)
% OUTPUT
%   model: struct (hashing model)

% display the greeting message
fprintf('[INFO] entering TrnHashMdl_LSH()\n');

% compute the mean feature vector
param.meanVec = mean(featMat, 2);

% generate hashing functions with the normal distribution
featCnt = size(featMat, 1);
param.projMat = randn(paraStr.hashBitCnt, featCnt);

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
