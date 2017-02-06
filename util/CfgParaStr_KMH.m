function paraStr = CfgParaStr_KMH()
% INTRO
%   configure hyper-parameters for KMH (K-means Hashing)
% INPUT
%   none
% OUTPUT
%   paraStr: struct (hyper-parameters)

% initialize <paraStr> with shared hyper-parameters
paraStr = InitParaStr();

% configure basic parameters
paraStr.mthdName = 'KMH'; % method name
paraStr.trnFuncHndl = @TrnHashMdl_KMH; % training function
paraStr.logFilePath = sprintf('%s/%s.%s.log', ...
    paraStr.logDirPath, paraStr.mthdName, paraStr.dataSetName);
paraStr.rltFilePath = sprintf('%s/%s.%s.mat', ...
    paraStr.rltDirPath, paraStr.mthdName, paraStr.dataSetName);

% configure hyper-parameters for the training process
paraStr.iterCnt = 50; % # of iterations
paraStr.sSpcDim = 4; % length of each subspace's dimension
paraStr.lambda = 10; % trade-off controller: $\lambda$
paraStr.smplCntTrn = 100000; % # of training samples

end
