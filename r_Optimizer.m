%optimizer for r
%% This function will take in an array of I's from SIRc
%% and an array from SIRn, and will try out a range of r values
%% to minimize some cost function.
% the cost function we are trying is just the euclidean norm
% between the two peaks. Others should probably be tried
% like maybe just vertical distance, too

function [bestrs, dists] = r_Optimizer(rarr, q, tin, U0, ...
    max_inf, max_inf_idx)

inner_iters = length(rarr);
outer_iters = length(max_inf);

bestrs = zeros(1, outer_iters);
dists = zeros(1, outer_iters);

progressbar('Optimizing r...')
for j=1:outer_iters
    progressbar(j/outer_iters)
    % this is the point we want to be closest to
    opt = [max_inf_idx(j) max_inf(j)];

    mindist = 10000;
    bestr = 0;

    for i=1:inner_iters
        r = rarr(i);
        [t,U] = SIRc_main(tin, U0, r, q);
        t = t';
        U = U';
        [M,I]= max(U(2,:));
        pt = [I M]; % where our max is

        dist = norm(pt-opt);
        %dist=abs(pt(1)-opt(1));
        if dist < mindist
            mindist = dist;
            bestr = r;
        end
    end

    bestrs(j) = bestr;
    dists(j) = dist;
end

end