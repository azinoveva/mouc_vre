% Placeholder variables to initialize the network
span = 0.05:0.1:0.995;
cost_gurobi = zeros(length(span), 2);
runtime_gurobi = zeros(1, length(span));
objval_gurobi = zeros(1, length(span));

cost_sedumi = zeros(length(span), 2);
runtime_sedumi = zeros(1, length(span));
objval_sedumi = zeros(1, length(span));
alpha = 25;


    %% Collect data for Gurobi
for k = 1:1
    network = network_init();
    for i = 1:length(span)
        w2 = span(i);
        w1 = 1 - w2;
        network.c = w1 * (network.c1 + alpha * network.cpen) + w2 * network.c2;
        network.Q_biobj = network.Q * w1;
        result_gurobi = solve_gurobi(network);
        [cost_gurobi(i, 1), cost_gurobi(i, 2)] = objective_values(network, alpha, result_gurobi.x);
        runtime_gurobi(i) = result_gurobi.runtime;
        objval_gurobi(i) = result_gurobi.objval;
    end
    loglog(cost_gurobi(:, 1), cost_gurobi(:, 2), 'ko'); 
    hold on
end

schedule_gurobi = reshape(result_gurobi.x, [24, 12, 3]);

%result_sedumi = solve_sedumi(N,T,Q,c,A,b);
%schedule_sedumi = reshape(result, [T, N, 3]);

%% Collect data for Sedumi

%% Plot 