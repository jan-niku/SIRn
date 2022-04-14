% This is the odefn for compartmental SIIR
% This file is used in SIIRc_main.m

function dUdt = SIRc(t,U,r,a)
    dUdt = zeros(3,1);
    dUdt(1) = -r*U(1)*U(2); % S
    dUdt(2) = r*U(1)*U(2) - a*U(2); % I1
    dUdt(3) = a*U(2);
end