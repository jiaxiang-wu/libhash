function [dataMatLrn, dataMatDtb, dataMatQry, dataMatLnk] = LoadDataSet(paraStr)
% INTRO
%   load the data set
% INPUT
%   paraStr: struct (hyper-parameters)
% OUTPUT
%   dataMatLrn: D x N_L (learning subset)
%   dataMatDtb: D x N_D (database subset)
%   dataMatQry: D x N_Q (query subset)
%   dataMatLnk: K x N_Q (ground-truth matches)

% display the greeting message
fprintf('[INFO] loading data set: %s\n', paraStr.dataSetName);

% parse file paths under the data directory
filePathLstLrn = [];
filePathLstDtb = [];
fileStrLst = dir([paraStr.dataDirPath, '/*vecs*']);
for fileIdx = 1 : numel(fileStrLst)
  filePath = [paraStr.dataDirPath, '/', fileStrLst(fileIdx).name];
  if ~isempty(strfind(filePath, 'learn'))
    filePathLstLrn = [filePathLstLrn; {filePath}];
  elseif ~isempty(strfind(filePath, 'base'))
    filePathLstDtb = [filePathLstDtb; {filePath}];
  elseif ~isempty(strfind(filePath, 'query'))
    filePathQry = filePath;
  elseif ~isempty(strfind(filePath, 'groundtruth'))
    filePathLnk = filePath;
  end
end
sort(filePathLstLrn);
sort(filePathLstDtb);

% load the learning subset
dataMatLrn = LoadVecsFiles(filePathLstLrn);

% load the database subset
dataMatDtb = LoadVecsFiles(filePathLstDtb);

% load query samples and their ground-truth matches
dataMatQry = LoadVecsFile(filePathQry);
dataMatLnk = LoadVecsFile(filePathLnk);

% remove unused query samples and their ground-truth matches
if paraStr.smplCntQry < size(dataMatQry, 2)
  dataMatQry = dataMatQry(:, 1 : paraStr.smplCntQry);
  dataMatLnk = dataMatLnk(1 : paraStr.linkCntPerQry, 1 : paraStr.smplCntQry);
end

end
