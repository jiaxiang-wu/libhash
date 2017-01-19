function SaveVecsFile(filePath, dataMat)
% INTRO
%   save the data matrix to a *vecs file
% INPUT
%   filePath: string (file path)
%   dataMat: D x N (data matrix)
% OUTPUT
%   none

% explicit data type conversion
if ~isempty(strfind(filePath, 'bvecs'))
  dataMat = uint8(dataMat);
elseif ~isempty(strfind(filePath, 'ivecs'))
  dataMat = uint32(dataMat);
elseif ~isempty(strfind(filePath, 'fvecs'))
  dataMat = single(dataMat);
end

% open file
outFile = fopen(filePath, 'w', 'ieee-le');

% obtain number of vectors/dimensions
[rowCnt, colCnt] = size(dataMat);

% load data matrix
for colIdx = 1 : colCnt
  fwrite(outFile, rowCnt, 'uint32');
  fwrite(outFile, dataMat(:, colIdx), class(dataMat));
end

% close file
fclose(outFile);

end
