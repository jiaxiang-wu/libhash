function model = TrnHashMdl_IsoH(dataMat, paraStr)
% INTRO
%   train a hashing model of IsoH
% INPUT
%   dataMat: D x N (data matrix)
%   paraStr: struct (hyper-parameters)
% OUTPUT
%   model: struct (hashing model)

% display the greeting message
fprintf('[INFO] entering TrnHashMdl_IsoH()\n');

% add path for all files under ./extern/AGH
addpath(genpath('./extern/IsoH'));

% calculate the mean feature vector and covariance matrix
meanVec = mean(dataMat, 2);
dataMatCen = bsxfun(@minus, dataMat, meanVec);
covrMat = dataMatCen * dataMatCen';

% perform PCA on the covariance matrix
[eigVecLst, eigValMat] = eigs(double(covrMat), paraStr.hashBitCnt, 'la');

% learn the orthogonal projection matrix
if strcmp(paraStr.lrnMthd, 'LP')
  projMat = LiftProjection(eigValMat, paraStr.iterCnt);
elseif strcmp(paraStr.lrnMthd, 'GF')
  projMat = GradientFlow(eigValMat);
else
  fprintf('[ERROR] invalid learning method: %s\n', paraStr.lrnMthd);
  return;
end

% create the hashing function handler
model.hashFunc = @(dataMat)(...
  (projMat * eigVecLst' * bsxfun(@minus, dataMat, meanVec) > 0) * 2 - 1);

end
