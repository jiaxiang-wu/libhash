% Spectral Hashing
% Y. Weiss, A. Torralba, R. Fergus. 
% Advances in Neural Information Processing Systems, 2008.
%
% CONVENTIONS:
%    data points are row vectors.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1) Create toy data:
% some parameters
Ntraining = 3000; % number training samples
Ntest = 3000; % number test samples
averageNumberNeighbors = 50; % number of groundtruth neighbors on training set (average)
aspectratio = 0.5; % aspect ratio between the two axis
loopbits = [2 4 8 16 32]; % try different number of bits for coding

% uniform distribution
Xtraining = rand([Ntraining,2]); Xtraining(:,2) = aspectratio*Xtraining(:,2);
Xtest = rand([Ntest,2]);  Xtest(:,2) = aspectratio*Xtest(:,2);

% define ground-truth neighbors (this is only used for the evaluation):
DtrueTraining = distMat(Xtraining);
DtrueTestTraining = distMat(Xtest,Xtraining); % size = [Ntest x Ntraining]
Dball = sort(DtrueTraining,2);
Dball = mean(Dball(:,averageNumberNeighbors));
WtrueTestTraining = DtrueTestTraining < Dball;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2) demo spectral hashing
clear SHparam score
colors = 'cbmrg'; 
i = 0;
m = ceil(rand*Ntest); % random test sample for visualization

for nb = loopbits
    i = i+1;
    SHparam.nbits = nb; % number of bits to code each sample

    % training
    SHparam = trainSH(Xtraining, SHparam);

    % compress training and test set
    [B1,U1] = compressSH(Xtraining, SHparam);
    [B2,U2] = compressSH(Xtest, SHparam);

    % example query
    Dhamm = hammingDist(B2, B1);
    %    size(Dhamm) = [Ntest x Ntraining]

    % evaluation
    score(:,i) = evaluation(WtrueTestTraining, Dhamm, 1, 'o-', 'color', colors(i));
    
    % Visualization
    figure
    subplot(211)
    show2dfun(Xtraining, -double(hammingDist(B2(m,:), B1)')); 
    colormap([1 0 0; jet(nb)])
    title({sprintf('Hamming distance to a test sample with %d bits', nb), 
        'red = unasigned'})
    subplot(212)
    show2dfun(Xtraining, WtrueTestTraining(m,:)');
    title('Ground truth neighbors for the test sample')
    colormap(jet(nb))
end

% Show eigenfunctions
figure
show2dfun(Xtraining, U1);

% Show eigenfunctions
figure
plot(loopbits, score(2,:))
xlabel('number of bits')
ylabel('precision for hamming ball 2')

