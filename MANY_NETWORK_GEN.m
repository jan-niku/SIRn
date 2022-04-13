% network generator code

% TODO: how do we get metrics out?

% return status:
% -7: User wishes not to overwrite directory

function RETURN_STATUS = MANY_NETWORK_GEN(N, ...
    Kmin, Kmax, Kstep, beta, ...
    SAVEDIR, BASENAME, FMT, METDIR)

% check if we want to destroy a bunch of data
% if exist(SAVEDIR,'dir')
%     fig = uifigure;
%     sel = uiconfirm(fig,"Directory exists. Overwrite?",...
%         "warning","Icon","warning");
%     if sel ~= "OK"
%         RETURN_STATUS = -7;
%         return
%     end
% end

% create our K-array
karr = Kmin:Kstep:Kmax;
iters = length(karr);

progressbar('generating networks...')

for k=1:iters
    progressbar(k/iters) % gives some indication to user

    % generate small world model
    sm = WattsStrogatz(N, karr(k), beta);

    % create a sparse adj matrix
    sadj = adjacency(sm);

    % generate a filename
    kstring = sprintf('%04d',k);
    FILENAME = BASENAME+kstring+FMT;
    FILEPATH = SAVEDIR + FILENAME;

    METFILE = "metrics"+kstring; % it adds .txt for us
    METPATH = METDIR+METFILE;
    METPATH = convertStringsToChars(METPATH);
    exportMetricsFile(sm, 'Title', METPATH);

    % output to file
    writematrix(sadj,FILEPATH);

end

% weve done everything now
RETURN_STATUS=0;
return
end