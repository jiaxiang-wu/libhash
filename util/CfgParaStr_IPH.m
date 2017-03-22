function paraStr = CfgParaStr_IPH()
% INTRO
%   configure hyper-parameters for IPH (Infinite Partition Hashing)
% INPUT
%   none
% OUTPUT
%   paraStr: struct (hyper-parameters)

% initialize <paraStr> with shared hyper-parameters
paraStr = InitParaStr();

% configure basic parameters
paraStr.mthdName = 'IPH'; % method name
paraStr.trnFuncHndl = @TrnHashMdl_IPH; % training function

% configure hyper-parameters for feature pre-processing
paraStr.kernAnchCnt = 1000; % # of anchor points in feature kernelization
paraStr.kernBandWid = 0.4; % RBF kernel function's band-width

% configure hyper-parameters for the training process
paraStr.trnWithLablVec = true; % train with the label vector
paraStr.useKernFeat = false; % use kernelized feature or not
paraStr.iterCnt = 25; % # of iterations
paraStr.optTlrtLmt = 1e-4; % minimal allowed improvement to continue iterations
paraStr.smplCntTrn = inf; % # of training points
paraStr.reguCoeffClss = 1e-1; % regularizer coefficient of classification
paraStr.pnltCoeffQuan = 3e-3; % penalty coefficient of quantization error
paraStr.iterCntCode = 3; % # of iterations to update the binary codes
paraStr.codeBlckLen = inf; % # of binary codes in block for joint optimization
paraStr.projInitScal = 2e+0; % projection matrix's init. numerical scale
paraStr.lbfgsIterCnt = 50; % # of L-BFGS iterations
paraStr.decyCoeffPart = 0.68; % decay coefficient of partitions

end
