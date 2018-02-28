% centripetal: Calculate centripetal parameterization for datapoints d
% Input:
%   d         Datapoints. d has to be a nxm-Matrix where
%             m is the dimensionality
% Output:
%   params    Parameterization

function [ params ] = centripetal( d )
a = 0.5;
t0 = 0;

count = size(d,1);
L = 0;
for i=2:1:count
    dist = pdist([d(i,:);d(i-1,:)],'euclidean')^a;
    L = L + dist;
end

params = zeros(count,1);
params(1) = t0;
tk = 0;
for i=2:1:count
    dist = pdist([d(i,:);d(i-1,:)],'euclidean')^a;
    tk = tk + dist;
    p = tk / L;
    params(i) = p;
end


end
