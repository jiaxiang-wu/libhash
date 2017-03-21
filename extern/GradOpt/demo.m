function demo()
% INTRO
%   demonstrates the usage of minFunc(), in the context of linear regression
% INPUT
%   None
% OUTPUT
%   None

close all; clearvars; clc;

% randomly generate feature vectors and targe values
opts.smplCnt = 1000;
opts.featCnt = 100;
opts.ouptCnt = 50;
opts.featMgn = 1.0;
opts.projMgn = 1.0;
opts.noisRat = 0.02;
[featMat, ouptMat, projMatUnly] = GnrtData(opts);

% evaluate the underlying projection matrix
[funcValUnly, ~] = CalcFuncGrad(projMatUnly(:), [], featMat, ouptMat);
fprintf('[INFO] funcVal (underlying) = %.4e\n', funcValUnly);

% obtain the closed-form solution to the linear regression
projMatClsd = (ouptMat / featMat)';
[funcValClsd, ~] = CalcFuncGrad(projMatClsd(:), [], featMat, ouptMat);
fprintf('[INFO] funcVal (closed-form) = %.4e\n', funcValClsd);

% initialize optimization options for each method
[optsGradDst, optsAdaGrad, optsAdaDelta, optsAdam] = InitOpts(opts.smplCnt);

% evaluate each method's performance
[~, ~, funcVecGradDst]  = EvaMethod(featMat, ouptMat, optsGradDst);
[~, ~, funcVecAdaGrad]  = EvaMethod(featMat, ouptMat, optsAdaGrad);
[~, ~, funcVecAdaDelta] = EvaMethod(featMat, ouptMat, optsAdaDelta);
[~, ~, funcVecAdam]     = EvaMethod(featMat, ouptMat, optsAdam);

% visualize the optimization process of each method
VisualOptProc([funcVecGradDst, funcVecAdaGrad, funcVecAdaDelta, funcVecAdam]);

end

function [featMat, ouptMat, projMat] = GnrtData(opts)
% INTRO
%   randomly generate a dataset for linear regression
% INPUT
%   opts: structure (dataset generation options)
% OUTPUT
%   featMat: D x N (feature matrix)
%   ouptMat: R x N (output matrix)
%   projMat: D x R (projection matrix)

% randomly generate feature vectors and targe values
featMat = opts.featMgn * randn(opts.featCnt, opts.smplCnt);
projMat = opts.projMgn * randn(opts.featCnt, opts.ouptCnt);
ouptMat = projMat' * featMat;
noisMgn = opts.noisRat * norm(ouptMat, 'fro');
ouptMat = ouptMat + noisMgn * randn(opts.ouptCnt, opts.smplCnt);

end

