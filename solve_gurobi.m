function result = solve_gurobi(network)
% Quadratic programming problem solved with Gurobi MATLAB API.
%
% z = [g; x; y] with x, y binary
%
% min z'*Q*z + c'*z, 
%  z
% such that: Az <= b
%
%
% --INPUTS-----------------------------------------------------------------
%   N       int                 Number of units
%   T       int                 Number of scheduling hours
%   Q       [3NT x 3NT]         Hessian of the QP
%   c       [3NT x 1]           Linear QP terms
%   A       [8NT+N+T x 3NT]     Linear constraint matrix
%   b       [8NT+N+T x 1]       Right hand side constraint vector
% --OUTPUTS----------------------------------------------------------------
%   result  struct              Optimal solution
%
%   Aleksandra Zinoveva, Aswin Kannan, HU Berlin, 2024  

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
    model.vtype = [repmat('C', 1, N*T), repmat('B', 1, 2*N*T)]; % N*T continuous, 2N*T binary variables

    % Write the model into 'model.lp'
    gurobi_write(model, 'model.lp');
    % Solve
    result = gurobi(model);  
    
end