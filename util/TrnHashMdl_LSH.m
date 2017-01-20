function model = TrnHashMdl_LSH(dataMat, paraStr)
% INTRO
%   train a LSH hashing model
% INPUT
%   dataMat: D x N (data matrix)
%   paraStr: struct (hyper-parameters)
% OUTPUT
%   model: struct (hashing model)

% display the greeting message
fprintf('[INFO] entering TrnHashMdl_LSH()\n');

% compute the mean feature vector
meanVec = mean(dataMat, 2);

% generate hashing functions with the normal distribution
featCnt = size(dataMat, 1);
projMat = randn(paraStr.hashBitCnt, featCnt);

% create the hashing function handler
model.hashFunc = @(dataMat)(...
    (projMat * bsxfun(@minus, dataMat, meanVec) > 0) * 2 - 1);

end
