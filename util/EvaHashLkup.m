function evaRslt = EvaHashLkup(distLst, linkLst, linkCntLst, hashLkupRad)
% INTRO
%   evaluate the hashing look-up strategy for ANN search
% INPUT
%   distLst: N x 1 (list of Hamming distance)
%   linkLst: K x 1 (list of ground-truth matches)
%   linkCntLst: L x 1 (list of number of ground-truth matches)
%   hashLkupRad: scalar (hashing look-up's radius)
% OUTPUT
%   evaRslt: struct (evaluation results)

% initialize arrays to store evaluation results
evaRslt.precVec = zeros(1, numel(linkCntLst));
evaRslt.reclVec = zeros(1, numel(linkCntLst));

% evaluate w.r.t. different number of ground-truth matches
for idx = 1 : numel(linkCntLst)
  % compute the recall score
  linkCnt = linkCntLst(idx);
  hitCnt = sum(ismember(find(distLst <= hashLkupRad), linkLst(1 : linkCnt)));
  evaRslt.precVec(idx) = hitCnt / sum(distLst <= hashLkupRad);
  evaRslt.reclVec(idx) = hitCnt / linkCnt;
end

end
