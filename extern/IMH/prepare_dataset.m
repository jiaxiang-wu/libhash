function prepare_dataset(dataset, an)
% dataset is stored in a row-wise matrix
%%
load(['./datasets/',dataset]);

traindata = normalize(traindata);
testdata  = normalize(testdata);

  
%%
if exist('traingnd','var')
    cateTrainTest = bsxfun(@eq, traingnd, testgnd');
end

% an = [400,1000];
for ix = 1 : length(an)
    n_anchors = an(ix);
    anchor_nm = ['anchor_' num2str(n_anchors)];
    eval(['[~,' anchor_nm '] = litekmeans(traindata, n_anchors, ''MaxIter'', 10);']);
%     eval(['[~,' anchor_nm ',~, sumD, D] = litekmeans(traindata, n_anchors, ''MaxIter'', 10);']);
    eval(['anchor_set.' anchor_nm '= ' anchor_nm, ';']);
%     eval(['anchor_set.' anchor_nm '_Dis = D;']);
end


if exist('traingnd','var')
        save(['testbed/',dataset],'traindata','testdata','traingnd','testgnd','cateTrainTest',...
            'anchor_set','-v7.3');
else
    save(['testbed/',dataset],'traindata','testdata', 'anchor_set','-v7.3');
end
clear;

end
