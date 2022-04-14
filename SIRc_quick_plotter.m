% SIRc many
%% This function will return a cell of infection arrays
% these will be time series infections from varying r in a sir simulation

function [t, max_I, max_I_iter] = MANY_SIRc_GEN(tarr, U0, p, r)



[t,U] = SIRc_main([0 200], [S0 I0 R0], p, r);
t = t';
U = U'; 


