function network = network_init()
%% Problem Formulation

network = struct();
%% Objective-related:

% Linear cost coefficient
lin_coef = [16.19, 17.26, 16.6, 16.5, 19.7, 22.26, 27.74, 25.92, 27.27, 27.79, 0.02, 0.02];

% Quadratic cost coefficient
quad_coef = [0.00048, 0.00031,  0.002,   0.00211,  0.00398, ... 
     0.00712, 0.000793, 0.00413, 0.002221, 0.00173, 0, 0];

% Idling cost -- also a constant coefficient in the cost function
C_run = [1000, 970, 700, 680, 450, 370, 480, 660, 665, 670, 0.02, 0.02];

% Cost of starting the unit. Stopping is "free".
C_start = [9000, 10000, 1100, 1120, 1800, 340, 520, 60, 60, 60, 10, 10];

%% Constraint-related

% Demand for 24H
D = [850,  950,  1050,  1100,  1200, 1250, ...
     1300, 1400, 1500, 1650, 1700, 1600, ...
     1400, 1200, 1150, 1000, 1100, 1300, ...
     1500, 1300, 1100, 900, 800, 750];

% Power limit of the conventional units.
G_max = [455, 455, 130, 130, 162, 80, 85, 55, 55, 55];

% Minimal running time of the units
T_min = [8, 8, 5, 5, 6, 3, 3, 1, 1, 1, 1, 1];

% Types of generators: 1 for conventional, -1 for VRE

types = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -1, -1];

% Starting state of the generators: two first conventional and wind farm
% are running

start = [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]; 

% Number of generators and time periods (24H)
Nconv = 10; Nvre = 2; 
T = 24; 
N = Nconv + Nvre;

%% Construct the constraint matrix:
% ------------------------------------------------------
% A1 - "general" identity matrix

A1 = eye(N*T);

% ------------------------------------------------------
% A2 - power generation constraints. 

A2 = [];
for i = 1:Nconv
    A2 = blkdiag(A2, blkdiag(G_max(i)*eye(T)));
end

% Have to additionally sample for VRE on an hourly basis

wind_power = [];
solar_power = [];
for t = 1:T
    wind_power = [wind_power, pdf(t, "wind")];
    solar_power = [solar_power, pdf(t, "solar")];
end

% Assemble A4
A2 = -blkdiag(A2, diag(wind_power), diag(solar_power));

% ------------------------------------------------------
% A3 - ensure we meet the demand

A3 = [];
for i = 1:T
    A3 = repmat(eye(T), 1, N);
end

% ------------------------------------------------------
% A4 - ensure minimum uptime
% Practically, we sample for start-ups in the last T_min hours and allow
% shutdown if this window is clear of start-ups

A4 = [];
for i = 1:N
    t = T_min(i);
    vec = [ones(1, t), zeros(1, T)];
    Agen = [];
    for j = 1:T
        Agen = [Agen; circshift(vec, j-1)];
    end
    Agen = Agen(:,t:end-1);
    A4 = blkdiag(A4, Agen);
end

% ------------------------------------------------------
% A5 - runtime-on connection (x_jt - x_jt-1 = y_jt)

A5 = [];
for i = 1:N
    A5 = blkdiag(A5, eye(T) - diag(ones(1, T-1), -1));
end

% ------------------------------------------------------
% A6 - incorporate sratring state

A6 = zeros(N, N*T);
for i = 1:N
    A6(i, 1 + T*(i-1)) = 1;
end

% ------------------------------------------------------
% A7 - wind and solar penalty constraints
% constraints for auxillary VRE penalty variables

wind_penalty = zeros(1, T) + quantile(wind_power, 0.5);

solar_penalty = zeros(1, T);
solar_penalty(5:20) = solar_penalty(5:20) + quantile(solar_power(5:20), 0.5);

vre_penalty = [wind_penalty, solar_penalty];

A8 = diag(ones(1, 2*T));
A7 = [zeros(2*T, (N-2)*T), A8];

% ------------------------------------------------------
% Assemble A

A = [A1,                A2,                 zeros(N*T),         zeros(N*T, 2*T);         % Upper bound on g
     zeros(N*T),        A1,                 zeros(N*T),         zeros(N*T, 2*T);         % Upper bound on x
     zeros(N*T),        zeros(N*T),         A1,                 zeros(N*T, 2*T);         % Upper bound on y
    -A1,                zeros(N*T),         zeros(N*T),         zeros(N*T, 2*T);         % Lower bound on g  
     zeros(N*T),       -A1,                 zeros(N*T),         zeros(N*T, 2*T);         % Lower bound on x
     zeros(N*T),        zeros(N*T),        -A1,                 zeros(N*T, 2*T);         % Lower bound on y
     A7,                zeros(2*T, N*T),    zeros(2*T, N*T),   -A8;                      % Lower bound on v
     zeros(N*T),        A5,                -A1,                 zeros(N*T, 2*T);         % 'On' and 'Running' connection
     zeros(N*T),       -A1,                 A4,                 zeros(N*T, 2*T);         % Minimal uptime
    -A3,                zeros(T, N*T),      zeros(T, N*T),      zeros(T, 2*T);           % Meeting the demand
     zeros(N, N*T),     A6,                 zeros(N, N*T),      zeros(N, 2*T)           % Starting state: generators 1 and 2 are running; the rest is off
    ];

% A predominantly consists of zeroes. Squeezing them out can save a lot of
% space -- therefore sparse representation.

network.A = sparse(A);
network.N = N;
network.T = T;

%% Create vector b

network.b = [zeros(1, N*T), ones(1, 2*N*T), zeros(1, 3*N*T), vre_penalty, zeros(1, 2*N*T) -D, start]';

%% Construct first objective: Q and c in z'Qz + c'z + pen for price modeling
% Set g = [g11, ..., g1T, ..., gNT]
%     x = [x11, ..., x1T, ..., xNT]
%     y = [y11, ..., y1T, ..., yNT]
%     v = [v11, ..., v1T, ..., y2T]
% and z = [g, x, y, v]'
% where vij is an auxillary variable that defines penalty for
% underproduction in wind (i = 1) and solar (i = 2) farms at a time j.

% VRE units have no influence on construction of Q and c. The idling cost
% is fixed and other costs do not apply. Quadratic part appears only in the
% first objective.
Q = [];

for i = 1:N
    Q = blkdiag(Q, quad_coef(i)*eye(T));
end

network.Q = sparse(blkdiag(Q, zeros(2*(N+1)*T)));

% Linear components of the objectives 
% network.c1 = [repelem(lin_coef, T), repelem(C_run, T), repelem(C_start, T)]';
network.c1 = [repelem(lin_coef, T), repelem(C_run, T), repelem(C_start, T), zeros(1, 2*T)]';
network.c2 = [repelem(types, T), zeros(1, 2*T*(N+1))]';
network.cpen = [zeros(1, 3*N*T), ones(1, 2*T)]';

%% Clean up

clear A1 A2 A3 A4 A5 A6 Agen t i j vec solar_power start wind_power;
end