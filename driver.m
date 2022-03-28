% This code will generate a lognormal network using CNM
% and then pass this network through gmuric's SIR

%% Parameters

% Global
N = 1000; % try for this many nodes
PLOT = [1,1];

% CNM
dist = 'lognormal'; % use 'makedist' to see list of possibles
sigma2 = 1; % change me based on dist VERY SENSITIVE
mu = 1; % change me based on dist SLIGHTLY SENSITIVE

% SIRn
parents = [1]; % initially infected
immunized = []; % unused
r = 0.03; % recovery
p = 0.03; % infection prob
num_of_steps = 2000;

%% Generate Network
disp("Creating degree distribution...")
pd = makedist(dist,mu,sigma2);
init_net = zeros(1,N);
for i = 1:N % build degree dist by prob dist
    init_net(i) = pd.random;
end
init_net = ceil(init_net); % degrees are ints
disp("Building network from distribution...")
net = cm_net(init_net); % pass dist to cm for adj mat

%% Pass to SIRn
disp("Beginning simulation...")
[inf,nisum,rec,infsum] = ...
    sir_simulation(net,parents,p,immunized,r,num_of_steps);

%% Plot

disp("Plotting...")
% SIRn stuff
if PLOT(2)
    figure
    subplot(4,1,1);
    plot(inf, 'b.:');
    ylabel('Infected (current)');
    grid on
    
    subplot(4,1,2);
    plot(infsum,'b.:');
    ylabel('Infected (sum)');
    grid on
    
    subplot(4,1,3);
    plot(nisum,'b.:');
    ylabel('Infected (new)');
    grid on
    
    subplot(4,1,4);
    plot(rec,'b.:');
    ylabel('Recovered');
    grid on
end

if PLOT(1)
    figure
    metrics = exportMetricsFile(graph(net), 'Title','metrics');
    avgAssort = mean(metrics.assortativityByNode);
    avgDegree = mean(init_net);
    subtitstr = dist+", \mu="+num2str(mu)+...
                ", \sigma="+num2str(sigma2);

    subplot(2,2,1)
    plot(graph(net))
    title("Network Visualization")
    subtitle(subtitstr)

    subplot(2,2,2)
    hist(init_net)
    hold on
    xline(avgDegree, 'Color', 'r', 'LineWidth', 2)
    hold off
    title("Degree Distribution")
    subtitle("Mean: " + num2str(avgDegree))

    subplot(2,2,3)
    hist(metrics.assortativityByNode)
    title("Assortativity by Node")
    subtitle("Mean: " + num2str(avgAssort))
    hold on
    xline(avgAssort, 'Color', 'r', 'LineWidth', 2);
    hold off

    subplot(2,2,4)
    hist(metrics.clusterings)
    hold on
    xline(metrics.avgClustering, 'Color', 'r', 'LineWidth', 2);
    title("Clustering")
    subtitle("Mean: " + num2str(metrics.avgClustering))
    hold off
end

