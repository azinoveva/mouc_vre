function power = pdf(hour, type)
%PDF Summary of this function goes here
%   Detailed explanation goes here

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


