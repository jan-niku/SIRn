%% This function will grab time series from simulations
% it expects an array to be passed of the numbers you want
% and an array of the compartments you want output
% it returns a cell of outputs

function Series = sim_grabber(numsim, ...
    compartments, SIRDIR)
    
    % Generate the simulation and compartments array
    compartments = find(compartments); % grab idx of nonzero

    % build cell
    qty_compartments = length(compartments);
    Series = cell(qty_compartments,1,numsim);

    % iterate over files and populate
    for sim=1:numsim
        numpadded = sprintf('%04d',sim);
        FILENAME = "sim"+numpadded+".txt";
        FILEPATH = SIRDIR+FILENAME;

        simulation = readmatrix(FILEPATH);
%        simulation(1,:) = simulation(1,:)+1; % fix an off by one error

        for srs=1:qty_compartments
            % series row needs to be indexed by consecutive ints
            % but we do not have to pull consecutive series from simulation
            Series{srs,1,sim} = simulation(compartments(srs),:);
        end
    end
end