% a better optimizer for r
% something like descent
%% This function will take in an array of I's from SIRc
%% and an array from SIRn, and will try out a range of r values
%% to minimize some cost function.
% the cost function we are trying is just the euclidean norm
% between the two peaks. Others should probably be tried
% like maybe just vertical distance, too

function [bestrs, dists] = r_Optimizer2(r, q, tin, U0, ...
    max_inf, max_inf_idx)

% we need to do this process for outer_iters many network simulations
% each one will have its own best r
% and its own best distance
% we need arrays to hold these, too
outer_iters = length(max_inf);
bestrs = zeros(1, outer_iters);
dists = zeros(1, outer_iters);

progressbar('Optimizing r...')
for i=15:outer_iters % for each network simulation
    progressbar(i/outer_iters)

    % this its the point which we are trying to reach
    opt = [max_inf_idx(i) max_inf(i)];

    % we have a starting distance
    % this should be big, it means our first step is conservative
    dist = 500;
    deltadist=10;

    % we start with a very close guess
    rcurr = r*.999;

    while deltadist > 1e-5

        % save the old distance and r
        rold = rcurr;
        distold = dist;

        % run SIRc with current r
        [t,U]=SIRc_main(tin,U0,rcurr,q);
        U=U'; % transpose
        t=t';

        % get the maximum point in SIRc
        [M I] = max(U(2,:));

        % the coordinates are reversed
        maxpt = [I M];

        % get the distance between the two points.
        dist = norm(maxpt-opt);
        deltadist=abs(dist-distold);

        % use this to make the multiplier
        % and get a new r
        rrat = dist/distold;
        rcurr = rcurr*rrat;

    end







end




end
