% MANY NETWORK SIR
%% This code will generate a ton of simulations and save them
% it relies on the driver being pointed to a bunch of networks
% this code resolves a bug where the networked code occasionally reports
% infections starting at 0.

% in the future, this will be far cheaper to resolve by editing gmuric's 
% code, since the simulation can be terminated and restarted at the start
% rather than at the end.

function RETURN_STATUS = MANY_NETWORK_SIR(SAVEDIR, BASENAME, FMT, SIRDIR, ...
    N, r, p, max_iters, num_parents)

% grab a full list of the matching matrices we want to loop over
adjmats = dir(fullfile(SAVEDIR,BASENAME+"*"+FMT));
iters = length(adjmats);

for net=1:iters
    inf = [0]; % bug tracing, see note at top
    progressbar((net+iters)/(2*iters))

    % for reasons unknown, we sometimes report an infected array
    % that starts at 0. see note at top
    while inf(1) == 0
        parents = randi(N,1,num_parents);
        % load the matrix into a network
        curmat = adjmats(net).name; % grab the filename
        curmat = SAVEDIR+curmat; % point to the dir
        curnum = regexp(curmat,'\d*','Match'); % numbers for naming

        adjmat = readmatrix(curmat);

        % some additional parameters
        immunized = [];

        % pass to sir
        [inf,nisum,rec,infsum] = ...
            sir_simulation(adjmat,parents,p,immunized,r,max_iters);
    end

    % we need: rec, nisum, infsum, inf
    % these should be named like the network
    % and output in a single file in a new dir
    sirvecs = [inf; nisum; rec; infsum];
    SIRFILE = "sim"+curnum(1);
    SIMPATH = SIRDIR+SIRFILE;
    writematrix(sirvecs, SIMPATH);

end

end

