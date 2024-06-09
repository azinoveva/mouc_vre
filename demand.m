function demand_profile = demand(gens, start, T)
% DEMAND Generates a demand profile for an electrical network.
%
%   demand_profile = DEMAND(max_capacity, T) creates a demand profile with a
%   sinusoidal base and random variation, ensuring the demand stays within realistic bounds.
%
%   Inputs:
%     gens         - Maximum capacity of the generators.
%     gens         - Starting state of the generators.
%     T            - Number of time steps (hours) over which the demand profile is generated.
%
%   Outputs:
%     demand_profile - Vector of length T representing the demand profile for the network.
%
%   Example:
%     demand_profile = demand([455, 455, 120, 30], [1, 1, 0, 0], 24);
%     This generates a demand profile for a network with four generators
%     with maximum capacities of 455, 455, 120, 30 MWh over 24 hours under assumption that the first two generators are running at T=1.
%
%   Notes:
%     - The base demand is sinusoidal with a peak-to-peak variation of 50% of the max capacity.
%     - Random variation is added to the base demand, with a standard deviation of 10% of the max capacity.
%     - The resulting demand profile is shifted by 6 time steps to simulate realistic demand patterns.
%     - Demand values are constrained to be non-negative and not exceed the maximum capacity.

% Compute constraints on maximum capaciti and feasible starting point
starting_capacity = sum(gens(start == 1));
max_capacity = sum(gens);
% Create a base demand profile using a sinusoidal function
% The base demand is a sinusoidal wave oscillating between 0.5*max_capacity and max_capacity.
% The factor 0.25*(3 + sin(...)) ensures the demand oscillates around a base level with some variation.
base_demand = max_capacity * 0.25 * (3 + sin(2 * pi * (0:T-1) / T));

% Add random variation to the base demand profile
% Random variation is introduced to simulate more realistic demand fluctuations.
% The variation is a Gaussian noise with a standard deviation of 5% of max_capacity.
variation = max_capacity * 0.05 * randn(1, T);

% Combine the base demand with the random variation
demand_profile = base_demand + variation;

% Ensure the demand is within realistic bounds
% The demand is constrained to be non-negative and not exceed max_capacity.
demand_profile = max(0, min(demand_profile, max_capacity));

% Circshift the demand profile by 6 time steps
% This can be used to simulate a different starting point in the demand cycle.
demand_profile = circshift(demand_profile, 6);

% Additional constraint for the starting state
demand_profile(1) = min(demand_profile(1), starting_capacity);

end
