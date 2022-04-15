% Experimental code for plotting many simulations at once

function ret = MANY_SIMULATION_PLOT(SIRDIR, ...
    compartments, GIFNAME, N, karr, t, U, ...
    U0, q, r, tin)

% get the series
sim_first = 1;
sim_step = 1;
sim_last = length(karr);
Series = sim_grabber(sim_first, sim_step, sim_last, ...
    compartments, SIRDIR);
[comps, ~, sers] = size(Series); % cols, the middle, always 1

% inputs are the wrong dimension
%U = U';
%t = t';

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

%% Menu
msg = "What do you want to plot?";
opts = ["K vs. Maximum New Infections" ...
        "K vs. Iteration of Max New Infections" ...
        "Network Max Infections vs. SIRc Max Infections" ...
        "(Animated) Network Converge to Compartmental" ...
        "(Animated) Reverse Convergence Gif" ...
        "Clustering Coefficient vs. r-Compensation"];
        
choice = menu(msg,opts);

switch choice
    case 1
        plot(karr,max_new_inf)
        title('K value vs. Maximum New Infections')
        subtitle("N="+N)
        xlim([0 max(karr)])
        xlabel("K-value")
        ylabel("Maximum New Infections")
        
    case 2
        plot(karr,max_new_inf_idx)
        title('K vs. Iteration of Max New Infections')
        subtitle("N="+N)
        xlim([0 max(karr)])
        xlabel("K-value")
        ylabel("Index of Maximum Infection")

    case 3
        plot(karr, max_inf)
        xlim([0 max(karr)])
        ylim([0 SIRc_max_inf*1.2])
        yline(SIRc_max_inf,'-','Compartmental Maximum','LineWidth',3)
        title("K vs. Maximum Infected")
        subtitle("N="+N);
        xlabel("K-value")
        ylabel("Maximum Infected")

    case 4
        kprop = karr/N; % K as a proportion of N
        plot(Series{1,1,1})
        hold on
        plot(t+1,U(2,:))
        hold off
        title("Infected; Compartmental vs. Networked")
        subtitle("K proportion: " + kprop(1))
        xlabel("Time")
        ylabel("Infected")
        xlim([0 200])
        ylim([0 N])
        gif('convergence.gif','overwrite',true)
        for idx=2:sers
            plot(Series{1,1,idx})
            hold on
            plot(t+1,U(2,:))
            hold off
            title("Infected; Compartmental vs. Networked")
            subtitle("K proportion: " + kprop(idx))
            xlabel("Time")
            ylabel("Infected")
            xlim([0 200])
            ylim([0 N])
            gif
        end

    case 5
        rmin = r/50;
        rstep=r/200;
        rmax=r;
       progressbar('Generating SIRc Outcomes')
        [tarr, max_I, max_I_idx, Is, iters] = MANY_SIRc_GEN(tin, U0, ...
            q, rmin, rstep, rmax);
        plot(tarr{1}, Is{1})
        hold on
        plot(Series{1,1,sers*.65})
        hold off
        ylim([0 N])
        xlim([0 50])
        gif('delete.gif','overwrite',true)
        for idx=1:iters
            plot(tarr{idx},Is{idx})
            hold on
            plot(Series{1,1,sers*.65})
            hold off
            ylim([0 N])
            xlim([0 200])
            gif
        end
end

