% enter the adjacency matrix you want to load here
A = load("small_network.txt");

% enter size of matrix here
m = 5;
n = 5;

% strange what is this
bigA = [zeros(m,m), A;
        A', zeros(n,n)];

% create the graph
g = graph(bigA);

% some kind of running coords for plot
xdata = [ones(1,m), 2+zeros(1,n)];
ydata = [linspace(0,1,m), linspace(0,1,n)];

plot(g,'XData', xdata, 'YData', ydata)

