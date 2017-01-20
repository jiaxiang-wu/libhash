function [U,X,Y] = show2dfun(X,u)
% [U,X,Y] = show2dfun(X,u)
%
% Display the 2D function u(X)
% X does not need to be a regular grid

X = double(X);
D = size(X,2);

if D > 1
    x = X(:,1);
    y = X(:,2);

    n = size(u,2);
    nx = ceil(sqrt(n)); ny = ceil(n/nx);

    kernel = ones(5,5);

    L = 100; % minimal image size
    mx = min(x);
    Mx = max(x);
    my = min(y);
    My = max(y);

    D = min((Mx-mx)/L, (My-my)/L);
    [X,Y] = meshgrid(mx:D:Mx, my:D:My);
    [nr,nc] = size(X);

    U = zeros([nr nc 1 n], 'single');
    i = sub2ind([nr nc], fix((nr-1)*(y-my)/(My-my)+1), fix((nc-1)*(x-mx)/(Mx-mx)+1));
    mask = zeros(size(X));
    mask(i) = 1;
    mask = conv2(mask, kernel, 'same')>0;
    
    for m = 1:n
        p = prctile(abs(u(:,m)), 95);
        uu = griddata(x, y, u(:,m), X, Y);
        uu = uint8(128+128*uu/p);
        uu(mask==0) = 0;

        U(:,:,:,m) = uu;
    end
end

montage(uint8(U))



