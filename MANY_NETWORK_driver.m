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
N=1500; % number of nodes
if ~(exist(SAVEDIR) & exist(METDIR) & exist(SIRDIR))
    %f = msgbox("Select a network directory");
    SAVEDIR = uigetdir + "/"; % folder where networks are saved
    %g = msgbox("Select a metric directory");
    METDIR = uigetdir + "/"; % place to keep metrics
    %h = msgbox("Select a simulation directory");
    SIRDIR = uigetdir + "/";
    BASENAME = "smallworld"; % the basename onto which k's are appended
    FMT = ".txt"; % the format of saving
end

% Network
Kmin=1; % minimum number of connections (over two)
Kmax=ceil(N/2); % maximum number of connections (over two)
Kstep=25;
karr = Kmin:Kstep:Kmax;
beta=0; % rewiring (use 0)

% SIR simulation
r = 0.03; % recovery
p = 0.0005; % infection prob
max_iters = 2000; % maximum iterations of simulation
parent_prop = 0.05; % proportion of network as parents
num_parents = ceil(N*parent_prop);
parents = randi(N,1,num_parents);

% Run SIRc to populate
S0 = N-length(parents);
I0 = length(parents);
R0 = 0;
[SIRc_tspan, SIRc_U] = SIRc_main([0 200], [S0 I0 R0], p, r);
SIRc_tspan = SIRc_tspan';
SIRc_U = SIRc_U';
% Plotting
% IT IS BEST NOT TO CHANGE THE FOLLOWING ARRAY
% UNLESS YOU WANT TO DEBUG MANY_SIM.._PLOT.m
compartments = [1, ... % infected
                1, ... % new infected
                1, ... % recovered
                1];    % cumulative infected
GIFNAME = "test.gif";

%% Runtime
answer = questdlg('Do you want to generate networks?', ...
    'Runtime', ...
    'Yes, and plot', ...
    'No, just plot', ...
    'No, just plot'); % default to not overwriting

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
            N, r, p, max_iters, parents)

        MANY_SIMULATION_PLOT(SIRDIR, compartments, GIFNAME, ...
            N, karr, SIRc_tspan, SIRc_U);

    case 'No, just plot'

        MANY_SIMULATION_PLOT(SIRDIR, compartments, GIFNAME, ...
            N, karr, SIRc_tspan, SIRc_U);
end