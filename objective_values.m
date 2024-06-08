function [F1, F2] = objective_values(network, alpha, solution)
% OBJECTIVE_VALUES Calculates the objective values for a given solution.
%
%   [F1, F2] = OBJECTIVE_VALUES(network, alpha, solution) computes the
%   values of two objectives for the provided solution in the context of 
%   an electrical network optimization problem.
%
%   Inputs:
%     network  - Structure containing the network parameters, including:
%                - Q    : Quadratic cost matrix.
%                - c1   : Linear cost vector for the first objective.
%                - cpen : Penalty cost vector for VRE deviations.
%                - c2   : Linear cost vector for the second objective.
%     alpha    - Scalar weighting factor for the penalty costs.
%     solution - Vector representing the solution for which the objectives
%                are calculated.
%
%   Outputs:
%     F1 - Cost of power generation, including quadratic and linear costs,
%          and penalties for VRE deviations.
%     F2 - Difference between the generation from coal/oil and VRE.
%
%   Notes:
%     - The function assumes that 'network' has been properly initialized
%       using a function like 'network_init'.
%     - The 'solution' vector should be of appropriate length corresponding
%       to the number of generators (network.N) and time steps (network.T).

    % F1: Cost of power generation
    F1 = solution' * network.Q * solution + (network.c1 + alpha * network.cpen)' * solution;

    % F2: Coal/oil generation minus VRE generation
    F2 = network.c2' * solution;
end

