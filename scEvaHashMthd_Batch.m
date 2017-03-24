close all; clearvars; clc;

% initialize constant variables
kMthdNameLst = [{'SDH'}, {'MCSDH'}, {'IPH'}];
kHashBitCntLst = [8, 16, 24, 32, 48, 64, 96, 128];
kEvalFPath = './scEvaHashMthd.m';
kParaFPath = './util/InitParaStr.m';

% backup files
copyfile(kEvalFPath, [kEvalFPath, '.bak']);
copyfile(kParaFPath, [kParaFPath, '.bak']);

% evaluate under various parameter combinations
system(sprintf('sed -i ''s/close\\ all/%%close\\ all/g'' %s', kEvalFPath));
for mthdName = kMthdNameLst
  for hashBitCnt = kHashBitCntLst
    % modify the main script and configuration files
    system(sprintf('sed -i "/kMthdName/s/''[A-Za-z]\\+''/''%s''/g" %s', ...
      mthdName{1}, kEvalFPath));
    system(sprintf('sed -i ''/hashBitCnt/s/[0-9]\\+/%d/g'' %s', ...
      hashBitCnt, kParaFPath));
    pause(1); % wait for the <sed> command to take effect
    
    % run the main script, and save a copy of the logging file
    try
      scEvaHashMthd;
      copyfile(paraStr.logFilePath, './tmp');
    catch
      fprintf('[ERROR] evaluation failed: %d\n', hashBitCnt);
    end
  end
end

% restore files
movefile([kEvalFPath, '.bak'], kEvalFPath);
movefile([kParaFPath, '.bak'], kParaFPath);
