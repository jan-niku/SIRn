% Experimental code for plotting many simulations at once

function ret = MANY_SIMULATION_PLOT(SIRDIR, ...
    compartments, GIFNAME, N, karr, t, U, ...
    U0, q, r, tin, METDIR, beta)

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
    "Plot A Simulation by Clustering Coefficient" ...
    "Simple Network SIR"];

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
        title("Adjusting r to Fit Networked Model")
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
            title("Adjusting r to Fit Networked Model")
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
                scatter(metrics(1,:),rcomp,25,percerrors,'filled')
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
                scatter(metrics(1,:),rcomp,25,percerrors,'filled')
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

    case 8
        % generate a network simulation
        % 30,2,0.08,0.05,0.07 looks good
        ns = 30;
        ks = 2;
        beta = .08;
        r=0.05;
        q=0.07;

        parents = randi(ns,1,ceil(ns*.06));
        g = WattsStrogatz(ns,ks,beta);
        a = adjacency(g);
        [inf,nisum,rec,infsum,s_all] = sir_simulation(...
            a,parents,r,[],q,200); % note zall only holds inf
        stps = length(inf)*1.05;

        ii = length(parents);
        [t,U] = SIRc_main([0 200], [ns-ii ii 0] , r, q);
        U = U';
        t = t';
        up = max(U(2,:))*1.1;

        % coloring
        % we need a couple of columns of zeros
        rs = zeros(ns,2);
        nstep = size(s_all,1);
        colors = [];
        for idx=1:nstep
            colors(:,:,idx) = [s_all(idx,:)' rs];
        end

        subplot(2,1,1)
        plot(0,inf(1))
        title("Infected in Model")
        ylabel("Number Infected")
        hold on
        upto = t<=1;
        plot(t(upto)+1,U(2,upto))
        hold off
        xlim([0 stps])
        ylim([0 up])
        %        legend("Network", "Fully Connected")

        subplot(2,1,2)
        p=plot(g, ...
            'NodeColor', colors(:,:,1), ...
            'NodeLabel', {});
        p.Marker='s';
        title("Network Simulation")
        titstring="N="+ns+", K="+ks+", \beta="+beta;
        subtitle(titstring)

        gif('simple_network_sir.gif',...
            'overwrite',true,...
            'DelayTime',.25,...
            'resolution',150)

        for r=2:nstep

            subplot(2,1,1)
            plot(inf(1:r))
            xlim([0 stps])
            ylim([0 up])
            title("Infected in Model")
            ylabel("Number Infected")
            hold on
            upto = t<=r;
            plot(t(upto)+1,U(2,upto))
            hold off
            %            legend("Network", "Fully Connected")

            subplot(2,1,2)
            p=plot(g, ...
                'NodeColor', colors(:,:,r), ...
                'NodeLabel', {});
            p.Marker='s';
            title("Network Simulation")
            titstring="N="+ns+", K="+ks+", \beta="+beta;
            subtitle(titstring)

            gif
        end



end



