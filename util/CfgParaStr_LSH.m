function paraStr = CfgParaStr_LSH()
% INTRO
%   configure hyper-parameters for LSH (Locality Sensitive Hashing)
% INPUT
%   none
% OUTPUT
%   paraStr: struct (hyper-parameters)

% initialize <paraStr> with shared hyper-parameters
paraStr = InitParaStr();

% configure basic parameters
paraStr.mthdName = 'LSH'; % method name
paraStr.trnFuncHndl = @TrnHashMdl_LSH; % training function

% configure hyper-parameters for the training process

end
