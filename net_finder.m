% network plotter

% finds the network given some parameter

function [net_sim, idx] = net_finder(CC, metrics, Series)

met = metrics(1,:);
sz = length(met);

% look for exact matches first
exact = met == CC;
matches = find(exact);
if sum(matches) == 1
    idx = find(exact);
else
    sa = repelem(CC,sz); % met-length-many copies of CC
    rad = 0.01; % initial search radius
    while sum(matches) ~= 1
        res = abs(met-sa);
        matches = res<rad;
        rad = rad/10;
        if rad < 1e-8
            disp("Radius too small, breaking")
            break
        end
    end
    idx = find(matches);

net_sim = Series{1,1,idx};

end