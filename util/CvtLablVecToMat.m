function lablMat = CvtLablVecToMat(lablVec)
% INTRO
%   convert the label vector to a 0/1 label matrix
% INPUT
%   lablVec: 1 x N (label vector)
% OUTPUT
%   lablMat: C x N (label matrix)

% convert the label vector to a 0/1 label matrix
smplCnt = numel(lablVec);
clssIdLst = unique(lablVec);
clssIdCnt = numel(clssIdLst);
lablMat = zeros(clssIdCnt, smplCnt);
for clssIdIdx = 1 : clssIdCnt
  lablMat(clssIdIdx, lablVec == clssIdLst(clssIdIdx)) = 1;
end

end
