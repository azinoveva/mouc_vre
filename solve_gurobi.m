function result = solve_gurobi(N,T,Q,c,A,b)
%% Quadratic programming problem solved with Gurobi MATLAB API.

    % Start constructing the model
    model = struct();

    
    %% Define model objective

    model.Q = Q;
    model.obj = c;
    model.modelsense = 'min';

    model.A = A;
    model.rhs = b;
    model.sense = '<';
    model.vtype = [repmat('C', 1, N*T), repmat('B', 1, 2*N*T)];

    gurobi_write(model, 'model.lp');
    params.resultfile = 'iismodel.ilp';
    result = gurobi(model, params);
    

end