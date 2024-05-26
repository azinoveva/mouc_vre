function [recovered_x, yalmip_time, solver_time] = solve_sedumi_alt(network)
%SOLVE_SEDUMI_ALT Summary of this function goes here
%   Detailed explanation goes here
%% Setup
Q = network.Q_biobj;
c = network.c;

A = network.A;
b = network.b;

n = length(c);
m = size(A, 1);

%% Construct the model for YALMIP

% Define the lifted variable X (n+1 x n+1 matrix)
X = sdpvar(n+1, n+1);

% Define the lifted cost matrix
hatQ = [Q, 0.5*c; 0.5*c', 0];

% Define the constraints
Constraints = X >= 0;

% Add inequality constraints Ax <= b in the lifted form
for i = 1:m
    Ai = [zeros(n, n), A(i, :)'/2; A(i, :)/2, -b(i)];
    Constraints = [Constraints, trace(Ai*X) <= 0];
end

% Define the objective function
Objective = trace(hatQ*X);

% Set the solver
options = sdpsettings('solver', 'sedumi', 'verbose', 2);

% Solve the problem
sol = optimize(Constraints, Objective, options);

optimal_X = value(X);
recovered_x = optimal_X(1:n, n+1);

yalmip_time = diagnostics.yalmiptime;
solver_time = diagnostics.solvertime;
end

