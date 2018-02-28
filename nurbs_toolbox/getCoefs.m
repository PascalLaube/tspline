function [ coefs ] = getCoefs(direction, row, srf)
%Gets the coefficients of a row index (row) in: 
% direction = 1 => U direction
% direction = 2 => V direction
% This is for surfaces (srf) of nurbs toolbox

if direction == 1
    coefs = [reshape(srf.coefs(1,:,row),[1,srf.number(1)]); ...
                reshape(srf.coefs(2,:,row),[1,srf.number(1)]); ...
                reshape(srf.coefs(3,:,row),[1,srf.number(1)])];
end

if direction == 2
    coefs = [reshape(srf.coefs(1,row,:),[1,srf.number(2)]); ...
                reshape(srf.coefs(2,row,:),[1,srf.number(2)]); ...
                reshape(srf.coefs(3,row,:),[1,srf.number(2)])];
end

end
