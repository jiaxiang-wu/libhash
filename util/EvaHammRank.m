function evaRslt = EvaHammRank(distLst, linkLst, linkCntLst, evaPosLst)
% INTRO
%   evaluate the Hamming ranking strategy for ANN search
% INPUT
%   distLst: N x 1 (list of Hamming distance)
%   linkLst: K x 1 (list of ground-truth matches)
%   linkCntLst: L x 1 (list of number of ground-truth matches)
%   evaPosLst: S x 1 (list of evaluation positions)
% OUTPUT
%   evaRslt: struct (evaluation results)

% sort instances in the ascending order of the Hamming distance
[~, swapIdxLst] = sort(distLst);

% initialize arrays to store evaluation results
evaPosCnt = numel(evaPosLst);
evaRslt.precMat = zeros(evaPosCnt, numel(linkCntLst));
evaRslt.reclMat = zeros(evaPosCnt, numel(linkCntLst));
evaRslt.mapVec = zeros(1, numel(linkCntLst));

% evaluate w.r.t. different number of ground-truth matches
for idx = 1 : numel(linkCntLst)
  % compute the 0/1 hit list (0: false NN; 1: true NN)
  linkCnt = linkCntLst(idx);
  hitLst = zeros(size(swapIdxLst));
  hitLst(linkLst(1 : linkCnt)) = 1;
  hitLst = hitLst(swapIdxLst);

  % compute the precision/recall@T scores
  hitCntLst = cumsum(hitLst);
  evaRslt.precMat(:, idx) = hitCntLst(evaPosLst)' ./ evaPosLst';
  evaRslt.reclMat(:, idx) = hitCntLst(evaPosLst)' / linkCnt;

  % compute the meanAP score
  hitPosLst = find(hitLst > 0);
  evaRslt.mapVec(idx) = mean(hitCntLst(hitPosLst) ./ hitPosLst);
end

end
