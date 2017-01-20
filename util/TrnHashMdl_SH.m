function model = TrnHashMdl_SH(dataMat, paraStr)
% INTRO
%   train a SH hashing model
% INPUT
%   dataMat: D x N (data matrix)
%   paraStr: struct (hyper-parameters)
% OUTPUT
%   model: struct (hashing model)

% display the greeting message
fprintf('[INFO] entering TrnHashMdl_SH()\n');

% add path for all files under ./extern/spectral_hashing/util
addpath(genpath('./extern/spectral_hashing'));

% learn parameters of spectral hashing
param.nbits = paraStr.hashBitCnt;
param = trainSH(double(dataMat'), param);

% create the hashing function handler
model.hashFunc = @(dataMat)(HashFuncImpl(dataMat', param)');

end

function codeMat = HashFuncImpl(dataMat, param)
% INTRO
%   calculate binary codes with pre-trained SH parameters
% INPUT
%   dataMat: N x D (data matrix)
%   param: struct (pre-trained SH parameters)
% OUTPUT
%   codeMat: N x R (binary code matrix)

% project the data matrix via PCA
dataMat = bsxfun(@minus, dataMat * param.pc, param.mn);
omegMat = bsxfun(@times, param.modes, pi ./ (param.mx - param.mn));

% calculate the binary code matrix
smplCnt = size(dataMat, 1);
codeMat = zeros(smplCnt, param.nbits);
for bitIdx = 1 : param.nbits
  ys = sin(bsxfun(@times, dataMat, omegMat(bitIdx, :)) + pi / 2);
  yi = prod(ys, 2);
  codeMat(:, bitIdx) = (yi > 0) * 2 - 1;
end

end
