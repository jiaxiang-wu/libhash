function model = TrnHashMdl_LSH(featMat, paraStr, ~)
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
meanVec = mean(featMat, 2);

% generate hashing functions with the normal distribution
featCnt = size(featMat, 1);
projMat = randn(paraStr.hashBitCnt, featCnt);

% create the hashing function handler
param.meanVec = meanVec;
param.projMat = projMat;
model.hashFunc = @(featMat)(HashFuncImpl_Std(featMat, param));

end
