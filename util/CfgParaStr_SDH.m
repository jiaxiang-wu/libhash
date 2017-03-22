function paraStr = CfgParaStr_SDH()
% INTRO
%   configure hyper-parameters for SDH (Supervised Discrete Hashing)
% INPUT
%   none
% OUTPUT
%   paraStr: struct (hyper-parameters)

% initialize <paraStr> with shared hyper-parameters
paraStr = InitParaStr();

% configure basic parameters
paraStr.mthdName = 'SDH'; % method name
paraStr.trnFuncHndl = @TrnHashMdl_SDH; % training function

% configure hyper-parameters for the training process
paraStr.trnWithLablVec = true; % train with the label vector
paraStr.enblFeatNorm = true; % enable feature normalization
paraStr.iterCnt = 25; % # of iterations
paraStr.optTlrtLmt = 1e-4; % minimal allowed improvement to continue iterations
paraStr.smplCntTrn = inf; % # of training samples
paraStr.reguCoeffClss = 1e+0; % regularizer coefficient of classification
paraStr.reguCoeffProj = 1e-4; % regularizer coefficient of hash projection
paraStr.pnltCoeffQuan = 1e-5; % penalty coefficient of quantization error
paraStr.iterCntCode = 1; % # of iterations to update the binary codes

end
