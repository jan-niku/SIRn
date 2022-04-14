% Experimental code for plotting many simulations at once

function ret = MANY_SIMULATION_PLOT(SIRDIR, ...
    compartments, GIFNAME, N, karr, t, U)

% get the series
sim_first = 1;
sim_step = 1;
sim_last = length(karr);
Series = sim_grabber(sim_first, sim_step, sim_last, ...
    compartments, SIRDIR);
[comps, ~, sers] = size(Series); % cols, the middle, always 1

% populate infected arrays
max_inf = zeros(1,sers);
max_inf_idx = zeros(1,sers);
for idx=1:sers
    inf = Series{1,1,idx};
    [run_max, run_idx] = max(inf);
    max_inf(idx) = run_max;
    max_inf_idx(idx) = run_idx;
end
SIRc_max_inf = max(U(2,:));

% populate new infected arrays
max_new_inf = zeros(1,sers);
max_new_inf_idx = zeros(1,sers);
for idx=1:sers
    newinf = Series{2,1,idx};
    [run_max, run_idx] = max(newinf);
    max_new_inf(idx) = run_max;
    max_new_inf_idx(idx) = run_idx;
end

% inputs are the wrong dimension
U = U';
t = t';

answer = questdlg('What do you want to plot?', ...
    'Plot Dialog', ...
    'K vs. Maximum New Infections', ...
    'K vs. Iteration of Max New Infections', ...
    'Network Max Infections vs. SIRc Max Infections', ...
    'gif test', ...
    'K vs. Iteration of Max New Infections');

switch answer
    case 'K vs. Maximum New Infections'
        plot(karr,max_new_inf)
        title('K value vs. Maximum New Infections')
        subtitle("N="+N)
        xlim([0 max(karr)])
        xlabel("K-value")
        ylabel("Maximum New Infections")
        
    case 'K vs. Iteration of Max New Infections'
        plot(karr,max_new_inf_idx)
        title('K vs. Iteration of Max New Infections')
        subtitle("N="+N)
        xlim([0 max(karr)])
        xlabel("K-value")
        ylabel("Index of Maximum Infection")

    case 'Network Max Infections vs. SIRc Max Infections'
        plot(karr, max_inf)
        xlim([0 max(karr)])
        ylim([0 SIRc_max_inf*1.2])
        yline(SIRc_max_inf,'-','Compartmental Maximum','LineWidth',3)
        title("K vs. Maximum Infected")
        subtitle("N="+N);
        xlabel("K-value")
        ylabel("Maximum Infected")

    case 'gif test'
        

end

