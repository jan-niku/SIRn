% network generator code

% return status:
% -7: User wishes not to overwrite directory

function karr = MANY_NETWORK_GEN(N, ...
    Kmin, Kmax, Kstep, beta, ...
    SAVEDIR, BASENAME, FMT, METDIR)


% create our K-array
karr = Kmin:Kstep:Kmax;
iters = length(karr);

% array to hold metrics
METRICS = zeros(2,iters);
METFILE = METDIR+"metrics.txt";

for k=1:iters
    progressbar(k/(iters*2)) % gives some indication to user

    % generate small world model
    sm = WattsStrogatz(N, karr(k), beta);

    % create a sparse adj matrix
    sadj = adjacency(sm);

    % generate a filename
    kstring = sprintf('%04d',k);
    FILENAME = BASENAME+kstring+FMT;
    FILEPATH = SAVEDIR + FILENAME;

    %METFILE = "metrics"+kstring; % it adds .txt for us
    %METPATH = METDIR+METFILE;
    %METPATH = convertStringsToChars(METPATH);
    %exportMetricsFile(sm, 'Title', METPATH);
    mt = getGraphMetrics(sm);
    METRICS(1,k) = mt.avgClustering;
    METRICS(2,k) = mt.avgPathLength;

    % output to file
    writematrix(sadj,FILEPATH);

end
writematrix(METRICS, METFILE);
% weve done everything now
return
end