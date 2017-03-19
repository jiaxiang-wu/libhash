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

% configure hyper-parameters for the training process
paraStr.lrnMthd = 'GF'; % LP (Lift Projection) / GF (Gradient Flow)
paraStr.iterCnt = 25; % # of iterations (LP only)

end
