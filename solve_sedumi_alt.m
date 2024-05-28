function [recovered_x, yalmip_time, solver_time] = solve_sedumi_alt(network)
%SOLVE_SEDUMI_ALT Summary of this function goes here
%   Detailed explanation goes here
%% Setup
    Q = network.Q_biobj;
    c = network.c;
    
    A = network.A;
    b = network.b;
    
    % Number of variables
    n = length(c);
    
    % Construct the augmented matrix Q_tilde
    Q_tilde = [Q, c; c', 0];
    
    % Define variables in YALMIP
    X = sdpvar(n+1, n+1, 'symmetric'); % Symmetric matrix variable for homogenization
    x = X(1:n, n+1); % Extract the x part from the last column of X
    
    % Define the homogenized objective function: (1/2) * trace(Q_tilde*X)
    objective = trace(Q_tilde * X);
    
    % Define the constraints
    constraints = [X >= 0, ... % X must be positive semidefinite
                   X(n+1, n+1) == 1, ... % Homogenization constraint
                   A * x <= b * X(n+1, n+1)]; % Original linear constraints, homogenized
    
    % Set up options for the solver
    options = sdpsettings('solver', 'sedumi', 'verbose', 1);
    
    % Solve the problem
    sol = optimize(constraints, objective, options);
    
    % Check if the solution is feasible
    if sol.problem == 0
        % Extract and display the solution
        x_opt = value(x)
        X_opt = value(X)
        fprintf('Optimal value: %f\n', value(objective));
    else
        disp('The problem could not be solved');
        disp(sol.info);
    end
end

