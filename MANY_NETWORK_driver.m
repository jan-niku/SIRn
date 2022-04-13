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
%f = msgbox("Select a network directory");
SAVEDIR = uigetdir + "/"; % folder where networks are saved
%g = msgbox("Select a metric directory");
METDIR = uigetdir + "/"; % place to keep metrics
%h = msgbox("Select a simulation directory");
SIRDIR = uigetdir + "/";
BASENAME = "smallworld"; % the basename onto which k's are appended
FMT = ".txt"; % the format of saving

% Network
Kmin=1; % minimum number of connections (over two)
Kmax=ceil(N/2); % maximum number of connections (over two)
Kstep=25;
beta=0; % rewiring (use 0)

% SIR simulation
r = 0.05; % recovery
p = 0.005; % infection prob
max_iters = 2000; % maximum iterations of simulation
parent_prop = 0.03; % proportion of network as parents

progressbar('generating networks...')
MANY_NETWORK_GEN(N, ...
    Kmin, Kmax, Kstep, beta, ...
    SAVEDIR, BASENAME, FMT, METDIR)

% Generate Parents
num_parents = ceil(N*parent_prop);
parents = randi(N,1,num_parents);

progressbar('running sir...')
MANY_NETWORK_SIR(SAVEDIR, BASENAME, FMT, SIRDIR, ...
    N, r, p, max_iters, parents)