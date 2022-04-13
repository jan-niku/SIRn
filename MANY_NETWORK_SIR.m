% MANY NETWORK SIR

function RETURN_STATUS = MANY_NETWORK_SIR(SAVEDIR, BASENAME, FMT, SIRDIR, ...
    N, r, p, max_iters, parents)

% grab a full list of the matching matrices we want to loop over
adjmats = dir(fullfile(SAVEDIR,BASENAME+"*"+FMT));
iters = length(adjmats);

for net=1:iters
    progressbar((net+iters)/(2*iters))

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

    % we need: rec, nisum, infsum, inf
    % these should be named like the network
    % and output in a single file in a new dir
    sirvecs = [inf; nisum; rec; infsum];
    SIRFILE = "sim"+curnum;
    SIMPATH = SIRDIR+SIRFILE;
    writematrix(sirvecs, SIMPATH);

end

end

