%% The main plotting wrapper that is called by many_network_driver
% at some point these all need to be split off into different functions

%% TODO
% some kind train test split on 7/9, 
% alternatively, generate some new networks and try it out

function ret = MANY_SIMULATION_PLOT(SIRDIR, ...
    compartments, METDIR, sirc,Series,numsim)

[~, ~, sers] = size(Series); % cols, the middle, always 1

% populate infected arrays
max_inf = zeros(1,sers);
max_inf_idx = zeros(1,sers);
for idx=1:sers
    inf = Series{1,1,idx};
    [run_max, run_idx] = max(inf);
    max_inf(idx) = run_max;
    max_inf_idx(idx) = run_idx;
end
SIRc_max_inf = max(sirc.U2);

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
rmin=sirc.r/1000;
rstep=sirc.r/1000;
rmax=sirc.r;
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
    "Plot a Simulation by Clustering Coefficient" ...
    "(Animated) Simple Network SIR" ...
    "Average Path Length vs. r-Compensation"];

choice = menu(msg,opts);

switch choice
    case 1
        plot(sirc.karr,max_new_inf)
        title('K value vs. Maximum New Infections')
        subtitle("N="+sirc.N)
        xlim([0 max(sirc.karr)])
        xlabel("K-value")
        ylabel("Maximum New Infections")

    case 2
        plot(sirc.karr,max_new_inf_idx)
        title('K vs. Iteration of Max New Infections')
        subtitle("N="+sirc.N)
        xlim([0 max(sirc.karr)])
        xlabel("K-value")
        ylabel("Index of Maximum Infection")

    case 3
        plot(sirc.karr, max_inf)
        xlim([0 max(sirc.karr)])
        ylim([0 SIRc_max_inf*1.2])
        yline(SIRc_max_inf,'-','Fully Connected Maximum','LineWidth',3)
        title("K vs. Maximum Infected")
        subtitle("N="+sirc.N);
        xlabel("K-value")
        ylabel("Maximum Infected")

    case 4

        kprop = sirc.karr/sirc.N; % K as a proportion of N
        fcmax = max(sirc.U2)*1.1; % for vert graph param

        plot(Series{1,1,1},'Color','black')
        hold on
        plot(sirc.tspan+1,sirc.U2,'--')
        hold off
        title("Infected; Fully Connected vs. Networked")
        subtitle("K proportion: " + kprop(1))
        xlabel("Time")
        ylabel("Infected")
        legend("Network", "Fully Connected")
        xlim([0 70])
        ylim([0 fcmax])

        gif('convergence.gif','overwrite',true)

        for idx=2:sers

            plot(Series{1,1,idx},'Color','black')
            hold on
            plot(sirc.tspan+1,sirc.U2,'--')
            hold off
            title("Infected; Fully Connected vs. Networked")
            subtitle("K proportion: " + kprop(idx))
            xlabel("Time")
            ylabel("Infected")
            legend("Network", "Fully Connected")
            xlim([0 70])
            ylim([0 fcmax])

            gif
        end

    case 5
        progressbar('Generating SIRc Outcomes')
        [tarr, ~, ~, Is, iters] = MANY_SIRc_GEN(sirc.tin, sirc.U0, ...
            sirc.q, rmin, rstep, rmax);
        plot(tarr{1}+1, Is{1})
        hold on
        plot(Series{1,1,ceil(sers*.65)})
        hold off
        ylim([0 sirc.N])
        xlim([0 75])
        title("Adjusting r to Fit Networked Model")
        rcompstr = sprintf('%01.04f',rarr(1)/sirc.r);
        subtitle("r Compensation: "+rcompstr);
        xlabel("Time")
        ylabel("Infected")
        legend("Network Model", "Fully Connected Model")
        gif('delete.gif','overwrite',true)
        for idx=1:iters
            plot(tarr{idx}+1,Is{idx})
            hold on
            % ceil sers*.65 means
            % grab about 65% of the way into the series
            plot(Series{1,1,ceil(sers*.65)})
            hold off
            ylim([0 sirc.N])
            xlim([0 75])
            title("Adjusting r to Fit Networked Model")
            rcompstr = sprintf('%01.04f',rarr(idx)/sirc.r);
            subtitle("r Compensation: "+rcompstr);
            xlabel("Time")
            ylabel("Infected")
            legend("Fully Connected Model", "Network Model")
            gif
        end

    case 6
        msg = "Do you want to optimize?";
        opts = ["No, load from file (will error if first run)" ...
            "Yes, optimize (will take a couple minutes)"];
        choice = menu(msg,opts);

        cc = metrics(1,:);

        switch choice
            case 1

                outcomes = readmatrix(METDIR+"opt_metrics.txt");
                bestrs = outcomes(1,:);
                dists = outcomes(2,:);
                percerrors = outcomes(3,:);
                rcomp = outcomes(4,:);
                beginidx = outcomes(5,1);

                % we have discarded some trivial fittings
                cc = cc(beginidx:end);

                c=polyfit(log(cc),rcomp,1);
                fit = @(x) c(1)*log(x)+c(2);

                prederror = (fit(cc)-rcomp)./rcomp;

                subplot(2,1,1)
                scatter(cc,rcomp,25,prederror,'filled')
                hold on
                fplot(fit,[0.25,1])
                hold off
                colormap('turbo')
                colorbar
                title("r-Compensation vs. Cluster Coefficient")
                subtitle("Coloring by Percent Error of Log Fit")
                xlabel("Clustering Coefficient of Network")
                ylabel("r Compensation Giving Best Fit")

                subplot(2,1,2)
                scatter(cc,prederror,'.')
                xlim([.2 1])
                yline(0,'-','LineWidth',2)
                title("Residuals of Log Fit")
                xlabel("Clustering Coefficient")
                ylabel("Error")

                exportgraphics(gcf,"r-optimization.png")

            case 2

                [bestrs, dists, percerrors, beginidx] = r_Optimizer(...
                    rarr, sirc.q, sirc.tin, sirc.U0, ...
                    max_inf, max_inf_idx,sirc.num_parents);

                rcomp = bestrs/sirc.r;
                beginarr = [beginidx zeros(1,length(rcomp)-1)];
                outopt = [bestrs; dists; percerrors; rcomp; beginarr];
                writematrix(outopt,METDIR+"opt_metrics.txt")

                % we have discarded some trivial fittings
                cc = cc(beginidx:end);

                % create a fitting
                c=polyfit(log(cc),rcomp,1);
                fit = @(x) c(1)*log(x)+c(2);

                % predict then calculate error
                prederror = (fit(cc)-rcomp)./rcomp;

                subplot(2,1,1)
                scatter(cc,rcomp,25,prederror,'filled')
                hold on
                fplot(fit,[0.25,1])
                hold off
                colormap('turbo')
                colorbar
                title("r-Compensation vs. Cluster Coefficient")
                subtitle("Coloring by Percent Error of Log Fit")
                xlabel("Clustering Coefficient of Network")
                ylabel("r Compensation Giving Best Fit")

                subplot(2,1,2)
                scatter(cc,prederror,'.')
                xlim([.2 1])
                yline(0,'-','LineWidth',2)
                title("Residuals of Log Fit")
                xlabel("Clustering Coefficient")
                ylabel("Error")

                exportgraphics(gcf,"r-optimization.png")
        end

    case 7

        outcomes = readmatrix(METDIR+"opt_metrics.txt");
        bestrs = outcomes(1,:);
        %        dists = outcomes(2,:);
        %        percerrors = outcomes(3,:);
        %        rcomp = outcomes(4,:);

        prompt = {'Whats the value, approximately?'};
        answ = inputdlg(prompt);
        [net_sim, idx] = net_finder(str2double(answ{1}), metrics, Series);

        plot(net_sim)
        xlim([0 125])
        hold on
        rn = bestrs(idx);
        [t,U] = SIRc_main(sirc.tin, sirc.U0, rn, sirc.q);
        plot(sirc.tspan+1,sirc.U2)
        title("Network Simulation")
        subtitle("K value: " + sirc.karr(idx));
        xlabel("Time")
        ylabel("Infections")
        legend("Network", "Fully Connected")

    case 8
        % generate a network simulation
        % 30,2,0.08,0.05,0.07 looks good
        ns = 40;
        ks = 3;
        beta = .12;
        r=0.05;
        q=0.07;

        parents = randi(ns,1,ceil(ns*.06));
        g = WattsStrogatz(ns,ks,beta);
        a = adjacency(g);
        [inf,~,~,~,s_all] = sir_simulation(...
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
        subtitle("r="+r+", q="+q)
        ylabel("Number Infected")
        hold on
        upto = t<=1;
        plot(t(upto)+1,U(2,upto))
        hold off
        xlim([0 stps])
        ylim([0 up])
        legend("Network", "Fully Connected",'Location', 'northeast')

        subplot(2,1,2)
        p=plot(g, ...
            'NodeColor', colors(:,:,1), ...
            'NodeLabel', {});
        p.Marker='s';
        title("Network Simulation")
        titstring="N="+ns+", K="+ks+", \beta="+beta;
        subtitle(titstring)

        gif('simple_network_sir2.gif',...
            'overwrite',true,...
            'DelayTime',.25,...
            'resolution',200)

        for idx=2:nstep

            subplot(2,1,1)
            plot(inf(1:idx))
            xlim([0 stps])
            ylim([0 up])
            title("Infected in Model")
            subtitle("r="+r+", q="+q)
            ylabel("Number Infected")
            hold on
            upto = t<=idx;
            plot(t(upto)+1,U(2,upto))
            hold off
            legend("Network", "Fully Connected", 'Location', 'northeast')

            subplot(2,1,2)
            p=plot(g, ...
                'NodeColor', colors(:,:,idx), ...
                'NodeLabel', {});
            p.Marker='s';
            title("Network Simulation")
            titstring="N="+ns+", K="+ks+", \beta="+beta;
            subtitle(titstring)

            gif
        end

    case 9
        msg = "Do you want to optimize?";
        opts = ["No, load from file (will error if first run)" ...
            "Yes, optimize (will take a couple minutes)"];
        choice = menu(msg,opts);

        cc = metrics(2,:);

        switch choice
            case 1

                outcomes = readmatrix(METDIR+"APL-opt_metrics.txt");
                bestrs = outcomes(1,:);
                dists = outcomes(2,:);
                percerrors = outcomes(3,:);
                rcomp = outcomes(4,:);
                beginidx = outcomes(5,1);

                % we have discarded some trivial fittings
                cc = cc(beginidx:end);

                c=polyfit(log(cc),rcomp,1);
                fit = @(x) c(1)*log(x)+c(2);

                prederror = (fit(cc)-rcomp)./rcomp;

                subplot(2,1,1)
                scatter(cc,rcomp,25,prederror,'filled')
                hold on
                fplot(fit,[1,2])
                hold off
                colormap('turbo')
                colorbar
                title("r-Compensation vs. Average Path Length")
                subtitle("Coloring by Percent Error of Log Fit")
                xlabel("Average Path Length of Network")
                ylabel("r Compensation Giving Best Fit")

                subplot(2,1,2)
                scatter(cc,prederror,'.')
                xlim([1 2])
                yline(0,'-','LineWidth',2)
                title("Residuals of Log Fit")
                xlabel("Average Path Length")
                ylabel("Error")

                exportgraphics(gcf,"APL-r-optimization.png")

            case 2

                [bestrs, dists, percerrors, beginidx] = r_Optimizer(...
                    rarr, sirc.q, sirc.tin, sirc.U0, ...
                    max_inf, max_inf_idx,sirc.num_parents);

                rcomp = bestrs/sirc.r;
                beginarr = [beginidx zeros(1,length(rcomp)-1)];
                outopt = [bestrs; dists; percerrors; rcomp; beginarr];
                writematrix(outopt,METDIR+"APL-opt_metrics.txt")

                % we have discarded some trivial fittings
                cc = cc(beginidx:end);

                % create a fitting
                c=polyfit(log(cc),rcomp,1);
                fit = @(x) c(1)*log(x)+c(2);

                % predict then calculate error
                prederror = (fit(cc)-rcomp)./rcomp;

                subplot(2,1,1)
                scatter(cc,rcomp,25,prederror,'filled')
                hold on
                fplot(fit,[1,2])
                hold off
                colormap('turbo')
                colorbar
                title("r-Compensation vs. Average Path Length")
                subtitle("Coloring by Percent Error of Log Fit")
                xlabel("Average Path Length of Network")
                ylabel("r Compensation Giving Best Fit")

                subplot(2,1,2)
                scatter(cc,prederror,'.')
                xlim([1 2])
                yline(0,'-','LineWidth',2)
                title("Residuals of Log Fit")
                xlabel("Average Path Length")
                ylabel("Error")

                exportgraphics(gcf,"APL-r-optimization.png")
        end



end



