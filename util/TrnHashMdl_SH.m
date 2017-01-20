function model = TrnHashMdl_SH(dataMat, paraStr)
% INTRO
%   train a hashing model of SH
% INPUT
%   dataMat: D x N (data matrix)
%   paraStr: struct (hyper-parameters)
% OUTPUT
%   model: struct (hashing model)

% display the greeting message
fprintf('[INFO] entering TrnHashMdl_SH()\n');

% add path for all files under ./extern/spectral_hashing/util
addpath(genpath('./extern/SH'));

% call <trainSH> to obtain SH parameters
param.nbits = paraStr.hashBitCnt;
param = trainSH(double(dataMat'), param);

% create the hashing function handler
model.hashFunc = @(dataMat)(HashFuncImpl(dataMat, param));

end

function codeMat = HashFuncImpl(dataMat, param)
% INTRO
%   calculate binary codes with pre-trained SH parameters
% INPUT
%   dataMat: D x N (data matrix)
%   param: struct (pre-trained SH parameters)
% OUTPUT
%   codeMat: R x N (binary code matrix)

% call <compressSH> to calculate binary codes
[~, codeMat] = compressSH(dataMat', param);
codeMat = (codeMat' > 0) * 2 - 1;

end
