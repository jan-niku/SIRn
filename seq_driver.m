% seq_driver

% This code is similar to driver,
% but it will not plot
% it is designed to build a matrix of adj matrices
% which are then passed into some model. 

%% Parameters
% Global
N = 10000; % number of nodes
addKfin = 0;

% Small world parameters
% K is the link density. 
Kinit = 1; % the first k
Kfin = 10000; % the last k
Kstep = 10; % the step between them
Karr = [Kinit:Kstep:Kfin]; % build the array
% note in this set up, you may miss kfin
% if the interval does not divide evenly by Kstep
if 