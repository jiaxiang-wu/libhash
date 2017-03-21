function smplIdxLst = GnrtMiniBatc(smplCnt, batcSiz)
% INTRO
%   generate sample indexes for mini-batch partition
% INPUT
%   smplCnt: scalar (number of samples in total)
%   batcSiz: scalar (number of samples in a mini-batch)
% OUTPUT
%   smplIdxLst: L x 1 (list of sample indexes; cell array)

smplIdxs = randperm(smplCnt);
batcCnt = floor(smplCnt / batcSiz);
smplIdxLst = cell(batcCnt, 1);
for batcIdx = 1 : batcCnt
  smplIdxLst{batcIdx} = smplIdxs((1 : batcSiz) + (batcIdx - 1) * batcSiz);
end

end
