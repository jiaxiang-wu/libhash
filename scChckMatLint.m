close all; clearvars; clc;

% specify directories to be checked
kChkDirPathLst = [...
    {'./'}, ...
    {'./util/'}];

% check for warnings and errors in the *.m file
for chkDirPath = kChkDirPathLst
  fileStrLst = dir([chkDirPath{1}, '*.m']);
  for fileIdx = 1 : numel(fileStrLst)
    filePath = [chkDirPath{1}, fileStrLst(fileIdx).name];
    fprintf('[INFO] checking %s\n', filePath);
    checkcode(filePath);
  end
end
