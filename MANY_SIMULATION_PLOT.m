% Experimental code for plotting many simulations at once

function ret = MANY_SIMULATION_PLOT(SIRDIR, ...
    compartments, GIFNAME, N, karr, t, U, ...
    U0, q, r, tin, METDIR)

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

% We need some stuff for 5 and 6 into SIRc for r-optimizing
rmin=r/1000;
rstep=r/1000;
rmax=r;
rarr=rmin:rstep:rmax;

% grab the metrics
metrics = readmatrix(METDIR+"metrics.txt");

%% Menu
msg = "What do you want to plot?";
opts = ["K vs. Maximum New Infections" ...
    "K vs. Iteration of Max New Infections" ...
    "Network Max Infections vs. SIRc Max Infections" ...
    "(Animated) Network Converge to Fully Connected" ...
    "(Animated) Reverse Convergence Gif" ...
    "Clustering Coefficient vs. r-Compensation" ...
    "Plot A Simulation by Clustering Coefficient"];

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
        yline(SIRc_max_inf,'-','Fully Connected Maximum','LineWidth',3)
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
        title("Infected; Fully Connected vs. Networked")
        subtitle("K proportion: " + kprop(1))
        xlabel("Time")
        ylabel("Infected")
        legend("Network", "Fully Connected")
        xlim([0 100])
        ylim([0 N])
        gif('convergence.gif','overwrite',true)
        for idx=2:sers
            plot(Series{1,1,idx})
            hold on
            plot(t+1,U(2,:))
            hold off
            title("Infected; Fully Connected vs. Networked")
            subtitle("K proportion: " + kprop(idx))
            xlabel("Time")
            ylabel("Infected")
            legend("Network", "Fully Connected")
            xlim([0 100])
            ylim([0 N])
            gif
        end

    case 5
        progressbar('Generating SIRc Outcomes')
        [tarr, max_I, max_I_idx, Is, iters] = MANY_SIRc_GEN(tin, U0, ...
            q, rmin, rstep, rmax);
        plot(tarr{1}, Is{1})
        hold on
        plot(Series{1,1,ceil(sers*.65)})
        hold off
        ylim([0 N])
        xlim([0 75])
        title("Adjusting r to fit networked model")
        rcompstr = sprintf('%01.04f',rarr(1)/r);
        subtitle("r Compensation: "+rcompstr);
        xlabel("Time")
        ylabel("Infected")
        legend("Network Model", "Fully Connected Model")
        gif('delete.gif','overwrite',true)
        for idx=1:iters
            plot(tarr{idx},Is{idx})
            hold on
            % ceil sers*.65 means
            % grab about 65% of the way into the series
            plot(Series{1,1,ceil(sers*.65)})
            hold off
            ylim([0 N])
            xlim([0 75])
            title("Adjusting r to fit networked model")
            rcompstr = sprintf('%01.04f',rarr(idx)/r);
            subtitle("r Compensation: "+rcompstr);
            xlabel("Time")
            ylabel("Infected")
            legend("Fully Connected Model", "Network Model")
            gif
        end

    case 6
        msg = "Do you want to re-optimize?";
        opts = ["No, load from file" ...
            "Yes, reoptimize"];
        choice = menu(msg,opts);

        switch choice
            case 1
                outcomes = readmatrix(METDIR+"opt_metrics.txt");
                bestrs = outcomes(1,:);
                dists = outcomes(2,:);
                percerrors = outcomes(3,:);
                rcomp = outcomes(4,:);
                scatter(metrics(1,:),rcomp,50,percerrors,'filled')
                colormap('turbo')
                colorbar
                title("r-Compensation vs. Cluster Coefficient")
                subtitle("Coloring by Percent Error of Best Peak Approximation")
                xlabel("Clustering Coefficient of Network")
                ylabel("Compensation Factor for Best Approximation")
                exportgraphics(gcf,"r-optimization.png")

            case 2
                [bestrs, dists, percerrors] = r_Optimizer(rarr, q, tin, U0, ...
                    max_inf, max_inf_idx);
                rcomp = bestrs/r;
                outopt = [bestrs; dists; percerrors; rcomp];
                writematrix(outopt,METDIR+"opt_metrics.txt")
                scatter(metrics(1,:),rcomp,50,percerrors,'filled')
                colormap('turbo')
                colorbar
                title("r-Compensation vs. Cluster Coefficient")
                subtitle("Coloring by Percent Error of Best Peak Approximation")
                xlabel("Clustering Coefficient of Network")
                ylabel("Compensation Factor for Best Approximation")
                exportgraphics(gcf,"r-optimization.png")
        end

    case 7
        outcomes = readmatrix(METDIR+"opt_metrics.txt");
        bestrs = outcomes(1,:);
        dists = outcomes(2,:);
        percerrors = outcomes(3,:);
        rcomp = outcomes(4,:);
        prompt = {'Whats the value, approximately?'};
        answ = inputdlg(prompt);
        [net_sim, idx] = net_finder(str2num(answ{1}), metrics, Series);
        plot(net_sim)
        xlim([0 125])
        hold on
        rn = bestrs(idx);
        [t,U] = SIRc_main(tin, U0, rn, q);
        plot(t+1,U(:,2))
        title("Network Simulation")
        subtitle("K value: " + karr(idx));
        xlabel("Time")
        ylabel("Infections")
        legend("Network", "Fully Connected")
end


