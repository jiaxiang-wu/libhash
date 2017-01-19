function [precScrLst, reclScrLst, meanAP] = ...
    CalcPrecReclMap(distLst, linkLst, evaPosLst)
% INTRO
%   compute the precision/recall@T and meanAP scores
% INPUT
%   distLst: N x 1 (list of Hamming distance)
%   linkLst: K x 1 (list of ground-truth matches)
%   evaPosLst: S x 1 (list of evaluation positions)
% OUTPUT
%   precScrLst: S x 1 (list of precision@T scores)
%   reclScrLst: S x 1 (list of recall@T scores)
%   meanAP: scalar (meanAP score)

% sort instances in the ascending order of the Hamming distance
[~, swapIdxLst] = sort(distLst);

% compute the 0/1 hit list (0: false NN; 1: true NN)
hitLst = zeros(size(swapIdxLst));
hitLst(linkLst) = 1;
hitLst = hitLst(swapIdxLst);

% compute the precision/recall@T scores
hitCntLst = cumsum(hitLst);
precScrLst = hitCntLst(evaPosLst)' ./ evaPosLst';
reclScrLst = hitCntLst(evaPosLst)' / numel(linkLst);

% compute the meanAP score
evaPosLst = find(hitLst > 0);
meanAP = mean(hitCntLst(evaPosLst) ./ evaPosLst);

end
