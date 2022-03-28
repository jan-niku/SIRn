function [z,ni] = sir_infection_step(A,x0,p)

%A - Adjacency matrix

%x0 - vector which describes infected nodes in time step before running 
%    function where each element represents infected/non infected node. 
%    The value is 1 for infected, and 0 for non infected node

% P VECTOR COULD BE USEFUL TO MODIFY
%p - the probability that succeptible node will be infected. The 
%    probability is the same for all nodes if the p is scalar. If p is the 
%    vector, it represents the probabilities of infection for each node

%r_tobe - "recovered to be" - the list of nodes to be recovered 
%         in this time step

%z - output vector - the new state of a system. Vector consisted of 1s and 
%    0s, where 1 is infected and 0 is not infected node

%ni - "newly infected" - output vector - the difference between previous 
%     and new state of a system

% grab only num  cols of A (square)
[~,n] = size(A);

% they may not be exactly 1
x0(x0>1) = 1; 
% I = find(x0 == 1)
%Calculate all susceptible nodes

PROB = zeros(1,n);
NEWINF = zeros(1,n);

%OPTIMIZED CODE 1

% A(x0==1,:) pulls out rows of infected
% sum(...,1) then sums them, column wise, into a new row
% this first pulls out the adjacencies of any infected node
% then sums them
% so we get a total, each column is the number of infected nodes
% that this node is adjacent to now (or will be)
AN = sum(A(x0==1,:),1); %,1) -> row vector of column sums
% all entries greater than 1 are true, since we dont care about >1
AN(AN>1) = 1;
% susceptible vector, nodes next to infected nodes
SUC1 = AN;
%END OF OPTIMIZED CODE 1

% we don't care about nodes that are already infected here
SUC = SUC1 - x0;
% make sure nothing dropped below zero, should be a bool after this
% this is a vector of nodes next to infected nodes
% so SUsCeptible
SUC(SUC<0) = 0;

%Calculate the number of infected neighboring nodes for each susceptible node
%OPTIMIZED CODE 2
NEIGH = zeros(1,n);
for i = find(SUC==1) % for every index of a SUC node
    AN = and(A(:,i),x0');
    NEIGH(i) = sum(AN);
end
%END OF THE OPTIMIZED CODE

%Calculate the probability of infection for each node
if size(p,1)==1
    for i = 1:n
        PROB(i) = 1-(1-p)^NEIGH(i);
    end
else
    for i = 1:n
        PROB(i) = 1-(1-p(i))^NEIGH(i);
    end
end


%Calculate new infected nodes
for i = 1:n
    format long
    r = rand;
    if r <= PROB(i)
        NEWINF(i) = 1;
    end
end
ni = NEWINF;
%The new vector z with all infected nodes
z = NEWINF + x0;

%remove the nodes



end