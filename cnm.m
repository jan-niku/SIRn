% cnm generation
function [init_net, net] = cnm(param1,param2,dist)

pd = makedist(dist,param1,param2);
init_net = zeros(1,N);
for i = 1:N % build degree dist by prob dist
    init_net(i) = pd.random;
end
init_net = ceil(init_net); % degrees are ints
disp("Building network from distribution...")
net = cm_net(init_net); % pass dist to cm for adj mat