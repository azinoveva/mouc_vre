function [z, solver_time] = solve_sedumi(network)
% SOLVE_SEDUMI Solves a semidefinite programming problem using SeDuMi.
%
%   [z, solver_time] = SOLVE_SEDUMI(network) solves the semidefinite 
%   programming problem formulated for the given network structure using 
%   the SeDuMi solver. It returns the solution vector and the solver time.
%
%   Inputs:
%     network - Structure containing the network parameters, including:
%               - Q_biobj : Quadratic cost matrix for the objective.
%               - c       : Linear cost vector for the objective.
%               - A       : Constraint matrix.
%               - b       : Constraint vector.
%
%   Outputs:
%     z          - Solution vector for the optimization problem.
%     solver_time - Time taken by the solver to find the solution.
%
%   Example:
%     % Initialize network structure (assuming network_init is defined)
%     network = network_init(5, 24);
%     % Solve the semidefinite programming problem
%     [z, solver_time] = solve_sedumi(network);
%
%   Notes:
%     - This function uses YALMIP to define and solve the semidefinite 
%       programming problem. Ensure YALMIP and SeDuMi are installed and added 
%       to the MATLAB path.
%     - The network structure should contain fields Q_biobj, c, A, and b.
%     - The solver is set to SeDuMi with verbosity level 1.
%% Setup
    Q = network.Q_biobj;
    c = network.c;
    
    A = network.A;
    b = network.b;
    
    % Number of variables
    n = length(c);
    
    % Construct the augmented matrix Q_tilde
    Q_tilde = [0, 0.5*c'; 0.5*c, Q];
    
    % Define variables in YALMIP
    Z = sdpvar(n+1, n+1, 'symmetric');            % Symmetric matrix variable for homogenization
    
    % Define the homogenized objective function: (1/2) * trace(Q_tilde*X)
    objective = trace(Q_tilde * Z);
    
    % Define the constraints
    constraints = [Z >= 0, ... % Z must be positive semidefinite
                   Z(1, 1) == 1]; % Original linear constraints, homogenized
    
    for i = 1:length(b)
        Ai = [0, A(i, :); A(i, :)', zeros(n)];
        constraints = [constraints, trace(Ai * Z) <= 2*b(i)];
    end

    % Set up options for the solver
    options = sdpsettings('solver', 'sedumi', 'verbose', 1);
    
    % Solve the problem
    sol = optimize(constraints, objective, options);
    
    % Check if the solution is feasible
    if sol.problem == 0
        % Extract and display the solution
        z = value(Z(2:end, 1));
        solver_time = sol.solvertime;
    else
        ME = MException('sol.problem', ...
        'The problem could not be solved!', str);
        disp(sol.info);
        throw(ME);
    end
end

