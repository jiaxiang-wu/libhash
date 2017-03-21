function model = TrnHashMdl_IPH(dataMat, paraStr, extrInfo)
% INTRO
%   train a hashing model of IPH
% INPUT
%   dataMat: D x N (data matrix)
%   paraStr: struct (hyper-parameters)
%   extrInfo: 1 x 2 (cell array of label vector and affinity matrix)
% OUTPUT
%   model: struct (hashing model)

% display the greeting message
fprintf('[INFO] entering TrnHashMdl_IPH()\n');

% add path for gradient-based optimization
addpath(genpath('./extern/GradOpt'));

% convert <dataMat> to single for compatibility
dataMat = single(dataMat);

% randomly select a subset of instances for training
instCnt = size(dataMat, 2);
instCntTrn = min(instCnt, paraStr.instCntTrn);
instIdxLstTrn = sort(randperm(instCnt, instCntTrn));
dataMatTrn = dataMat(:, instIdxLstTrn);
lablVecTrn = extrInfo{1}(instIdxLstTrn);

% expand the label vector into a 0/1 indicator matrix
clssIdLst = unique(lablVecTrn);
clssIdCnt = numel(clssIdLst);
lablMatTrn = zeros(clssIdCnt, instCntTrn);
for clssIdIdx = 1 : clssIdCnt
  lablMatTrn(clssIdIdx, lablVecTrn == clssIdLst(clssIdIdx)) = 1;
end

% compute the kernelized feature matrix
if strcmp(paraStr.krnlFuncType, 'linear')
  % directly use raw features for hashing function learning
  featMat = dataMat;
  
  % set anchor points and RBF kernel bandwidth as null values
  dataMatAnc = [];
  rbfKrnlWidt = 0;
else
  % randomly select a subset of instances as anchor points
  instCntAnc = min(instCntTrn, paraStr.instCntAnc);
  instIdxLstAnc = sort(randperm(instCntTrn, instCntAnc));
  dataMatAnc = dataMatTrn(:, instIdxLstAnc);

  % compute the RBF-kernelized feature matrix
  distMat = CalcDistMat(dataMatTrn, dataMatAnc, 'ecld');
  rbfKrnlWidt = mean(distMat(:)) * paraStr.rbfKnrlWidtMul;
  featMat = exp(-distMat .^ 2 / (2 * rbfKrnlWidt ^ 2))';
end

% remove the mean vector from the mapping feature matrix
featVecAve = mean(featMat, 2);
featMatCen = bsxfun(@minus, featMat, featVecAve);

% randomly initialize binary codes for all training instances
if strcmp(paraStr.codeInitMthd, 'rand')
  projMat = [];
  scalVec = [];
  biasVec = [];
  codeMat = (randn(paraStr.hashBitCnt, instCntTrn) > 0) * 2 - 1;
