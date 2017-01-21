function model = TrnHashMdl_AGH(dataMat, paraStr)
% INTRO
%   train a hashing model of AGH
% INPUT
%   dataMat: D x N (data matrix)
%   paraStr: struct (hyper-parameters)
% OUTPUT
%   model: struct (hashing model)

% display the greeting message
fprintf('[INFO] entering TrnHashMdl_AGH()\n');

% add path for all files under ./extern/AGH
addpath(genpath('./extern/AGH'));

% use k-means clustering to determine anchor points
clstOpts.ctrdCnt = paraStr.anchCnt;
clstOpts.iterCnt = 20;
clstOpts.ctrdLst = [];
clstOpts.initMthd = 'rnd';
clstOpts.enblVrbs = true;
[param.anchMat, ~] = KMeansClst(dataMat, clstOpts);

% call <OneLayerAGH_Train>/<TwoLayerAGH_Train> to obtain AGH parameters
r = paraStr.hashBitCnt;
param.s = paraStr.anchCntAfnt;
sigma = paraStr.rbfSigma;
if paraStr.useOneLevel
  [~, param.W, param.sigma] = ...
      OneLayerAGH_Train(dataMat', param.anchMat', r, param.s, sigma);
else
  [~, param.W, param.thres, param.sigma] = ...
      TwoLayerAGH_Train(dataMat', param.anchMat', r, param.s, sigma);
end

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

% call <OneLayerAGH_Test>/<TwoLayerAGH_Test> to calculate binary codes
if ~isfield(param, 'thres')
  codeMat = OneLayerAGH_Test(...
      dataMat', param.anchMat', param.W, param.s, param.sigma);
else
  codeMat = TwoLayerAGH_Test(...
      dataMat', param.anchMat', param.W, param.thres, param.s, param.sigma);
end
codeMat = (codeMat' > 0) * 2 - 1;

end
