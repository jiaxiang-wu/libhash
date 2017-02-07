function [E] = tSNEH(train_X, options)



% Set parameters
no_dims = options.maxbits;
init_dims = max(20, no_dims);
perplexity = 10;
% Run tSNE
[E] = tsne(train_X, [], no_dims, init_dims, perplexity);
% [E] = compute_mapping(train_X, 'tSNE', no_dims);%, init_dims, perplexity);




end
