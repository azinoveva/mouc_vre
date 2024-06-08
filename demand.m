function demand_profile = demand(max_capacity, T)
% DEMAND Generates a demand profile for an electrical network.
%
%   demand_profile = DEMAND(max_capacity, T) creates a demand profile with a
%   sinusoidal base and random variation, ensuring the demand stays within realistic bounds.
%
%   Inputs:
%     max_capacity - Maximum capacity of the network (scalar value).
%     T            - Number of time steps (hours) over which the demand profile is generated.
%
%   Outputs:
%     demand_profile - Vector of length T representing the demand profile for the network.
%
%   Example:
%     demand_profile = demand(1000, 24);
%     This generates a demand profile for a network with a maximum capacity of 1000 MWh over 24 hours.
%
%   Notes:
%     - The base demand is sinusoidal with a peak-to-peak variation of 50% of the max capacity.
%     - Random variation is added to the base demand, with a standard deviation of 10% of the max capacity.
%     - The resulting demand profile is shifted by 6 time steps to simulate realistic demand patterns.
%     - Demand values are constrained to be non-negative and not exceed the maximum capacity.

% Create a base demand profile using a sinusoidal function
% The base demand is a sinusoidal wave oscillating between 0.5*max_capacity and max_capacity.
% The factor 0.25*(3 + sin(...)) ensures the demand oscillates around a base level with some variation.
base_demand = max_capacity * 0.25 * (3 + sin(2 * pi * (0:T-1) / T));

% Add random variation to the base demand profile
% Random variation is introduced to simulate more realistic demand fluctuations.
% The variation is a Gaussian noise with a standard deviation of 10% of max_capacity.
variation = max_capacity * 0.1 * randn(1, T);

% Combine the base demand with the random variation
demand_profile = base_demand + variation;

% Ensure the demand is within realistic bounds
% The demand is constrained to be non-negative and not exceed max_capacity.
demand_profile = max(0, min(demand_profile, max_capacity));

% Circshift the demand profile by 6 time steps
% This can be used to simulate a different starting point in the demand cycle.
demand_profile = circshift(demand_profile, 6);
end
