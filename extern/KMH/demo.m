function [h_fig] = demo(Xtraining, Xtest, gt, num_bits, num_bits_subspace, use_mex)

%num_bits = 64; % num of bits per vector

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% training and encoding
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% KMH
B = num_bits;  
b = num_bits_subspace;   % num of bits per subspace
         % recommended:
         % SIFT-32bits: b=2; SIFT-64,128bits: b=4;
         % GIST: b=4 or 8; (b=8 is slightly better but slower for training)
         
num_iter = 50; % num of iterations, 50 to 200. Usually 50 is enough.
lambda = 10;
nSamples = 100000; %size(Xtraining,1); num of samples to train affinity preserving KM. Better to use all samples. 
M = B / b;  % num of subspaces

if nSamples == size(Xtraining,1)
    training_id = 1:nSamples;
else
    training_id = randperm(size(Xtraining,1));
    training_id = training_id(1:nSamples);
end

tic
[centers_table, R, sample_mean] = trainKMH(Xtraining(training_id, :), M, b, num_iter, lambda);
toc

tic
BincodeXtrainingKMH = encode_KMH(Xtraining, R, sample_mean, M, b, centers_table);
BincodeXtestKMH = encode_KMH(Xtest, R, sample_mean, M, b, centers_table);
toc

fprintf('KMH done.\n\n');

% ITQ
addpath 'ITQ';
tic
[sample_mean, eigVec, R] = trainITQ(Xtraining, num_bits);
toc
BincodeXtrainingITQ = compactbit(bsxfun(@minus, Xtraining, sample_mean) * eigVec * R > 0);
BincodeXtestITQ = compactbit(bsxfun(@minus, Xtest, sample_mean) * eigVec * R > 0);

fprintf('ITQ done.\n\n');

clear Xtraining;
clear Xtest;

save workingspace.mat;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evaluation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

K = 10; % K-NNs as ground truth;
gt = gt(:,1:K);

selectivity = 10000; 

if use_mex
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % evaluation in mex
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    addpath .\mex;
    
    h_fig = figure();
    hold on;
    
    tic
    recall_vs_sel_KMH = mexHamming(BincodeXtrainingKMH', BincodeXtestKMH', int32((gt-1)'), K, selectivity);
    plot(recall_vs_sel_KMH, 'b');
    drawnow;
    toc
    
    tic
    recall_vs_sel_ITQ = mexHamming(BincodeXtrainingITQ', BincodeXtestITQ', int32((gt-1)'), K, selectivity);
    plot(recall_vs_sel_ITQ, 'g');
    drawnow;
    toc
    
    legend('KMH', 'ITQ');
    ylim([0,1]);
    
    fprintf('evaluation in mex done.\n\n');
    
    clear functions;    
else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % evaluation in MATLAB
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    num_test = 100; % num of queries evaluated (evaluate a few samples due to efficiency)
    test_id = randperm(size(BincodeXtestKMH, 1));
    test_id = test_id(1:num_test);
    
    tic
    recall_vs_sel_KMH = eval_recall_vs_sel(BincodeXtrainingKMH, BincodeXtestKMH(test_id, :), gt(test_id, :), K, selectivity);
    toc
    tic
    recall_vs_sel_ITQ = eval_recall_vs_sel(BincodeXtrainingITQ, BincodeXtestITQ(test_id, :), gt(test_id, :), K, selectivity);
    toc
    
    h_fig = figure();
    hold on;
    plot(recall_vs_sel_KMH, 'b');
    plot(recall_vs_sel_ITQ, 'g');
    legend('KMH', 'ITQ');
    ylim([0,1]);
    drawnow;
    
    fprintf('evaluation in MATLAB done.\n\n');
end