clear
addpath ./tSNE
%% settings
codeLen = [16, 32, 64]; %number of hash bits
hammRadius = 2;
m = length(codeLen);

dataset = 'mnist';
isgnd =1;
anchor_numbers = 400;   %[400,1000];
%% uncommnet the follwing tow lines for the first run
% display('prepare datasets...');
% prepare_dataset(dataset, anchor_numbers);

display([dataset ': ']);
load(['testbed/',dataset]);


n_anchors = 400;
anchor_nm = ['anchor_' num2str(n_anchors)];
eval(['anchor = anchor_set.' anchor_nm ';']);


%% Initialization
method = 'IMH-tSNE';  % 'IMH-LE'
display([method ': ']);
options = InitOpt(method);


for i = 1 : m
    display(['learn ' num2str(codeLen(i)) ' bits...']);
    options.nbits = codeLen(i);
    options.maxbits = codeLen(i);
    %% hashing
    switch method
        case 'IMH-LE'
            [Embedding,Z_RS,sigma] = InducH(anchor, traindata, options);
            EmbeddingX = Z_RS*Embedding;
            H = EmbeddingX > 0;
            [tZ] = get_Z(testdata, anchor, options.s, sigma);
            tEmbedding = tZ*Embedding;
            tH = tEmbedding > 0;
            clear EmbeddingS EmbeddingX tEmbedding Z_RS tZ;
        case 'IMH-tSNE'
            % get embedding for anchor points
            options.nbits = codeLen(i);
            [Embedding] = tSNEH(anchor, options);
            [Z,~, sigma] = get_Z(traindata, anchor, options.s, options.sigma);
            EmbeddingX = Z*Embedding;
            H = EmbeddingX > 0;
            [tZ] = get_Z(testdata, anchor,  options.s, sigma);
            tEmbedding = tZ*Embedding;
            tH = tEmbedding > 0;
            clear Embedding EmbeddingX tEmbedding Z tZ;
    end
    %% evaluation
    display('Evaluation...');
    B = compactbit(H);
    tB = compactbit(tH);
    hammTrainTest = hammingDist(tB, B)';
    clear B tB;
    
    Ret = (hammTrainTest <= hammRadius+0.00001);
    % get hash lookup using hamming ball
    [cateP, cateR] = evaluate_macro(cateTrainTest, Ret); % category
    cateF1(i) = F1_measure(cateP, cateR);
    clear cateP cateR
    % get hamming ranking: MAP
    [~, HammingRank]=sort(hammTrainTest,1);
    [cateMAP(i)] = cat_apcal(traingnd,testgnd,HammingRank);
end
save(['results/',dataset,'_',method],  'cateMAP',  'cateF1');
clear cateMAP cateF1








