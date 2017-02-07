function model = TrnHashMdl_IMH(dataMat, paraStr)
% INTRO
%   train a hashing model of IMH
% INPUT
%   dataMat: D x N (data matrix)
%   paraStr: struct (hyper-parameters)
% OUTPUT
%   model: struct (hashing model)

% display the greeting message
fprintf('[INFO] entering TrnHashMdl_IMH()\n');

% add path for all files under ./extern/IMH
addpath(genpath('./extern/IMH'));

% validate hyper-parameters
assert(ismember(paraStr.lrnMthd, [{'LE'}, {'tSNE'}]));

% data normalization & anchor point selection
dataMat = normalize(dataMat'); % transposed
[~, anchMat] = litekmeans(dataMat, paraStr.anchCnt, 'MaxIter', paraStr.iterCnt);

% call <InducH>/<tSNEH> to obtain IMH parameters
options = InitOpt(['IMH-', paraStr.lrnMthd]);
options.nbits = paraStr.hashBitCnt;
options.maxbits = paraStr.hashBitCnt;
switch paraStr.lrnMthd
  case 'LE'
    [param.embed, ~, param.sigma] = InducH(anchMat, dataMat, options);
  case 'tSNE'
    param.embed = tSNEH(anchMat, options);
    [~, ~, param.sigma] = get_Z(dataMat, anchMat, options.s, options.sigma);
end
param.anchMat = anchMat;
param.options = options;

% create the hashing function handler
model.hashFunc = @(dataMat)(HashFuncImpl(dataMat, param));

end

function codeMat = HashFuncImpl(dataMat, param)
% INTRO
%   calculate binary codes with pre-trained IMH parameters
% INPUT
%   dataMat: D x N (data matrix)
%   param: struct (pre-trained IMH parameters)
% OUTPUT
%   codeMat: R x N (binary code matrix)

% compute the binary code matrix
dataMat = normalize(dataMat'); % transposed
zetaMat = get_Z(dataMat, param.anchMat, param.options.s, param.sigma);
codeMat = (zetaMat * param.embed > 0)' * 2 - 1;

end