function [funcVal, gradVec] = CalcFuncGrad(paraVec, smplIdxs, featMat, ouptMat)
% INTRO
%   compute the objective function's value and gradient vector
% INPUT
%   paraVec: (D * R) x 1 (projection matrix, viewed as the column vector)
%   smplIdxs: M x 1 (list of sample indexes)
%   featMat: D x N (feature matrix)
%   ouptMat: R x N (output matrix)
% OUTPUT
%   funcVal: scalar (objective function's value)
%   gradVec: (D * R) x 1 (objective function's gradient vector)

% obtain basic variables
featCnt = size(featMat, 1);
smplCnt = size(featMat, 2);
ouptCnt = size(ouptMat, 1);

% recover the projection matrix
projMat = reshape(paraVec, [featCnt, ouptCnt]);

% construct a mini-batch with randomly selected samples
if ~isempty(smplIdxs)
  batcSiz = numel(smplIdxs);
  featMat = featMat(:, smplIdxs);
  ouptMat = ouptMat(:, smplIdxs);
else
  batcSiz = smplCnt;
end

% compute the objective function's value
diffMat = projMat' * featMat - ouptMat;
funcVal = norm(diffMat, 'fro') ^ 2 / 2 / batcSiz;

% compute the objective function's gradient vector
gradMat = featMat * diffMat' / batcSiz;
gradVec = gradMat(:);

end

function [optsGradDst, optsAdaGrad, optsAdaDelta, optsAdam] = InitOpts(smplCnt)
% INTRO
%   initialize optimization options for each method
% INPUT
%   smplCnt: scalar (number of samples; required for mini-batch construction)
% OUTPUT
%   optsGradDst: structure (GradDst's optimization options)
%   optsAdaGrad: structure (AdaGrad's optimization options)
%   optsAdaDelta: structure (AdaDelta's optimization options)
%   optsAdam: structure (Adam's optimization options)

% configure common optimization options for all methods
opts.enblVis = false;
opts.epchCnt = 100;
opts.smplCnt = smplCnt;
opts.batcSiz = 50;

% configure optimization options for GradDst
optsGradDst = opts;
optsGradDst.method = 'GradDst';
optsGradDst.lrInit = 1e-2;
optsGradDst.lrIncrMult = 1.5;
optsGradDst.lrDecrMult = 0.5;
optsGradDst.momentum = 0.9;

% configure optimization options for AdaGrad
optsAdaGrad = opts;
optsAdaGrad.method = 'AdaGrad';
optsAdaGrad.lrInit = 1e-1;
optsAdaGrad.autoCorr = 0.95;
optsAdaGrad.fudgFctr = 1e-6;

% configure optimization options for AdaDelta
optsAdaDelta = opts;
optsAdaDelta.method = 'AdaDelta';
optsAdaDelta.momentum = 0.999;
optsAdaDelta.fudgFctr = 1e-6;

% configure optimization options for Adam
optsAdam = opts;
optsAdam.method = 'Adam';
optsAdam.lrInit = 1e-1;
optsAdam.betaFst = 0.90;
optsAdam.betaSec = 0.90;
optsAdam.fudgFctr = 1e-6;

end

function [projMat, funcVal, funcVec] = EvaMethod(featMat, ouptMat, opts)
% INTRO
%   evaluate the selected optimization method
% INPUT
%   featMat: D x N (feature matrix)
%   ouptMat: R x N (output matrix)
%   opts: structure (optimization options)
% OUTPUT
%   projMat: D x R (projection matrix)
%   funcVal: scalar (function's value of the optimal solution)
%   funcVec: T x 1 (list of function's values through iterations)

% obtain basic variables
featCnt = size(featMat, 1);
ouptCnt = size(ouptMat, 1);

% solve the optimization via gradient descent
projMatInit = randn(featCnt, ouptCnt);
paraVecInit = projMatInit(:);
[paraVec, funcVal, funcVec] = ...
  minFunc(@CalcFuncGrad, paraVecInit, opts, featMat, ouptMat);
projMat = reshape(paraVec, [featCnt, ouptCnt]);
fprintf('[INFO] funcVal (%s) = %.4e\n', opts.method, funcVal);

end

function VisualOptProc(funcMat)
% INTRO
%   visualize the optimization process of each method
% INPUT
%   funcMat: (T + 1) x 4 (matrix of function's values through iterations)
% OUTPUT
%   None

% obtain basic variables
iterCnt = size(funcMat, 1) - 1; % exclude the initial function's value
iterCntLast = 11;
assert(iterCntLast <= iterCnt);
xAxisLft = (0 : iterCnt);
xAxisRht = (iterCnt - iterCntLast + 1 : iterCnt);

% LEFT FIGURE: complete curve of function's values
subplot(1, 2, 1);
hold on;
plot(xAxisLft, funcMat(:, 1), 'r-o');
plot(xAxisLft, funcMat(:, 2), 'g-.+');
plot(xAxisLft, funcMat(:, 3), 'b-*');
plot(xAxisLft, funcMat(:, 4), 'm-.x');
grid on;
legend({'GradDst', 'AdaGrad', 'AdaDelta', 'Adam'}, 'Location', 'East');
xlabel('# of Iterations');
ylabel('Mean Squared Error');
set(gca, 'FontSize', 12);
title(sprintf('All %d Iterations', iterCnt));

% RIGHT FIGURE: partial curve of function's values (last a few iterations)
subplot(1, 2, 2);
hold on;
plot(xAxisRht, funcMat(end - iterCntLast + 1 : end, 1), 'r-o');
plot(xAxisRht, funcMat(end - iterCntLast + 1 : end, 2), 'g-.+');
plot(xAxisRht, funcMat(end - iterCntLast + 1 : end, 3), 'b-*');
plot(xAxisRht, funcMat(end - iterCntLast + 1 : end, 4), 'm-.x');
grid on;
legend({'GradDst', 'AdaGrad', 'AdaDelta', 'Adam'}, 'Location', 'East');
xlabel('# of Iterations');
ylabel('Mean Squared Error');
set(gca, 'FontSize', 12);
title(sprintf('Last %d Iterations', iterCntLast));

end
