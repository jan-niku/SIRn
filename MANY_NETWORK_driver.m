%% Allows a user to generate many small world networks 
% and then simulate SIR on all of these networks.
% will save useful metrics and simulation outcomes as text.
% optionally will run compartmental sir (?).

% TODO: you can probably get away with saving a lot of 
%       the initial matrices as sparse, although it may not
%       make it faster. Give it a go, maybe.

%       probably need to add re-simulations just in case

%       some kind of tool for comparing to sirc?

%% Parameters
% Global
N=1000; % number of nodes
% ask about directiories
msg = "How should we handle saving? (if generating networks)";
opts = ["Use Environment Variables for Paths (deletes old simulation)" ...
    "Set Directories (I don't want to delete anything)" ...
    "I just want to plot"];
choice = menu(msg,opts);

switch choice
    case 2
        SAVEDIR = uigetdir + "\"; % folder where networks are saved
        METDIR = uigetdir + "\"; % place to keep metrics
        SIRDIR = uigetdir + "\";
        BASENAME = "smallworld"; % the basename onto which k's are appended
        FMT = ".txt"; % the format of saving

        answer = questdlg('Do you want to generate networks?', ...
            'Runtime', ...
            'Yes, and plot', ...
            'No, just plot', ...
            'No, just plot'); % default to not overwriting


    case 1
        answer = questdlg('Do you want to generate networks?', ...
            'Runtime', ...
            'Yes, and plot', ...
            'No, just plot', ...
            'No, just plot'); % default to not overwriting


    case 3
        answer = 'No, just plot';
end

% Network
Kmin=floor(log(N)); % minimum number of connections (over two)
Kmax=ceil(N/2)+1; % maximum number of connections (over two)
Kstep=5;
karr = Kmin:Kstep:Kmax;
beta=.25; % rewiring (use 0)

% SIR simulation
q = 0.083; % recovery
r = 0.0004; % infection prob
max_iters = 2000; % maximum iterations of simulation
parent_prop = 0.005; % proportion of network as parents
num_parents = ceil(N*parent_prop);
parents = randi(N,1,num_parents);

% Run SIRc to populate
S0 = N-length(parents);
I0 = length(parents);
R0 = 0;
U0 = [S0 I0 R0];
tin = [0 200];
[SIRc_tspan, SIRc_U] = SIRc_main(tin, U0, r, q);
SIRc_tspan = SIRc_tspan';
SIRc_U = SIRc_U';
% Plotting
% IT IS BEST NOT TO CHANGE THE FOLLOWING ARRAY
% UNLESS YOU WANT TO DEBUG MANY_SIM.._PLOT.m
compartments = [1, ... % infected
                1, ... % new infected
                1, ... % recovered
                1];    % cumulative infected
GIFNAME = "convergence.gif";


%% Runtime

switch answer
    case 'Yes, and plot'
        % clear all old files
        delete(SIRDIR + "*txt");
        delete(SAVEDIR + "*" + FMT);
        delete(METDIR + "*txt");

        progressbar('generating networks...')
        MANY_NETWORK_GEN(N, ...
            Kmin, Kmax, Kstep, beta, ...
            SAVEDIR, BASENAME, FMT, METDIR);

        progressbar('running sir...')
        MANY_NETWORK_SIR(SAVEDIR, BASENAME, FMT, SIRDIR, ...
            N, q, r, max_iters, parents)

        MANY_SIMULATION_PLOT(SIRDIR, compartments, GIFNAME, ...
            N, karr, SIRc_tspan, SIRc_U);

    case 'No, just plot'

        MANY_SIMULATION_PLOT(SIRDIR, compartments, GIFNAME, ...
            N, karr, SIRc_tspan, SIRc_U, ...
            U0, q, r, tin, METDIR);
end