function paraStr = CfgParaStr_IMH()
% INTRO
%   configure hyper-parameters for IMH (Inductive Manifold Hashing)
% INPUT
%   none
% OUTPUT
%   paraStr: struct (hyper-parameters)

% initialize <paraStr> with shared hyper-parameters
paraStr = InitParaStr();

% configure basic parameters
paraStr.mthdName = 'IMH'; % method name
paraStr.trnFuncHndl = @TrnHashMdl_IMH; % training function
paraStr.logFilePath = sprintf('%s/%s.%s.log', ...
    paraStr.logDirPath, paraStr.mthdName, paraStr.dataSetName);
paraStr.rltFilePath = sprintf('%s/%s.%s.mat', ...
    paraStr.rltDirPath, paraStr.mthdName, paraStr.dataSetName);

% configure hyper-parameters for the training process
paraStr.anchCnt = 1000; % # of anchor points
paraStr.iterCnt = 10; % # of k-means clustering iterations to select anchors
paraStr.lrnMthd = 'LE'; % LE (Laplacian Eigenmaps) / tSNE

end
