function paraStr = CfgParaStr_SH()
% INTRO
%   configure hyper-parameters for SH (Spectral Hashing)
% INPUT
%   none
% OUTPUT
%   paraStr: struct (hyper-parameters)

% initialize <paraStr> with shared hyper-parameters
paraStr = InitParaStr();

% configure basic parameters
paraStr.mthdName = 'SH'; % method name
paraStr.trnFuncHndl = @TrnHashMdl_SH; % training function

% configure hyper-parameters for the training process

end
