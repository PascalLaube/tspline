function [ cP ] = interpBSpl(k,u,p,d)

%ds = d;
tA = bspline_basismatrix(k,u,p);
A = zeros(size(d,2) + 2);
A(2:end-1,:) = tA;
A(1,1) = 1; A(2,1) = -1;
A(end,end) = 1; A(end-1, end) = -1;
A(2,2) = 1; A(end-1,end-1) = 1;
d = d';

%get tangent at the ends
t1 = d(2,:) - d(1,:);
t1 = t1/norm(t1);
t2 = d(end-1,:) - d(end,:);
t2 = t2/norm(t2);

d = [d(1,:); t1; d(2:end-1,:); t2; d(end,:)];

cP = linsolve(A,d)';
end

