%% Allows a user to generate many small world networks
% and then simulate SIR on all of these networks.
% will save useful metrics and simulation outcomes as text.

% You will be asked, at some point, to pick 3 directories.
% The first stores all of your generated networks
% The second stores a single network metrics file
% The third stores all of the simulation outputs

%% Parameters
% just in case we are doing a lot of testing
% lets allow these to be set in code
% Global

% our large, hacky container
sirc = struct;

% KEY PARAMETERS
% number of nodes
sirc.N = 1500;
Kstep = 20;
sirc.q = 0.083; % recovery
sirc.r = 0.0004; % infection prob

% Network
Kmin=floor(log(sirc.N)); % minimum number of connections (over two)
Kmax=ceil(sirc.N-1)/2; % maximum number of connections (over two)
sirc.karr = Kmin:Kstep:Kmax;
sirc.beta=.25; % rewiring (use 0)

% SIR simulation
sirc.max_iters = 2000; % maximum iterations of simulation
sirc.parent_prop = 0.03; % proportion of network as parents
sirc.num_parents = ceil(sirc.N*sirc.parent_prop);
sirc.parents = randi(sirc.N,1,sirc.num_parents);

% Run SIRc to populate
S0 = sirc.N-length(sirc.parents);
I0 = length(sirc.parents);
R0 = 0;
sirc.U0 = [S0 I0 R0];
sirc.tin = [0 200];
[SIRc_tspan, SIRc_U] = SIRc_main(sirc.tin, sirc.U0, sirc.r, sirc.q);
sirc.tspan = SIRc_tspan';
SIRc_U = SIRc_U';
sirc.U1 = SIRc_U(1,:)';
sirc.U2 = SIRc_U(2,:)';
sirc.U3 = SIRc_U(3,:)';

%% User Interface
msg = "What do you want to do?";
opts = ["Use environmental variables for paths and regenerate networks" ...
    "Set path variables (and then decide whether to regenerate)" ...
    "I just want to plot"];
%    "Set some global model parameters(N, r, etc...)"];
choice = menu(msg,opts);

switch choice
    case 2
        SAVEDIR = uigetdir('./', "Select network directory") + "\"; % folder where networks are saved
        METDIR = uigetdir('./', "Select metric directory") + "\"; % place to keep metrics
        SIRDIR = uigetdir('./', "Select simulation directory") + "\";
        BASENAME = "smallworld"; % the basename onto which k's are appended
        FMT = ".txt"; % the format of saving

        answer = questdlg('Are you sure you want to generate networks?', ...
            'Runtime', ...
            'Yes, write and plot', ...
            'No, just plot', ...
            'No, just plot'); % default to not overwriting


    case 1
        answer = questdlg('Are you sure you want to generate networks?', ...
            'Runtime', ...
            'Yes, write and plot', ...
            'No, just plot', ...
            'No, just plot'); % default to not overwriting


    case 3
        answer = 'No, just plot';

        %    case 4
        %        disp('TODO')
end

switch answer
    case 'Yes, write and plot'
        % clear all old files
        delete(SIRDIR + "*txt");
        delete(SAVEDIR + "*" + FMT);
        delete(METDIR + "*txt");

        progressbar('generating networks...')
        MANY_NETWORK_GEN(sirc.N, ...
            Kmin, Kmax, Kstep, sirc.beta, ...
            SAVEDIR, BASENAME, FMT, METDIR);

        progressbar('running sir...')
        MANY_NETWORK_SIR(SAVEDIR, BASENAME, FMT, SIRDIR, ...
            sirc.N, sirc.q, sirc.r, sirc.max_iters, sirc.num_parents)

        writestruct(sirc, SIRDIR+"params.xml");

    case 'No, just plot'
        sirc = readstruct(SIRDIR+"params.xml");
end

% MANY_SIMULATION_PLOT(SIRDIR, compartments, GIFNAME, ...
%     N, karr, SIRc_tspan, SIRc_U, ...
%     U0, q, r, tin, METDIR,beta,num_parents);

if ~exist("Series")
    numsim = dir(SIRDIR+"*.txt");
    numsim = length(numsim);
    Series = sim_grabber(numsim, ...
        [1 1 1 1], SIRDIR);
end

MANY_SIMULATION_PLOT(SIRDIR, [1 1 1 1], ...
    METDIR,sirc,Series,numsim);