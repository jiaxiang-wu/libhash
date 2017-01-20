% settings
nBits = 16;
nTrain = 10000;
nTest = 10;
radius = 3;

%%% generate data
train = ndx2bit(uint8(rand(nBits,nTrain)>0.5),ones(nBits,1),8);
test  = ndx2bit(uint8(rand(nBits,nTest )>0.5),ones(nBits,1),8);

%%% generate gt. neighbors
tic;
neigh_true = cell(1,nTest);
for a=1:nTest
  d = hammingDist(test(:,a)',train');
  neigh_true{a} = find(d<=radius);
end
exhaustive_time = toc;


%%% now run semantic hash
[neighbors_out,time_taken] = semantic_hash(train,test,radius);

%%% check for differences
flag = 1;

for a=1:nTest

  q = setdiff(neigh_true{a},nonzeros(neighbors_out(:,a)));
  l1 = length(neigh_true{a});
  l2 = length(nonzeros(neighbors_out(:,a)));
  
  if any(q)
    flag = 0;
  end
  
  if (l1~=l2) %%% check that we don't have repeats
    fprintf('Same elements, but repeats present in query example: %d\n',a);
  end
  
end

if flag,
  fprintf('\n\n100%% agreement\n');
else
  fprintf('\n\nError: disagreement!!!\n');
  % disgreements could arise if total # neighbors is > MAX_RETURN (at top
  % of mex file). Check this if you have problems.
end

fprintf('Exhaustive time: %f, Semantic hash time: %f\n',exhaustive_time,time_taken);
