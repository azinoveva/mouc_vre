function result = solve_gurobi(network)
% SOLVE_GUROBI Solves a quadratic programming problem using Gurobi MATLAB API.
%
%   result = SOLVE_GUROBI(network) solves the quadratic programming problem 
%   formulated for the given network structure using the Gurobi MATLAB API.
%   It returns the optimal solution.
%
%   Inputs:
%     network - Structure containing the network parameters, including:
%               - N     : Number of units.
%               - T     : Number of scheduling hours.
%               - Q_biobj : Hessian of the quadratic programming problem.
%               - c     : Linear terms of the objective function.
%               - A     : Linear constraint matrix.
%               - b     : Right-hand side constraint vector.
%
%   Outputs:
%     result - Struct containing the optimal solution, including:
%              - x   : Solution vector.
%              - objval : Optimal objective value.
%              - status : Solution status.
%              - runtime : Runtime of the solver.
%
%   Example:
%     % Initialize network structure (assuming network_init is defined)
%     network = network_init(5, 24);
%     % Solve the quadratic programming problem using Gurobi
%     result = solve_gurobi(network);
%
%   Notes:
%     - This function uses the Gurobi MATLAB API to solve the quadratic 
%       programming problem. Ensure Gurobi and its MATLAB API are properly 
%       installed and added to the MATLAB path.
%     - The network structure should contain fields N, T, Q_biobj, c, A, and b.
%     - The solution status and runtime are included in the output struct 'result'.

    N = network.N; T = network.T;
    %% Construct the model
    model = struct();
    
    % Objectives
    model.Q = network.Q_biobj;
    model.obj = network.c;
    model.modelsense = 'min';

    % Constraints
    model.A = network.A;
    model.rhs = network.b;
    model.sense = '<';
    model.vtype = [repmat('C', 1, N*T), repmat('B', 1, 2*N*T), repmat('C', 1, 2*T)]; % N*T continuous, 2N*T binary variables

    % Write the model into 'model.lp'
    gurobi_write(model, 'model.lp');
    % Solve
    result = gurobi(model);  
    
end