function result = qp(N,T,Q,c,A,b,ub)
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
    model.lb = zeros(1, 3*N*T);
    model.ub = ub;
    model.start = [NaN(1, N*T), 1, 1, zeros(1, N-2), NaN(1, (N*T-N)), 1, 1, NaN(1, (N*T-2)),];
        
    %zeros(1, 3*N*T);

    gurobi_write(model, 'qp.lp');
    
    params = struct();
    params.runtime = 100;
    result = gurobi(model, params);

end