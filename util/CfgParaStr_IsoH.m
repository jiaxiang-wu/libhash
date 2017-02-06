function paraStr = CfgParaStr_IsoH()
% INTRO
%   configure hyper-parameters for IsoH (Isotropic Hashing)
% INPUT
%   none
% OUTPUT
%   paraStr: struct (hyper-parameters)

% initialize <paraStr> with shared hyper-parameters
paraStr = InitParaStr();

% configure basic parameters
paraStr.mthdName = 'IsoH'; % method name
paraStr.trnFuncHndl = @TrnHashMdl_IsoH; % training function
paraStr.logFilePath = sprintf('%s/%s.%s.log', ...
    paraStr.logDirPath, paraStr.mthdName, paraStr.dataSetName);
paraStr.rltFilePath = sprintf('%s/%s.%s.mat', ...
    paraStr.rltDirPath, paraStr.mthdName, paraStr.dataSetName);

% configure hyper-parameters for the training process
paraStr.lrnMthd = 'LP'; % LP (Lift Projection) / GF (Gradient Flow)
paraStr.iterCnt = 25; % # of iterations (LP only)

end
