function paraStr = CfgParaStr_ITQ()
% INTRO
%   configure hyper-parameters for ITQ (Iterative Quantization)
% INPUT
%   none
% OUTPUT
%   paraStr: struct (hyper-parameters)

% initialize <paraStr> with shared hyper-parameters
paraStr = InitParaStr();

% configure basic parameters
paraStr.mthdName = 'ITQ'; % method name
paraStr.trnFuncHndl = @TrnHashMdl_ITQ; % training function
paraStr.logFilePath = sprintf('%s/%s.%s.log', ...
    paraStr.logDirPath, paraStr.mthdName, paraStr.dataSetName);
paraStr.rltFilePath = sprintf('%s/%s.%s.mat', ...
    paraStr.rltDirPath, paraStr.mthdName, paraStr.dataSetName);

% configure hyper-parameters for the training process
paraStr.iterCnt = 25; % # of iterations

end
