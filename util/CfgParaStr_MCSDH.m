function paraStr = CfgParaStr_MCSDH()
% INTRO
%   configure hyper-parameters for MCSDH (Multi-cut Supervised Discrete Hashing)
% INPUT
%   none
% OUTPUT
%   paraStr: struct (hyper-parameters)

% initialized <paraStr> with shared hyper-parameters
paraStr = InitParaStr();

% configure basic parameters
paraStr.mthdName = 'MCSDH'; % method name
paraStr.trnFuncHndl = @TrnHashMdl_MCSDH; % training function

% configure hyper-parameters for the training process
paraStr.trnWithLablVec = true; % train with the label vector
paraStr.iterCnt = 25; % # of iterations
paraStr.optTlrtLmt = 1e-4; % minimal allowed improvement to continue iterations
paraStr.instCntTrn = inf; % # of training points
paraStr.instCntAnc = 1000; % # of anchor points
paraStr.reguCoeffClss = 1e+0; % regularizer coefficient of classification
paraStr.reguCoeffProj = 1e-4; % regularizer coefficient of hash projection
paraStr.pnltCoeffQuan = 1e-5; % penalty coefficient of quantization error
paraStr.iterCntCode = 3; % # of iterations to update the binary codes
paraStr.krnlFuncType = 'linear'; % kernel function type: 'linear' / 'rbf'
paraStr.rbfKnrlWidtMul = 0.50; % multiplier of the RBF kernel's bandwidth
paraStr.codeInitMthd = 'proj'; % binary codes' init. method: 'rand' / 'proj'
paraStr.projInitScal = 1e-0; % projection matrix's init. numerical scale
paraStr.lbfgsIterCnt = 50; % # of L-BFGS iterations
paraStr.actvFuncType = 'sigm'; % activation function's type: 'sigm' / 'relu'

end
