function [F1, F2] = objective_values(network, alpha, solution)
% The function takes network parameters and a solution and returns 
% the values of two objectives for this solution.

    % F1: Cost of power generation
    F1 = solution' * network.Q * solution + (network.c1 + alpha * network.cpen)' * solution;

    % F2: Coal/oil generation minus VRE generation
    F2 = network.c2' * solution;
end

