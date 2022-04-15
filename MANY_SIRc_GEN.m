% SIRc many
%% This function will return a cell of infection arrays
% these will be time series infections from varying r in a sir simulation

function [tarr, max_I, max_I_idx, Is, iters] = MANY_SIRc_GEN(tin, U0,...
q, rmin, rstep, rmax)

rarr = rmin:rstep:rmax;
iters = length(rarr);
tarr = cell(1,tin(2),iters);
max_I = zeros(1,iters);
max_I_idx = zeros(1,iters);
Is = cell(1,1,iters);

for i=1:iters
    progressbar(i/iters)
    [t,U] = SIRc_main(tin, U0, rarr(i),q);
    t = t';
    U = U';

    [runmax, runmaxidx] = max(U(2,:));
    max_I(i) = runmax;
    max_I_idx(i) = runmaxidx;
    tarr{i} = t;
    Is{i} = U(2,:);
end



