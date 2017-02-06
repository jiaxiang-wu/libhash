function Q = LiftProjection(M,iter)
% Input: matrix M = matrix Lambda, number of iterations iter. Output: orthogonal matrix Q
n = size(M,1);
a = trace(M)/n;

%random orthogonal matrix U
R = randn(n,n);
[U S V] = svd(R);
Z = U*M*U';

for i = 1:iter
    % find T
    T = Z;
    for j = 1:n
        T(j,j) = a;
    end
    % find Z
    [Q eigenValue] = eigsdescend(T,n);
    Z = Q*M*Q';
end
Q=Q';
end

