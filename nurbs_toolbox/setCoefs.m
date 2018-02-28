function [ srf ] = setCoefs(direction, row, srf, coefs)
%Sets the coefficients of a row index (row) in: 
% direction = 1 => U direction
% direction = 2 => V direction
% This is for surfaces (srf) of nurbs toolbox

if direction == 1
    temp = srf.coefs(1,:,row);
    srf.coefs(1,:,row) = coefs(1,:);
    srf.coefs(2,:,row) = coefs(1,:);
    srf.coefs(3,:,row) = coefs(1,:);
end

if direction == 2
    srf.coefs(1,row,:) = coefs(1,:);
    srf.coefs(2,row,:) = coefs(2,:);
    srf.coefs(3,row,:) = coefs(3,:);
end

end