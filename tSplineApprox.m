function [ cP, v, knotsQu ] = tSplineApprox( pij, splineCurves, knotsU, orderV)
%This approximation is based on "Approximate T-spline surface skinning" by Xunnian Yang

%Get knot vector v for interpolation
v(1) = 0;
for j=2:size(pij,1)
    pj   =  pij{j};
    pjm1 =  pij{j-1};

    v(j) = v(j-1) + (norm(pj(:,1)-pjm1(:,1)) ...
        + norm(pj(:,end)-pjm1(:,end)))/2;
end

for i=1:orderV-1
    v = [v(1) v v(end)];
end

n = size(pij,1)-1;

%Build M
M = zeros(n+3,n+3);
a = zeros(1,n+3);
b = zeros(1,n+3);
c = zeros(1,n+3);


for j=3:n+1
a(j) = basisRecur(v(orderV+j-2), v, 3, j-1);
b(j) = basisRecur(v(orderV+j-2), v, 3, j);
c(j) = basisRecur(v(orderV+j-2), v, 3, j+1);
end
b(1) = 1; b(n+3) = 1; c(1) = 0;
a(2) = 0;
c(2) = -((v(1+orderV)-v(orderV))/(v(2+orderV)-v(orderV)));
b(2) = 1-c(2);
a(n+2) = -((v(n+orderV)-v(n+orderV-1))/(v(n+orderV)-v(n+orderV-2)));
b(n+2) = 1-a(n+2); 
c(n+2) = 0;
a(n+3) = 0;

M(1,1) = b(1); M(1,2) =c(1);
M(2,1) = a(2); M(2,2) = b(2); M(2,3) = c(2);
for j=3:n+1
    M(j,j-1) = a(j);
    M(j,j) = b(j);
    M(j,j+1) = c(j);
end
M(n+2,n+1) = a(n+2);
M(n+2,n+2) = b(n+2);
M(n+2,n+3) = c(n+2);
M(n+3,n+2) = a(n+3);
M(n+3,n+3) = b(n+3);

%[~,p] = chol(M);

%beta
MBetaInv = zeros(n+3);
beta = [b(1)];
alpha = [0];
MBetaInv(1,1) = 1/beta(1);
for i=2:n+3
    alpha(i) = a(i)/beta(i-1);
    beta(i) = b(i)-alpha(i)*c(i-1);
    MBetaInv(i,i) = 1/beta(i);
end

%alpha
MAlphaInv = eye(n+3);
MAlphaInv(1,1) = 1;
for i=2:n+3
    for j=1:n+2
        g = 1;
        for l=j+1:i
            g = g*(-alpha(l));
            MAlphaInv(i,j) = g;
        end
    end
end

%gamma
gamma = [];
for i=1:n+2
    gamma(i) = c(i)/beta(i);
end

MGammaInv = eye(n+3);
MGammaInv(end,end) = 1;
for i=1:n+2
    for j=2:n+3
        r = 1;
        for l=i:j-1
            r = r*(-gamma(l));
            MGammaInv(i,j) = r;
        end
    end
end

iM = MGammaInv*MBetaInv*MAlphaInv;

% %Build C
C = zeros(size(iM,1),size(iM,2)-2);
C(:,2:end-1) = iM(:,3:end-2);
for i=1:size(iM,1)
    C(i,1) = iM(i,1) + iM(i,2);
    C(i,end) = iM(i,end-1) + iM(i,end);
end

Q = cell(1);
knotsQu = cell(1);
knotsQu{1} = knotsU{1};
for i=2:size(knotsU,1)+1
    knotsQu{i} = knotsU{i-1};
end
knotsQu{size(knotsU,1)+2} = knotsU{end};


for j=1:size(C,1)
    c = [];
    for i=1:size(knotsQu{j},2)
        sumP = 0;
        for l=1:size(splineCurves,1)
            P = bspline_deboor(4,splineCurves{l}.knots,splineCurves{l}.coefs,knotsQu{j}(i));
            sumP = sumP + (C(j,l)*P);
        end
        c = [c sumP];
    end
    Q{j} = c;
end

ord = splineCurves{1}.order;
%interpolate for qtilde
cP = cell(1);
for i=1:size(Q,2)
    par = knotsQu{i}(ord:(end-ord+1));
    Qi = Q{i}(:,ord:(end-ord+1));
    cps = interpBSpl(ord, knotsQu{i}, par, Qi);
    %these additional control points are only needed to build the t-mesh
    %(code refactor?) 
    cps = [cps(:,1) cps(:,1) cps cps(:,end) cps(:,end)];
    cP{i} = cps;
end

end

