function model = TrnHashMdl_ITQ(dataMat, paraStr)
% INTRO
%   train an ITQ hashing model
% INPUT
%   dataMat: D x N (data matrix)
%   paraStr: struct (hyper-parameters)
% OUTPUT
%   model: struct (hashing model)

% display the greeting message
fprintf('[INFO] entering TrnHashMdl_ITQ()\n');

% calculate the mean feature vector and covariance matrix
meanVec = mean(dataMat, 2);
dataMatCen = bsxfun(@minus, dataMat, meanVec);
covrMat = dataMatCen * dataMatCen';

% obtain eigenvectors corresponding to the K largest eigenvalues
[eigVecLst, ~] = eigs(double(covrMat), paraStr.hashBitCnt, 'la');

% obtain the original hashing functions with random rotation
projMatPri = eigVecLst';
dataMatPrj = projMatPri * dataMatCen;

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
projMat = projMatSec * projMatPri;

% create the hashing function handler
model.hashFunc = @(dataMat)(...
    (projMat * bsxfun(@minus, dataMat, meanVec) > 0) * 2 - 1);

end
