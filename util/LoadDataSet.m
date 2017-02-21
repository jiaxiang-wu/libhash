function dtSet = LoadDataSet(paraStr)
% INTRO
%   load the data set
% INPUT
%   paraStr: struct (hyper-parameters)
% OUTPUT
%   dtSet: structure (data set, including feature matrices & GT-matches/labels)

% display the greeting message
fprintf('[INFO] loading data set: %s\n', paraStr.dataSetName);

% initialize the data set
dtSet = struct('featMatLrn', [], 'featMatDtb', [], ...
  'featMatQry', [], 'linkMat', [], 'lablVecDtb', [], 'lablVecQry', []);

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
  elseif ~isempty(strfind(filePath, 'label'))
    filePathLbl = filePath;
  end
end
sort(filePathLstLrn);
sort(filePathLstDtb);

% load the learning, database, and query subsets
if paraStr.trnWithLrnSet
  dtSet.featMatLrn = LoadVecsFiles(filePathLstLrn);
end
dtSet.featMatDtb = LoadVecsFiles(filePathLstDtb);
dtSet.featMatQry = LoadVecsFile(filePathQry);
smplCntQry = size(dtSet.featMatQry, 2);

% load ground-truth matches or category labels
if exist('filePathLnk', 'var')
  dtSet.linkMat = LoadVecsFile(filePathLnk);
elseif exist('filePathLbl', 'var')
  lablVec = LoadVecsFile(filePathLbl);
  dtSet.lablVecQry = lablVec(1 : smplCntQry);
  dtSet.lablVecDtb = lablVec(smplCntQry + 1 : end);
else
  fprintf('[ERROR] either GT-matches of labels must be provided\n');
end

% remove unused query samples, and their GT-matches (or labels)
if paraStr.smplCntQry < smplCntQry
  dtSet.featMatQry = dtSet.featMatQry(:, 1 : paraStr.smplCntQry);
  if exist('linkMat', 'var')
    linkCntPerQryMax = max(paraStr.linkCntPerQry);
    dtSet.linkMat = dtSet.linkMat(1 : linkCntPerQryMax, 1 : paraStr.smplCntQry);
  end
  if exist('lablVecQry', 'var')
    dtSet.lablVecQry = dtSet.lablVecQry(1 : paraStr.smplCntQry);
  end
end

end
