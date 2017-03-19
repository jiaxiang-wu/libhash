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

% configure hyper-parameters for the training process
paraStr.iterCnt = 25; % # of iterations
paraStr.smplCntCovr = 100000; % # of samples to estimate the covariance matrix

end
