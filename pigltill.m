function [ uP ] = pigltill( params, order, contrPCount)
%Averaging Knot placement from Pigl/Tiller

%Knots for order
uP = pigltillKnotPlace(params, order, contrPCount)';

end

function [ u ] = pigltillKnotPlace( params, order, contrPCount)
    k = size(params,2);
    u = zeros(contrPCount+order,1);
    for i=1:order
        u(i) = params(1);
        u(contrPCount+i) = params(end);
    end

    inc = k/contrPCount;
    low = 1;
    high = 1;
    d = 0;
    w = zeros(contrPCount,1);
    for i=1:contrPCount
        d = d+inc;
        high = floor(d+0.5);
        sum = 0;
        for j=low:high
            sum = sum + params(j);
        end
        w(i) = sum/(high-low+1);
        low = high+1;
    end

    
    for i=1:(contrPCount-order)
        sum = 0;
        for j=i:(i+order-2)
            sum = sum+w(j+1);
        end
        u(i+order) = sum/(order-1);
    end
end


