% Placeholder variables to initialize the network
network = network_init();
span = 0:0.1:1;
obj_gurobi = [];
cost_gurobi = [];


for i = 1:length(span)
    w1 = span(i);
    w2 = 1 - w1;
    network.c = w1 * network.c1 + w2 * network.c2;
    network.Q_biobj = network.Q * w1;
    result_gurobi = solve_gurobi(network);
    [obj1, obj2] = value(network, result_gurobi.x);
    obj_gurobi = [obj_gurobi, result_gurobi.objval];
    cost_gurobi = [cost_gurobi; [obj1, obj2]];
end

loglog(cost_gurobi(:, 1), cost_gurobi(:, 2));

%schedule_gurobi = reshape(result_gurobi.x, [T, N, 3]);

%result_sedumi = solve_sedumi(N,T,Q,c,A,b);
%schedule_sedumi = reshape(result, [T, N, 3]);