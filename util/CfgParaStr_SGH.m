function paraStr = CfgParaStr_SGH()
% INTRO
%   configure hyper-parameters for SGH (Scalable Graph Hashing)
% INPUT
%   none
% OUTPUT
%   paraStr: struct (hyper-parameters)

% initialize <paraStr> with shared hyper-parameters
paraStr = InitParaStr();

% configure basic parameters
paraStr.mthdName = 'SGH'; % method name
paraStr.trnFuncHndl = @TrnHashMdl_SGH; % training function

% configure hyper-parameters for the training process
paraStr.rbfAnchCnt = 300; % # of anchor points in computing the RBF kernel

end
