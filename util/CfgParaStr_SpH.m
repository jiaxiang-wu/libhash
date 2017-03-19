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

% configure hyper-parameters for the training process
paraStr.smplCntTrn = 20000; % # of samples in the training subset

end
