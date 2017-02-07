% addpath C:\Users\fumin\Documents\code\Hashing\SRH_our\trunk
% Load data
load 'mnist_train.mat'

% Set parameters
no_dims = 2;
init_dims = 30;
ratio_landmarks = 0.01; % use 6,000 points
perplexity = 30;
%Run tSNE
tic
[mappedX, landmarks] = fast_tsne(train_X, no_dims, init_dims, ...
ratio_landmarks, perplexity);
toc
% Plot results
figure; gscatter(mappedX(:,1), mappedX(:,2), train_labels(landmarks));

% 
% tic
% [~, anchors] = litekmeans(train_X, 600);
% % anchors = train_X(landmarks,:);
% [E] = tsne(anchors, [], no_dims, init_dims, perplexity);
% n_landmarks = 6000;
% landmarks = randsample(size(train_X,1), n_landmarks);
% Z = get_Z(train_X(landmarks,:), anchors, 2, 0);
% E_landmarks = Z*E;
% toc
% figure;plot(E(:,1), E(:,2), '.');
% figure; gscatter(E_landmarks(:,1), E_landmarks(:,2), train_labels(landmarks));
