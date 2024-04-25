network;

result = solve_gurobi(N,T,Q,c,A,b);
schedule = reshape(result.x, [T, N, 3]);

figure
x = 1:24;
bar(x, schedule(:,:,1), 'stacked'); hold on
plot(x, D);