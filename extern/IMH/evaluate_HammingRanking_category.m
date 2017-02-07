function [pre, rec] = evaluate_HammingRanking_category(trnlabel, tstlabel,rank)

if size(rank,1)~=length(trnlabel)
    error('score and label must be equal length\n');
    pause;
end


precision = zeros(length(tstlabel), length(trnlabel));
recall = zeros(length(tstlabel), length(trnlabel));

for n = 1:length(tstlabel)
    [precision(n,:), recall(n,:)] = prcal(rank(:,n),trnlabel,tstlabel(n),M_set);
end
pre=mean(precision);
rec=mean(recall);

end

function [Pre, Rec] = prcal(sorted_ind,label,trueLabel)


%%% number of true samples
num_TrueNN=sum(label==trueLabel);
if num_TrueNN == 0
    pause
end
%%% number of samples
numTrain=length(label);

%%% 
sorted_truefalse=(label(sorted_ind)==trueLabel);
cumsum_rank=cumsum(sorted_truefalse);


Rec =cumsum_rank/num_TrueNN;
Pre =cumsum_rank./[1:numTrain]';



end
