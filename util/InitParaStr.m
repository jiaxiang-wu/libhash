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
paraStr.trnWithLrnSet = true; % train with the learning subset

% hashing model evaluation
paraStr.smplCntQry = 1000; % # of query samples to be evaluated
paraStr.evaPrtl = 'HammRank'; % evaluation protocol: 'HammRank' / 'HashLkup'
paraStr.linkCntPerQry = [100, 1000, 10000]; % # of GT-links per query
paraStr.evaPosLst = 10 .^ (0 : 4); % evaluation positions
%paraStr.evaPosLst = 2 .^ (0 : 15); % evaluation positions
paraStr.hashLkupRad = 2; % hashing look-up's radius
paraStr.smplCntRtrv = max(paraStr.evaPosLst); % # of retrieved samples

end
