function[inf,nisum,rec,infsum] = sir_simulation(A,parent_node,prob,immunized,r,num_of_steps)
%OUTPUT
%inf - number of infected
%nisum - number of infected nodes in each iteration
%rec - number of recovered nodes in each iteration
%infsum - total number of infected


%INPUT
% num_of_steps - maximum number of iterations. If all the nodes get recovered before that, the simulation will stop
% prob - the probability that the node will be infected from already infected neighboring node
% r - the recovery rate
% parent_node - the ID of the node where infection starts. If parent_node is an array of IDs,
%the infection will start in all of the nodes listed in parent_node. For
%example: parent_node = [1 5 7] means the infection will start in nodes 1 5 and 7 
% immunized - the custom probability of virus transmission to certain nodes could be specified if needed.
%For custom transmission probabilities, the vector "immunized" should have the size of number of nodes where
%each entry is the customized probability of transmission to certain node. If left empty, the p is the same
%for all nodes. For example, if network has 5 nodes and we want to
%customize the probabilities of transmission, then immunized vector should
%have the following form: immunized = [0.5 0.5 0.7 0.5 0.9]

% grab the total number of nodes we need
num_of_nodes = size(A,1);

% make a vector of nodes as zero
x = zeros(1,num_of_nodes);
% infect the desired parent nodes (maybe more than one)
x(parent_node) = 1;

% immunization section
% i dont think i want to use this yet
all_prob = zeros(num_of_nodes,1);
for i = 1:size(immunized,1)
    all_prob(immunized(i,1)) = immunized(i,2);
end
all_prob(all_prob==0)=prob; 

% there are no infected yet
% (are you sure that's what this holds?...)
inf = [];
% there is no number of infected yet
nisum = [];
% WHAT IS R SEQ? 
r_sequence = [];
    
    % for the number of desired steps
    for i = 1:num_of_steps 
        % if were on the first step
        % This just sets stuff up
        if i == 1
            % copy over the information vector
            z = x;
            % make a new vector of the same length
            ni = zeros(1,num_of_nodes);
            % create the first recovery step ( i think )
            if rand<r;  ni(x==1) = 1; end
            % recovered is this vector transposed
            recovered = ni';
            % record this time step for graphing i think?
            z_all(1,:) = z;
        % If we are not on the first step
        % (so everything is set up)
        else

            [z,ni] = sir_infection_step(A,z,all_prob);
            z_all(i,:) = z;
            [nA,nr] = sir_recovery_step(A,z_all(i-1,:),r);
            A = nA;
            recovered = recovered + nr;
            recovered(recovered > 1)=1;
        end
        inf(i) = sum(z(z==1));
        nisum(i) = sum(ni(ni==1));
        rec(i) = sum(recovered(recovered==1));
        infsum(i) = sum(z(z==1));
        inf(i) = inf(i)-rec(i);
        if i > 1 && inf(i) == 0
            break
        end
    end
end


