function [ N ] = basisFunTSpl( x, knots, deg, knotspan)
%Handle eval on sides: Because this t-spline implementation does not
%"close" the t-spline with extra knot intervals on the sides (in s and t),
%N automatically is set to 1 when evaluated at a border.
if x == knots(1)
    eq = true;
    for i=1:deg-1
        if knots(i) ~= knots(i+1)
            eq=false;
        end
    end
    if eq == true
        N=1;
        return;
    end
end
if x == knots(end)
    eq = true;
    for i=(size(knots,2)-deg+1):(size(knots,2)-1)
        if knots(i) ~= knots(i+1)
            eq=false;
        end
    end
    if eq == true
        N=1;
        return;
    end
end

N = basisRecur( x, knots, deg, knotspan);

end

