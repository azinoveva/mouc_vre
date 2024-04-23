function result = qp(N,T,Q,c,A,b)
%% Quadratic programming problem solved with Gurobi MATLAB API.

    % Start constructing the model
    model = struct();

    
    %% Define model objective

    model.Q = Q;
    model.obj = c;
    model.modelsense = 'min';

    model.A = A;
    model.rhs = b;
    model.sense = [repmat('<', 1, (2*N+1)*T), repmat('=', 1, N*T)];
    model.vtype = [repmat('C', 1, N*T), repmat('B', 1, 2*N*T)];
    model.start = zeros(1, 3*N*T);
    model.lb = zeros(1, 3*N*T);

    gurobi_write(model, 'qp.lp');
    result = gurobi_iis(model);
    

end