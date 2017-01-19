function dataMat = LoadVecsFiles(filePathLst)
% INTRO
%   load a data matrix from the combination of *vecs files
% INPUT
%   filePathLst: M x 1 (list of file paths)
% OUTPUT
%   dataMat: D x N (data matrix)

% count the overall number of rows and columns
fileCnt = numel(filePathLst);
rowCntLst = zeros(fileCnt, 1);
colCntLst = zeros(fileCnt, 1);
for fileIdx = 1 : fileCnt
  filePath = filePathLst{fileIdx};
  [rowCntLst(fileIdx), colCntLst(fileIdx), typStr] = PeakVecsFile(filePath);
end

% pre-allocate a data matrix
assert(max(rowCntLst) == min(rowCntLst));
rowCnt = rowCntLst(1);
colCnt = sum(colCntLst);
dataMat = zeros(rowCnt, colCnt, typStr);

% pre-allocate a data matrix, and then read files one-by-one
colIdxEnd = 0;
for fileIdx = 1 : fileCnt
  filePath = filePathLst{fileIdx};
  colIdxBeg = colIdxEnd + 1;
  colIdxEnd = colIdxEnd + colCntLst(fileIdx);
  dataMat(:, colIdxBeg : colIdxEnd) = LoadVecsFile(filePath);
end

end
