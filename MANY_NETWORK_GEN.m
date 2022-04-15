% network generator code

% TODO: how do we get metrics out?

% return status:
% -7: User wishes not to overwrite directory

function karr = MANY_NETWORK_GEN(N, ...
    Kmin, Kmax, Kstep, beta, ...
    SAVEDIR, BASENAME, FMT, METDIR,...
    parents,q,r,immunized,max_iters, SIRDIR)


% create our K-array
karr = Kmin:Kstep:Kmax;
iters = length(karr);

% array to hold metrics
METRICS = zeros(2,iters);
METFILE = METDIR+"metrics.txt";

for k=1:iters
    progressbar(k/iters) % gives some indication to user

    % generate small world model
    sm = WattsStrogatz(N, karr(k), beta);

    % create a adj matrix
    sadj = adjacency(sm);
    kstring = sprintf('%04d',k);

    [inf,nisum,rec,infsum] = ...
        sir_simulation(sadj,parents,q,immunized,r,max_iters);
    sirvecs = [inf; nisum; rec; infsum];
    SIRFILE = "sim"+kstring+".txt"; % consider fwrite instead (for .bin)
    SIMPATH = SIRDIR+SIRFILE;
    writematrix(sirvecs, SIMPATH);

    % generate a filename
    mt = getGraphMetrics(sm);
    METRICS(1,k) = mt.avgClustering;
    METRICS(2,k) = mt.avgPathLength;

end
writematrix(METRICS, METFILE);
% weve done everything now
return
end