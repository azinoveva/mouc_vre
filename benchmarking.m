network;

result_gurobi = solve_gurobi(N,T,Q,c,A,b);
schedule_gurobi = reshape(result_gurobi.x, [T, N, 3]);

%result_sedumi = solve_sedumi(N,T,Q,c,A,b);
%schedule_sedumi = reshape(result, [T, N, 3]);