% makes a small-world
function net = smallworld(N,K,beta)

g = WattsStrogatz(N, K, beta); % generate the network
net = adjacency(g); % turn it into a network

