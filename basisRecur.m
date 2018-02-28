%basisRecur: Eval B-Spline Basis functions
%Input:    
%   x           eval parameter
%   knots       B-Spline knots
%   deg         B-Spline degree
%   knotspan    knotspan for evaluation
%Output:
%   N           eval value

function [ N ] = basisRecur( x, knots, deg, knotspan )

if deg == 0
    if x >= knots(knotspan) && ...
       x < knots(knotspan+1)
        N = 1;
    else
        N = 0;
    end
else

    a=0;
    b=0;
    ad = knots(knotspan+deg)-knots(knotspan);
    if ad ~= 0
        a = ((x-knots(knotspan))/ad) * ...
            basisRecur(x,knots,deg-1,knotspan);
    end

    bd = knots(knotspan+deg+1)-knots(knotspan+1);
    if bd ~= 0
      b = ((knots(knotspan+deg+1)-x)/bd) * ...
          basisRecur(x,knots,deg-1,knotspan+1);
    end

    N = a+b;
end
end