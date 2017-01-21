function paraStr = CfgParaStr_SpH()
% INTRO
%   configure hyper-parameters for SpH (Spherical Hashing)
% INPUT
%   none
% OUTPUT
%   paraStr: struct (hyper-parameters)

% initialize <paraStr> with shared hyper-parameters
paraStr = InitParaStr();

% configure basic parameters
paraStr.mthdName = 'SpH'; % method name
paraStr.trnFuncHndl = @TrnHashMdl_SpH; % training function
paraStr.logFilePath = sprintf('%s/%s.%s.log', ...
    paraStr.logDirPath, paraStr.mthdName, paraStr.dataSetName);
paraStr.rltFilePath = sprintf('%s/%s.%s.mat', ...
    paraStr.rltDirPath, paraStr.mthdName, paraStr.dataSetName);

% configure hyper-parameters for the training process
paraStr.smplCntTrn = 20000; % # of samples in the training subset

end
