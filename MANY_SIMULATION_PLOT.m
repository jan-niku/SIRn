% Experimental code for plotting many simulations at once

%% Parameters
% Global 
SIRDIR = uigetdir;
SIRDIR = SIRDIR + "/";

% Grabbing
sim_first = 1;
sim_last = 20;
sim_step = 1;
compartments = [1, ... % infected
                0, ... % new infected
                0, ... % recovered
                0];    % cumulative infected

% Generate the simulation and compartments array
simulation_numbers = sim_first:sim_step:sim_last;
compartments = find(compartments); % grab idx of nonzero

Series = sim_grabber(simulation_numbers, compartments, SIRDIR);

   