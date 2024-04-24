%% Problem Formulation
% Two last generating units are wind and solar based, so no fuel cost
% there.

%% Objective-related:

% Linear cost coefficient
a = [16.19, 17.26, 16.6, 16.5, 19.7, 22.26, 27.74, 25.92, 27.27, 27.79, 0, 0];

% Quadratic cost coefficient
b = [0.00048, 0.00031,  0.002,   0.00211,  0.00398, ... 
     0.00712, 0.000793, 0.00413, 0.002221, 0.00173, 0, 0];

% Idling cost -- also a constant coefficient in the cost function
C_run = [1000, 970, 700, 680, 450, 370, 480, 660, 665, 670, 0, 20];

% Cost of starting the unit. Stopping is "free".
C_start = [9000, 10000, 1100, 1120, 1800, 340, 520, 60, 60, 60, 0, 0];

%% Constraint-related

% Demand for 24H
D = [700,  750,  850,  950,  1000, 1100, ...
     1150, 1200, 1300, 1400, 1450, 1500, ...
     1400, 1300, 1200, 1150, 1000, 1100, ...
     1200, 1400, 1300, 1100, 900,  800];

% Power limit of the conventional units.
G_max = [455, 455, 130, 130, 162, 80, 85, 55, 55, 55];

% Minimal running time of the units
T_min = [8, 8, 5, 5, 6, 3, 3, 1, 1, 1, 1, 1];

% Starting state of the generators: two first conventional and wind farm
% are running

start = [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]; 

Nconv = 10; Nvre = 2; T = 24; % number of generators and time periods (24H)
N = Nconv + Nvre;

%% Construct Q and c in z'Qz + c'z for price modeling

% VRE units have no influence on construction of Q and c. The idling cost
% is fixed and other costs do not apply (?)
Q = [];

for i = 1:N
    Q = blkdiag(Q, b(i)*eye(T));
end

Q = sparse(blkdiag(Q, zeros(2*N*T)));

c = [repelem(a, T), repelem(C_run, T), repelem(C_start, T)]';


%% Construct the constraint matrix:

% Set g = [g11, ..., g1T, ..., gNT]
%     x = [x11, ..., x1T, ..., xNT]
%     y = [y11, ..., y1T, ..., yNT]
% and z = [g, x, y]'


A1 = eye(N*T);

% Have to sample for VRE on an hourly basis
A2 = [];
for i = 1:Nconv
    A2 = blkdiag(A2, blkdiag(G_max(i)*eye(T)));
end

% Note: figre out how to apply function to an array
wind_maxpower = [];
solar_maxpower = [];
for t = 1:T
    wind_maxpower = [wind_maxpower, pdf(t, "wind")];
    solar_maxpower = [solar_maxpower, pdf(t, "solar")];
end

A2 = -blkdiag(A2, diag(wind_maxpower), diag(solar_maxpower));


A3 = [];
for i = 1:T
    A3 = repmat(eye(T), 1, N);
end

% A4 = -A1

A5 = [];
for i = 1:N
    t = T_min(i);
    vec = [ones(1, t), zeros(1, T)];
    Agen = [];
    for j = 1:T
        Agen = [Agen; circshift(vec, j-1)];
    end
    Agen = Agen(:,t:end-1);
    A5 = blkdiag(A5, Agen);
end

% ------------------------------------------------------
% A6 -- runtime-on connection (x_jt - x_jt-1 = y_jt)
% Unclear on the boundaries

A6 = [];
for i = 1:N
    A6 = blkdiag(A6, eye(T) - diag(ones(1, T-1), -1));
end

% ------------------------------------------------------


A7 = zeros(N, N*T);
for i = 1:N
    A7(i, 1 + T*(i-1)) = 1;
end


% Assemble

A = [A1,            A2,             zeros(N*T);         % Upper bound on g
     zeros(N*T),    A1,             zeros(N*T);         % Upper bound on x
     zeros(N*T),    zeros(N*T),     A1;                 % Upper bound on y
    -A1,            zeros(N*T),     zeros(N*T);         % Lower bound on g  
     zeros(N*T),   -A1,             zeros(N*T);         % Lower bound on x
     zeros(N*T),    zeros(N*T),    -A1;                 % Lower bound on y
     zeros(N*T),    A6,            -A1;                 % 'On' and 'Running' connection
     zeros(N*T),   -A1,             A5;                 % Minimal uptime
    -A3,            zeros(T, N*T),  zeros(T, N*T);      % Meeting the demand
     zeros(N, N*T), A7,             zeros(N, N*T)       % Starting state: generators 1 and 2 are running; the rest is off
    ];     

%% Create vector b

v = [zeros(1, N*T), ones(1, 2*N*T), zeros(1, 5*N*T), -D, start]';

%% Clean up

% A predominantly consists of zeroes. Squeezing them out can save a lot of
% space -- therefore sparse representation.
A = sparse(A);

clear A1 A2 A3 A5 A6 A7 Agen t;

% b in constraints Ax=b has become v to not overwrite the network parameters 
result = solve_gurobi(N,T,Q,c,A,v);

%% If model feasible

schedule = reshape(result.x, [T, N, 3]);
