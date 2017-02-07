% Got by modifying Wei Liu's codes
function [Z_nmlz, Z, sigma] = get_Z(X, Anchor, s, sigma)

[n,~] = size(X);
m = size(Anchor,1);

%% get Eucilidian distance

if n <= 1e5
    Dis = EuDist2(X,Anchor,0);
else
    Dis = zeros(n, m);
    l = floor(n / 1e5); r = mod(n, 1e5);
    for i = 1 : l
        Xi = X((i-1)*1e5 + [1:1e5], :);
        Dis((i-1)*1e5 + [1:1e5], :) = EuDist2(Xi,Anchor,0);  
%         pause(1);
    end
    clear Xi;
    if r > 0
        Dis(l*1e5 + 1 : end,:) = EuDist2(X(l*1e5 +1 : end,:),Anchor,0);
    end
end
clear X;
clear Anchor;
% display('0.....');

%% get Z

% display('1.....');
val = zeros(n,s);
pos = val;
for i = 1:s
    [val(:,i),pos(:,i)] = min(Dis,[],2);
    tep = (pos(:,i)-1)*n+[1:n]';
    Dis(tep) = 1e60; 
end
clear Dis;
clear tep;

if sigma == 0
   sigma = mean(val(:,s).^0.5);
%     sigma = mean(mean(val)).^0.5;
end
val = exp(-val/(1/1*sigma^2));

if nargout >= 2
    Z = zeros(n,m);
    tep = (pos-1)*n+repmat([1:n]',1,s);
    Z([tep]) = [val];
    Z = sparse(Z);
end
%% get normalized Z
val_nmlz = repmat(sum(val,2).^-1,1,s).*val; % normalize %val_nmlz = bsxfun(@rdivide, val, sum(val,2)); %
clear val;
Z_nmlz = zeros(n,m);
if ~exist('tep', 'var')
    tep = (pos-1)*n+repmat([1:n]',1,s);
end
Z_nmlz([tep]) = [val_nmlz];
Z_nmlz = sparse(Z_nmlz);
clear val_nmlz;
clear tep;
clear pos;
% display('3.....');

end

