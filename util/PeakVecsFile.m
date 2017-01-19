function [rowCnt, colCnt, typStr] = PeakVecsFile(filePath)
% INTRO
%   take a peak into the *vecs file, and return its data size
% INPUT
%   filePath: string (file path)
% OUTPUT
%   dataMat: D x N (data matrix)

% determine the value length
if ~isempty(strfind(filePath, 'bvecs'))
  valLen = 1;
  typStr = 'uint8';
elseif ~isempty(strfind(filePath, 'ivecs'))
  valLen = 4;
  typStr = 'uint32';
elseif ~isempty(strfind(filePath, 'fvecs'))
  valLen = 4;
  typStr = 'single';
end

% open file
inFile = fopen(filePath, 'rb');

% obtain number of vectors/dimensions
rowCnt = fread(inFile, 1, 'uint32');
colLen = 4 + valLen * rowCnt;
fseek(inFile, 0, 'eof');
byteCnt = ftell(inFile);
colCnt = byteCnt / colLen;

% close file
fclose(inFile);

end
