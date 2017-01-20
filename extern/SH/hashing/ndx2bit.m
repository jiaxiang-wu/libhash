function xb = ndx2bit(x, n, word)
%
% x = unit8 array
% n = number of bits used to code each element of 'x'
%
% xb = compacted string of bits (using words of 'word' bits)

if nargin<3
    word = 32;
end

[dim nSamples] = size(x);
nbits = sum(n);

nw = ceil(nbits/word);

switch word
    case 8
        xb = zeros([nw nSamples], 'uint8');
    case 16
        xb = zeros([nw nSamples], 'uint16');
    case 32
        xb = zeros([nw nSamples], 'uint32');
end

m = 0;
w = 1;
for j = 1:dim
    for i = 1:n(j)
        m = m+1;
        c = bitget(x(j,:), i);
        xb(w,:) = bitset(xb(w,:), m, c);
        
        if m == word
            w = w+1;
            m = 0;
        end
    end
end


