%optimizer for r
%% This function will take in an array of I's from SIRc
%% and an array from SIRn, and will try out a range of r values
%% to minimize some cost function.
% the cost function we are trying is just the euclidean norm
% between the two peaks. Others should probably be tried
% like maybe just vertical distance, too

% problem:
% we are having index issues
% we are just trying to ignore everything before and including
% the last index where the max is right at the beginning
% you only get 57 out of this? There are over 300 simulations!
% then cc errors in polyfit, with len 257~ which sounds right
% why are we getting so few out here?!


function [bestrs, dists, percerrors, beginidx] = r_Optimizer(rarr, q, tin, U0, ...
    max_inf, max_inf_idx,num_parents)

% we dont want to fit where the disease just dies out immediately
nf = max_inf == num_parents;
beginidx = find(nf,1,'last')+1;

% quantify and cry for the lost time 
lost = max_inf_idx(1:beginidx) > 1;
tl = sum(lost);
disp("Discarding "+tl+" nontrivial simulations")

%rarr = rarr(beginidx:end);
max_inf_idx = max_inf_idx(beginidx:end);
max_inf = max_inf(beginidx:end);

inner_iters = length(rarr);
outer_iters = length(max_inf);

bestrs = zeros(1, outer_iters);
dists = zeros(1, outer_iters);
percerrors = zeros(1, outer_iters);

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
        U = U';
        [M,I]= max(U(2,:));
        pt = [I M]; % where our max is

        dist = norm(pt-opt);

        if dist <= mindist
            mindist = dist;
            bestr = r;
            best_est = M;
        end
    end
    bestrs(j) = bestr; 
    dists(j) = mindist;
    percerrors(j) = (best_est-opt(2))/opt(2); 
end

% we discard ones where the disease dies out right away
% bestrs = bestrs(beginidx:end);
% dists = dists(beginidx:end);
% percerrors = percerrors(beginidx:end);

end