function power = pdf(hour, type)
% PDF Generates a power output sample based on forecasted values and 
% probability distributions for wind and solar farms.
%
%   power = PDF(hour, type) calculates the power output sample for the 
%   specified hour and farm type using forecasted values and probability 
%   distributions. The function returns the power output sample.
%
%   Inputs:
%     hour - Integer representing the hour of the day (in 24-hour format).
%     type - String specifying the type of farm ("wind" or "solar").
%
%   Outputs:
%     power - Calculated power output sample for the given hour and farm type.
%
%   Example:
%     % Generate a power output sample for a wind farm at 9 AM
%     power = pdf(9, "wind");
%
%   Notes:
%     - This function generates power output samples based on forecasted 
%       values and probability distributions for wind and solar farms.
%     - It utilizes log-normal and sine irradiation functions to model power 
%       output for wind and solar farms, respectively.
%     - The input 'hour' should be an integer in the range [1, 24], 
%       representing the hour of the day.
%     - The input 'type' should be a string, either "wind" or "solar", 
%       specifying the type of farm.
%     - Power output for solar farms is zero during nighttime (between 8 PM 
%       and 5 AM).

%% Forecasted output and probability distributions for ...

% a wind farm
wind_forecast = 25.5;

wind_probs = [0.5, 0.15, 0.15, 0.10,  0.10;
              1,   0.99, 1.01, 0.975, 1.025;
              1,   0.98, 1.02, 0.95,  1.05  ];
% a solar farm
solar_forecast = 40;

solar_probs = [0.7, 0.15,  0.15;
               1,   0.985, 1.015;
               1,   0.975, 1.025 ];
%% Start searching through conditions
% Decide, wind or solar farm

if type == "wind"
    % Two probability tables: 12AM-11AM and 12PM-11PM
    if hour <= 12
        sequence = wind_probs(2, :);
    else
        sequence = wind_probs(3, :);
    end

    % Sample probability from the corresponding table
    sample = datasample(sequence, 1, 'Weights', wind_probs(1, :));
    % According to the sample probability, define maximal power output
    max_power = wind_forecast * sample;

    % Transform for log-normal distribution
    mu = log(1/sqrt(2) * max_power);
    sigma = log(2);

    % Sample power
    power = lognrnd(mu, sigma);

elseif type == "solar"
    % No solar energy between 8PM and 5AM
    if hour < 5 || hour > 20
        power = 0;
    else
        % As with the wind, two probability tables: 5AM-11AM and 12PM-8PM
        if hour <= 12
            sequence = solar_probs(2, :);
        else
            sequence = solar_probs(3, :);
        end

        % Sample probability from the corresponding table
        sample = datasample(sequence, 1, 'Weights', solar_probs(1, :));
        % According to the sample probability, define maximal power output
        max_power = solar_forecast * sample;
        % Return actual power output according to sin irradiation function
        power = max_power * sin(pi * (hour - 5) / 15)^2;
    end
end


