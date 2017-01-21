function paraStr = InitParaStr()
% INTRO
%   initialize shared hyper-parameters for all hashing methods
% INPUT
%   none
% OUTPUT
%   paraStr: struct (hyper-parameters)

% file paths
paraStr.dataSetName = 'SIFT1M';
paraStr.rootDirPath = '/data/jxwu/ANN.Search';
paraStr.dataDirPath = [paraStr.rootDirPath, '/', paraStr.dataSetName];
paraStr.logDirPath = './log';
paraStr.rltDirPath = './result';

% hashing model training
paraStr.hashBitCnt = 64; % # of hashing bits
paraStr.trnWithLrnSet = false; % use the learning subset for training

% hashing model evaluation
paraStr.smplCntQry = 1000; % # of query samples to be evaluated
paraStr.linkCntPerQry = 10000; % # of ground-truth links per query
paraStr.evaPosLst = 10 .^ (0 : 4); % evaluation positions
%paraStr.evaPosLst = 2 .^ (0 : 15); % evaluation positions
paraStr.smplCntRtrv = max(paraStr.evaPosLst); % # of retrieved samples
paraStr.reclOnly = false; % compute recall@T scores only (faster)

end
