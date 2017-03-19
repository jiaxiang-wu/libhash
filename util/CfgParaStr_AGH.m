function paraStr = CfgParaStr_AGH()
% INTRO
%   configure hyper-parameters for AGH (Anchor Graph Hashing)
% INPUT
%   none
% OUTPUT
%   paraStr: struct (hyper-parameters)

% initialize <paraStr> with shared hyper-parameters
paraStr = InitParaStr();

% configure basic parameters
paraStr.mthdName = 'AGH'; % method name
paraStr.trnFuncHndl = @TrnHashMdl_AGH; % training function

% configure hyper-parameters for the training process
paraStr.anchCnt = 500; % # of anchor points (original: 300)
paraStr.anchCntAfnt = 50; % # of nearest anchor points (original: 2 ~ 30)
paraStr.rbfSigma = 0; % Gaussian RBF kernel's width parameter (0: auto)
paraStr.useOneLevel = true; % use the one level version of AGH

end
