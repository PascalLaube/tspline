%Testfile computing an example approximation

deg = 2;
sampleCountU = 200;
sampleCountV = 10;

%Boundary curve 1 
pnts = [ 0.0  3.0  4.5  6.5 8.0 10.0; 
         0.0  0.0  0.0  0.0 0.0  0.0;  
         2.0  2.0  7.0  4.0 7.0  9.0];    
crv1 = nrbmak(pnts, [0 0 0 1/3 0.5 2/3 1 1 1]); 
 
% Boundary curve 2 
pnts= [ 0.0  3.0  5.0  8.0 10.0; 
        10.0 10.0 10.0 10.0 10.0; 
        3.0  5.0  8.0  6.0 10.0]; 
crv2 = nrbmak(pnts, [0 0 0 1/3 2/3 1 1 1]); 
 
% Boundary curve 3 
pnts= [ 0.0 0.0 0.0 0.0; 
        0.0 3.0 8.0 10.0; 
        2.0 0.0 5.0 3.0]; 
crv3 = nrbmak(pnts, [0 0 0 0.5 1 1 1]); 
 
% Boundary curve 4 
pnts= [ 10.0 10.0 10.0 10.0 10.0; 
        0.0   3.0  5.0  8.0 10.0; 
        9.0   7.0  7.0 10.0 10.0]; 
crv4 = nrbmak(pnts, [0 0 0 0.25 0.75 1 1 1]); 
 
srf = nrbcoons(crv1, crv2, crv3, crv4); 

knotsU = cell2mat(srf.knots(1));
knotsV = cell2mat(srf.knots(2));
orderU = srf.order(1);
orderV = srf.order(2);

tU = linspace(knotsU(1),knotsU(end),sampleCountU);
tV = linspace(knotsV(1),knotsV(end),sampleCountV);

valuesX = spcol(knotsU,orderU,tU)*squeeze(srf.coefs(1,:,:))*...
    spcol(knotsV,orderV,tV).';
valuesY = spcol(knotsU,orderU,tU)*squeeze(srf.coefs(2,:,:))*...
    spcol(knotsV,orderV,tV).';
valuesZ = spcol(knotsU,orderU,tU)*squeeze(srf.coefs(3,:,:))*...
    spcol(knotsV,orderV,tV).';

pArr=cell(size(valuesX,2),1);
bSplArr = cell(size(valuesX,2),1);
knotsUArr = cell(size(valuesX,2),1);
for i=1:size(valuesX,2)
    points(1,:) = valuesX(:,i)';
    points(2,:) = valuesY(:,i)';
    points(3,:) = valuesZ(:,i)';
    pArr{i} = points;
    
    %Get Params
    params = centripetal(points')';
    SKTPKnots = pigltill(params, 4, 10);

    SKTPKnots = sort(SKTPKnots);
    aprSplSKTPCoefs = bspline_approx(4,SKTPKnots,params,points);
    %plot3(aprSplSKTPCoefs(1,:), aprSplSKTPCoefs(2,:), aprSplSKTPCoefs(3,:),'m-');
    aprBSpl.coefs = aprSplSKTPCoefs;
    aprBSpl.order = 4;
    aprBSpl.params = params;
    aprBSpl.knots = SKTPKnots;
    bSplArr{i} = aprBSpl;
    knotsUArr{i} = SKTPKnots;
    aSplSKTP =  bspline_deboor(4,SKTPKnots,aprSplSKTPCoefs,params)';
    %plot3(aSplSKTP(:,1), aSplSKTP(:,2), aSplSKTP(:,3),'b-');
end

%approx
[cP v] = tSplineApprox( pArr', bSplArr', knotsUArr', 4);
t = tSpline([],3);
t.skinnedTSpline(cP, v, knotsUArr);
