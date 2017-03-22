function normFunc = GnrtNormFunc(featMat)
% INTRO
%   generate a normalization function handler
% INPUT
%   featMat: D x N (feature matrix)
% OUTPUT
%   normFunc: func. handler (normalization function)

% calculate the max/min/mean value for each feature dimension
featVecMax = max(featMat, [], 2);
featVecMin = min(featMat, [], 2);
featVecAve = mean(featMat, 2);

% generate a normalization function handler
biasVec = -featVecAve;
scalVec = (featVecMax - featVecMin) .^ (-1);
scalVec(isinf(scalVec)) = 1.0; % replace <inf> with 1.0
normFunc = @(x)(bsxfun(@times, bsxfun(@plus, x, biasVec), scalVec));

end
