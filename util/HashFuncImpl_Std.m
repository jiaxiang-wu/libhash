function codeMat = HashFuncImpl_Std(featMat, param)
% INTRO
%   standard implementation of hashing functions
%   1) remove the mean vector
%   2) multiply by the projection matrix
% INPUT
%   featMat: D x N (feature matrix)
%   param: struct (hashing function's parameters)
% OUTPUT
%   codeMat: R x N (binary code matrix)

% specify the number of samples per mini-batch
kBatcSiz = 100000;

% obtain basic variables
hashBitCnt = size(param.projMat, 1);
smplCnt = size(featMat, 2);

% compute the binary code matrix in a mini-batch manner
batcCnt = ceil(smplCnt / kBatcSiz);
codeMat = zeros(hashBitCnt, smplCnt, 'uint8');
for batcIdx = 1 : batcCnt
  smplIdxBeg = (batcIdx - 1) * kBatcSiz + 1;
  smplIdxEnd = min(batcIdx * kBatcSiz, smplCnt);
  smplIdxs = (smplIdxBeg : smplIdxEnd);
  codeMat(:, smplIdxs) = param.projMat ...
    * bsxfun(@minus, single(featMat(:, smplIdxs)), param.meanVec) > 0;
end

end
