function [ctrdLst, asmtLst] = KMeansClst(dataMat, opts)
% INTRO
%   k-means clustering
% INPUT
%   dataMat: D x N (data matrix)
%   opts: struct (hyper-parameters)
%   ctrdCnt: scalar (number of centroids)
%   iterCnt: scalar (number of iterations)
%   enblVrbs: bool (enable verbose output or not)
%   varargin: D x K (initial clustering centroids; optional)
% OUTPUT
%   ctrdLst: D x K (clustering centroids)
%   asmtLst: 1 x N (each sample's assignment)

% define constant variables
kSmplCntPerBatc = 100000; % number of samples per mini-batch

% obtain basic variables
smplCnt = size(dataMat, 2);
batcCnt = ceil(smplCnt / kSmplCntPerBatc);

% randomly select <k> instances as initial centroids
if isempty(opts.ctrdLst)
  ctrdLst = InitCtrdLst(dataMat, opts);
else
  ctrdLst = opts.ctrdLst;
end

% run k-means iterations
asmtLst = zeros(1, smplCnt);
for iterIdx = 1 : opts.iterCnt
  % assign each instance to its nearest centroid
  distrVal = 0;
  for batcIdx = 1 : batcCnt
    smplIdxBeg = (batcIdx - 1) * kSmplCntPerBatc + 1;
    smplIdxEnd = min(smplCnt, smplIdxBeg + kSmplCntPerBatc - 1);
    smplIdxLst = (smplIdxBeg : smplIdxEnd);
    distMat = CalcDistMat(dataMat(:, smplIdxLst), ctrdLst, 'ecld');
    [distVec, asmtLst(smplIdxLst)] = min(distMat, [], 2);
    distrVal = distrVal + sum(distVec);
  end

  % update each centroid's feature vector
  for ctrdIdx = 1 : opts.ctrdCnt
    smplIdxLst = find(asmtLst == ctrdIdx);
    if ~isempty(smplIdxLst)
      ctrdLst(:, ctrdIdx) = mean(dataMat(:, smplIdxLst), 2);
    end
  end

  % display the iteration progress
  if opts.enblVrbs
    fprintf('iterIdx = %d, distrVal = %.4e\n', iterIdx, distrVal);
  end
end

end

function ctrdLst = InitCtrdLst(dataMat, opts)
% INTRO
%   initialize a list of centroids for k-means clustering centroids
% INPUT
%   dataMat: D x N (data matrix)
%   opts: struct (hyper-parameters)
% OUTPUT
%   ctrdLst: D x K (clustering centroids)

% obtain basic variables
smplCnt = size(dataMat, 2);

% disable the <adp> mode if the centroids are too many (efficiency concern)
if opts.ctrdCnt >= 1024
  opts.initMthd = 'rnd';
end

% randomly initialize centroids for k-means clustering
if strcmp(opts.initMthd, 'rnd')
  dataIdxLst = randperm(smplCnt, opts.ctrdCnt);
  ctrdLst = dataMat(:, dataIdxLst);
end

% adaptively initialize centroids for k-means clustering
if strcmp(opts.initMthd, 'adp')
  % randomly select the first centroid
  smplIdx = ceil(rand() * smplCnt);
  ctrdLst = repmat(dataMat(:, smplIdx), [1, opts.ctrdCnt]);

  % compute the initial distance to centroid
  distVec = CalcDistMat(dataMat, ctrdLst(:, 1), 'ecld');

  % iteratively select data points as centroids
  for ctrdIdx = 2 : opts.ctrdCnt
    % randomly select a data point w.r.t. the distance to centroid
    probVec = distVec / sum(distVec);
    smplIdx = randsample(smplCnt, 1, true, probVec);
    ctrdLst(:, ctrdIdx) = dataMat(:, smplIdx);

    % update the distance to centroid
    distVec = min(distVec, CalcDistMat(dataMat, ctrdLst(:, ctrdIdx), 'ecld'));
  end
end

end
