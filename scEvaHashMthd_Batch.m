close all; clearvars; clc;

% initialize constant variables
kMthdName = 'IMH';
kEvalFPath = './scEvaHashMthd.m';
kParaFPath = './util/InitParaStr.m';

% backup files
copyfile(kEvalFPath, [kEvalFPath, '.bak']);
copyfile(kParaFPath, [kParaFPath, '.bak']);

% evaluate under various parameter combinations
system('rm -f ./batch.log && touch ./batch.log');
system(sprintf('sed -i ''s/close\\ all/%%close\\ all/g'' %s', kEvalFPath));
system(sprintf('sed -i "/kMthdName/s/''[A-Za-z]\\+''/''%s''/g" %s', kMthdName, kEvalFPath));
for hashBitCnt = [16, 32, 48, 64]
  system(sprintf('sed -i ''/hashBitCnt/s/[0-9]\\+/%d/g'' %s', hashBitCnt, kParaFPath));
  pause(1); % wait for the <sed> command to take effect
  try
    scEvaHashMthd;
    system(sprintf('grep meanAP ./log/%s.*.log >> ./batch.log', kMthdName));
  catch
    fprintf('[ERROR] evaluation failed: %d / %d\n', hashBitCnt, linkCntPerQry);
    system('echo "meanAP: n/a" >> ./batch.log');
  end
end
system('cat ./batch.log');

% restore files
movefile([kEvalFPath, '.bak'], kEvalFPath);
movefile([kParaFPath, '.bak'], kParaFPath);
