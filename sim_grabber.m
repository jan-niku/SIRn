%% This function will grab time series from simulations
% it expects an array to be passed of the numbers you want
% and an array of the compartments you want output
% it returns a cell of outputs

function Series = sim_grabber(sim_first, sim_step, sim_last, ...
    compartments, SIRDIR)
    
    % Generate the simulation and compartments array
    simulation_numbers = sim_first:sim_step:sim_last;
    compartments = find(compartments); % grab idx of nonzero

    % build cell
    qty_simulations = length(simulation_numbers);
    qty_compartments = length(compartments);
    Series = cell(qty_compartments,1,qty_simulations);

    % iterate over files and populate
    for simnum=1:qty_simulations
        numpadded = sprintf('%04d',simulation_numbers(simnum));
        FILENAME = "sim"+numpadded+".txt";
        FILEPATH = SIRDIR+FILENAME;

        simulation = readmatrix(FILEPATH);

        for srs=1:qty_compartments
            % series row needs to be indexed by consecutive ints
            % but we do not have to pull consecutive series from simulation
            Series{srs,1,simnum} = simulation(compartments(srs),:);
        end
    end
end