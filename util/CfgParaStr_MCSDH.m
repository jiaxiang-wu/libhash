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

% configure hyper-parameters for feature pre-processing
paraStr.kernAnchCnt = 1000; % # of anchor points in feature kernelization
paraStr.kernBandWid = 0.4; % RBF kernel function's band-width

% configure hyper-parameters for the training process
paraStr.trnWithLablVec = true; % train with the label vector
paraStr.useKernFeat = false; % use kernelized feature or not
paraStr.iterCnt = 25; % # of iterations
paraStr.optTlrtLmt = 1e-4; % minimal allowed improvement to continue iterations
paraStr.smplCntTrn = inf; % # of training points
paraStr.reguCoeffClss = 1e+0; % regularizer coefficient of classification
paraStr.reguCoeffProj = 1e-4; % regularizer coefficient of hash projection
paraStr.pnltCoeffQuan = 1e-5; % penalty coefficient of quantization error
paraStr.iterCntCode = 3; % # of iterations to update the binary codes
paraStr.codeInitMthd = 'proj'; % binary codes' init. method: 'rand' / 'proj'
paraStr.projInitScal = 2e+0; % projection matrix's init. numerical scale
paraStr.lbfgsIterCnt = 50; % # of L-BFGS iterations
paraStr.actvFuncType = 'sigm'; % activation function's type: 'sigm' / 'relu'

end
