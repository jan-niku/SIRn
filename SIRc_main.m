% This is code for a compartmental SIR
% it returns a matrix of S I R respectively as time series with time

function [t,U] = SIRc_main(tspan, U0, ...
    infection_rate, recovery_rate)

%% Params
%t0 = 0;
%tf = 100;
%tspan = [t0 tf];
%S0 = 100;
%I0 = 1;
%R0 = 0;
%U0 = [S0,I0,R0];

%infection_rate = 0.005;
%recovery_rate = 0.05;

%PLOTBOOL = 1; % plot at all?
%LEG_PLOT = 1; % legend
%LEGNAMES = ["S","I","R"];
%POP_BOOL = [1,1,1]; % which populations

%% Solve
[t,U] = ode45(@(t,U) SIRc(t,U,infection_rate,recovery_rate), tspan, U0);