else
  featNrmAve = mean(sqrt(sum(featMat .^ 2, 1)));
  projMat = randn(size(featMatCen, 1), paraStr.hashBitCnt);
  scalVec = ones(paraStr.hashBitCnt, 1) * paraStr.projInitScal / featNrmAve;
  biasVec = randn(paraStr.hashBitCnt, 1) * 1e-2;
  actvMat = bsxfun(@plus, bsxfun(@times, FracPower(...
      projMat' * featMatCen, paraStr.decyCoeffPart), scalVec), biasVec);
  codeMat = (cos(actvMat) > 0) * 2 - 1;
end

% compute the initial classification weighting matrix
clssReguMat = paraStr.reguCoeffClss * eye(paraStr.hashBitCnt);
clssMat = (codeMat * codeMat' + clssReguMat) \ (codeMat * lablMatTrn');

% update the MCSDH model through iterations
for iterIdx = 1 : paraStr.iterCnt
  % display heart-beat message
  fprintf('[INFO] iterIdx = %3d / %3d\n', iterIdx, paraStr.iterCnt);
  
  % update the code matrix and projection parameters
  [codeMat, projMat, scalVec, biasVec] = UpdtCodeProj(featMatCen, ...
      lablMatTrn, clssMat, codeMat, projMat, scalVec, biasVec, paraStr);
  
  % update the classification weighting matrix
  clssMat = (codeMat * codeMat' + clssReguMat) \ (codeMat * lablMatTrn');
    
  % evaluate the objective function's value
  actvMat = bsxfun(@plus, bsxfun(@times, FracPower(...
      projMat' * featMatCen, paraStr.decyCoeffPart), scalVec), biasVec);
  clssLssVal = norm(lablMatTrn - clssMat' * codeMat, 'fro');
  reguLssVal = paraStr.reguCoeffClss * norm(clssMat, 'fro');
  quanLssVal = ...
      paraStr.pnltCoeffQuan * norm(codeMat - cos(actvMat), 'fro');
  objFuncVal = clssLssVal + reguLssVal + quanLssVal;
  fprintf('[INFO] clssLssVal = %.4e\n', clssLssVal);
  fprintf('[INFO] reguLssVal = %.4e\n', reguLssVal);
  fprintf('[INFO] quanLssVal = %.4e\n', quanLssVal);
  fprintf('[INFO] objFuncVal = %.4e\n', objFuncVal);
  
  % check for the early-break condition
  if iterIdx ~= 1
    projMatDiff = projMat - projMatPrev;
    updtRat = norm(projMatDiff, 'fro') / norm(projMat, 'fro');
    fprintf('[INFO] update ratio: %.4f%%\n', updtRat * 100);
    if updtRat < paraStr.optTlrtLmt
      fprintf('[INFO] early break at %d-th iteration\n', iterIdx);
      break;
    end
  end
  projMatPrev = projMat;
  
  actvMatInit = projMat' * featMatCen;
  actvMatPowr = FracPower(actvMatInit, paraStr.decyCoeffPart);
  actvMatScal = bsxfun(@times, actvMatPowr, scalVec);
  actvMatBias = bsxfun(@plus, actvMatScal, biasVec);
  
  subplot(2, 2, 1);
  plot(sort(actvMatInit(:)));
  title(sprintf('actvMatInit (%d / %d)', iterIdx, paraStr.iterCnt));
  subplot(2, 2, 2);
  plot(sort(actvMatPowr(:)));
  title(sprintf('actvMatPowr (%d / %d)', iterIdx, paraStr.iterCnt));
  subplot(2, 2, 3);
  plot(sort(actvMatScal(:)));
  title(sprintf('actvMatScal (%d / %d)', iterIdx, paraStr.iterCnt));
  subplot(2, 2, 4);
  plot(sort(actvMatBias(:)));
  title(sprintf('actvMatBias (%d / %d)', iterIdx, paraStr.iterCnt));
  drawnow;
end

% create the hashing function handler
model.actvFunc = @(dataMat)(ActvFuncImpl(dataMat, ...
    dataMatAnc, rbfKrnlWidt, featVecAve, projMat, scalVec, biasVec, paraStr));
model.hashFunc = @(dataMat)(uint8(cos(model.actvFunc(dataMat)) > 0));

end

function [codeMat, projMat, scalVec, biasVec] = UpdtCodeProj(...
    featMat, lablMat, clssMat, codeMat, projMat, scalVec, biasVec, paraStr)
% INTRO
%   update the code matrix and projection parameters
% INPUT
%   featMat: D x N (feature matrix)
%   lablMat: L x N (extended label matrix)
%   clssMat: R x L (classification weighting matrix)
%   codeMat: R x N (binary code matrix)
%   projMat: D x R (projection matrix)
%   scalVec: R x 1 (scale vector)
%   biasVec: R x 1 (bias vector)
%   paraStr: structure (parameters for training the retrieval model)
% OUTPUT
%   codeMat: R x N (binary code matrix)
%   projMat: D x R (projection matrix)
%   scalVec: R x 1 (scale vector)
%   biasVec: R x 1 (bias vector)

% obtain basic variables
featCnt = size(featMat, 1);
hashBitCnt = size(codeMat, 1);

% randomly initialize the projection matrix and bias vector
if isempty(projMat) || isempty(scalVec) || isempty(biasVec)
  fprintf('[ERROR] un-initialized projection parameters\n');
  exit(-1);
end

% compute the quantization error
actvMat = bsxfun(@plus, bsxfun(@times, FracPower(...
    projMat' * featMat, paraStr.decyCoeffPart), scalVec), biasVec);
quanLssValPrev = norm(codeMat - cos(actvMat), 'fro');

% update each hashing-bit's code & projection parameters
resdMat = lablMat - clssMat' * codeMat;
hashBitLst = randperm(hashBitCnt);
paraStr.codeBlckLen = min(paraStr.codeBlckLen, hashBitCnt);
assert(mod(hashBitCnt, paraStr.codeBlckLen) == 0);
codeBlckCnt = hashBitCnt / paraStr.codeBlckLen;
for codeBlckIdx = 1 : codeBlckCnt
  fprintf('[INFO] codeBlckIdx = %d / %d\n', codeBlckIdx, codeBlckCnt);
  
  % STAGE 0: determine which hashing bits to be optimized
  blckIdxBeg = (codeBlckIdx - 1) * paraStr.codeBlckLen + 1;
  blckIdxEnd = blckIdxBeg + paraStr.codeBlckLen - 1;
  hashBitIdx = hashBitLst(blckIdxBeg : blckIdxEnd);
  
  % STAGE 1: update the binary code sub-matrix with the ideal encoding
  clssMatPt = clssMat(hashBitIdx, :)';
  projMatPt = projMat(:, hashBitIdx);
  scalVecPt = scalVec(hashBitIdx);
  biasVecPt = biasVec(hashBitIdx);
  resdMat = resdMat + clssMatPt * codeMat(hashBitIdx, :);
  actvMatPt = bsxfun(@plus, bsxfun(@times, FracPower(...
      projMatPt' * featMat, paraStr.decyCoeffPart), scalVecPt), biasVecPt);
  codeMatPt = (clssMatPt' * resdMat ...
      + paraStr.pnltCoeffQuan * cos(actvMatPt) > 0) * 2 - 1;
  
  % STAGE 2: update the projection sub-matrix and bias sub-vector
  % pack parameters into a single vector
  paraVec = [projMatPt(:); scalVecPt; biasVecPt];

  % update the projection sub-matrix and bias sub-vector with the L-BFGS solver
  opts.method = 'AdaDelta';
  opts.enblVis = false;
  opts.epchCnt = 20;
  opts.smplCnt = size(featMat, 2);
  opts.batcSiz = 500;
  opts.momentum = 0.90;
  opts.fudgFctr = 1e-6;
  paraVec = minFunc(@CalcCostGrad, paraVec, opts, featMat, codeMatPt, paraStr);

  % extract parameters from the single vector
  projVecPt = paraVec(1 : featCnt * paraStr.codeBlckLen);
  projMatPt = reshape(projVecPt, [featCnt, paraStr.codeBlckLen]);
  scalVecPt = ...
      paraVec(featCnt * paraStr.codeBlckLen + (1 : paraStr.codeBlckLen));
  biasVecPt = ...
      paraVec((featCnt + 1) * paraStr.codeBlckLen + (1 : paraStr.codeBlckLen));
  projMat(:, hashBitIdx) = projMatPt;
  scalVec(hashBitIdx) = scalVecPt;
  biasVec(hashBitIdx) = biasVecPt;
  
  % STAGE 3: update the binary code sub-matrix with the predicted encoding
  actvMatPt = bsxfun(@plus, bsxfun(@times, FracPower(...
      projMatPt' * featMat, paraStr.decyCoeffPart), scalVecPt), biasVecPt);
  codeMatPt = (cos(actvMatPt) > 0) * 2 - 1;
  codeMat(hashBitIdx, :) = codeMatPt;
  resdMat = resdMat - clssMatPt * codeMat(hashBitIdx, :);
end

% compute the quantization error
actvMat = bsxfun(@plus, bsxfun(@times, FracPower(...
    projMat' * featMat, paraStr.decyCoeffPart), scalVec), biasVec);
quanLssValCurr = norm(codeMat - cos(actvMat), 'fro');
fprintf('[INFO] quanLssVal = %.4e -> %.4e\n', quanLssValPrev, quanLssValCurr);

end

function [costVal, gradVec] = ...
  CalcCostGrad(paraVec, smplIdxs, featMat, codeMat, paraStr)
% INTRO
%   compute the cost function's value and gradient vector
% INPUT
%   paraVec: (D x r + r + r) x 1 (projection matrix and bias vector)
%   smplIdxs: M x 1 (list of sample indexes)
%   featMat: D x N (feature matrix)
%   codeMat: r x N (binary code matrix, 1 <= r <= R)
%   paraStr: structure (parameters for training the retrieval model)
% OUTPUT
%   costVal: scalar (cost function's value)
%   gradVec: (D x r + r + r) x 1 (gradient vector)

% obtain basic variables
featCnt = size(featMat, 1);
hashBitCnt = size(codeMat, 1);

% extract parameters from the single vector
projMat = reshape(paraVec(1 : featCnt * hashBitCnt), [featCnt, hashBitCnt]);
scalVec = paraVec(featCnt * hashBitCnt + (1 : hashBitCnt));
biasVec = paraVec((featCnt + 1) * hashBitCnt + (1 : hashBitCnt));

% construct a mini-batch with selected samples
if ~isempty(smplIdxs)
  featMat = featMat(:, smplIdxs);
  codeMat = codeMat(:, smplIdxs);
end

% compute the cost function's value
actvMatInit = projMat' * featMat;
actvMatPowrMOne = FracPower(actvMatInit, paraStr.decyCoeffPart - 1);
actvMatPowr = actvMatInit .* actvMatPowrMOne;
actvMatScal = bsxfun(@times, actvMatPowr, scalVec);
actvMatBias = bsxfun(@plus, actvMatScal, biasVec);
diffMat = codeMat - cos(actvMatBias);
costVal = norm(diffMat, 'fro') ^ 2 / 2;

% compute the gradient of projection matrix and bias vector
dervMatBias = diffMat .* sin(actvMatBias);
dervMatScal = dervMatBias;
dervMatPowr = bsxfun(@times, dervMatScal, scalVec);
dervMatInit = paraStr.decyCoeffPart * (dervMatPowr .* actvMatPowrMOne);
gradVecBias = sum(dervMatBias, 2);
gradVecScal = sum(dervMatBias .* actvMatPowr, 2);
gradMatProj = featMat * dervMatInit';

% pack gradients into a single vector
gradVec = [gradMatProj(:); gradVecScal; gradVecBias];

end

function actvMat = ActvFuncImpl(dataMat, ...
    dataMatAnc, rbfKrnlWidt, featVecAve, projMat, scalVec, biasVec, paraStr)
% INTRO
%   hashing function
% INPUT
%   dataMat: D x N (feature matrix of instances to be encoded)
%   dataMatAnc: D x K (feature matrix of anchor points)
%   rbfKrnlWidt: scalar (RBF kernel's band-width)
%   featVecAve: K x 1 (RBF kernelized feature's mean vector)
%   projMat: R x K (projection matrix)
%   scalVec: R x 1 (scale vector)
%   biasVec: R x 1 (bias vector)
%   paraStr: structure (parameters for training the retrieval model)
% OUTPUT
%   actvMat: R x N (activation matrix)

% compute the kernelized feature matrix
if strcmp(paraStr.krnlFuncType, 'linear')
  featMat = dataMat;
else
  distMat = CalcDistMat(dataMat, dataMatAnc, 'ecld');
  featMat = exp(-distMat .^ 2 / (2 * rbfKrnlWidt ^ 2))';
end
featMatCen = bsxfun(@minus, featMat, featVecAve);

% obtain the final activation matrix
actvMat = bsxfun(@plus, bsxfun(@times, FracPower(...
    projMat' * featMatCen, paraStr.decyCoeffPart), scalVec), biasVec);

end

function y = FracPower(x, alpha)
% INTRO
%   compute the fractional power of <x>
% INPUT
%   x: M x N (input data matrix)
%   alpha: scalar (exponent number)
% OUTPUT
%   y: M x N (output data matrix)

% replace extremely small values for numerical stability
valMin = 1e-6;
x(x >= 0 & x < valMin) = valMin;
x(x < 0 & x > -valMin) = -valMin;

% compute the fractional power, ensuring real-valued outputs
[valNum, valDen] = rat(alpha);
if mod(valNum, 2) == 1
  assert(mod(valDen, 2) == 1); % otherwise, complex numbers are required
  y = sign(x) .* exp(alpha * log(abs(x)));
else
  y = exp(alpha * log(abs(x)));
end

end
