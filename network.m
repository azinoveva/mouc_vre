%% Problem Formulation

%Objective-related:
a = [16.19, 17.26, 16.6, 16.5, 19.7, 22.26, 27.74, 25.92, 27.27, 27.79];

b = [0.00048, 0.00031,  0.002,   0.00211,  0.00398, ... 
     0.00712, 0.000793, 0.00413, 0.002221, 0.00173];

C_run = [1000, 970, 700, 680, 450, 370, 480, 660, 665, 670];

C_start = [9000, 10000, 1100, 1120, 1800, 340, 520, 60, 60, 60];

%Constraint-related
D = [700,  750,  850,  950,  1000, 1100, ...
     1150, 1200, 1300, 1400, 1450, 1500, ...
     1400, 1300, 1200, 1150, 1000, 1100, ...
     1200, 1400, 1300, 1100, 900,  800];

G_max = [455, 455, 130, 130, 162, 80, 85, 55, 55, 55];

T_min = [8, 8, 5, 5, 6, 3, 3, 1, 1, 1];

N = 10; T = 24; % number of generators and time periods (24H)

%% Construct Q and c in z^TQz + c^Tz for price modeling

Q = [];

for i = 1:N
    Q = blkdiag(Q, a(i)*eye(T));
end

Q = sparse(blkdiag(Q, zeros(2*N*T)));

c = [repelem(b, T), repelem(C_run, T), repelem(C_start, T)]';


%% Construct the matrices A1 through A7:
% Set g = [g11, ..., g1T, ..., gNT]^T, 
%     x = [x11, ..., x1T, ..., xNT]^T
%     y = [y11, ..., y1T, ..., yNT]^T
% and z = [g, x, y]^T

A1 = [];
for i = 1:T
    A1 = blkdiag(A1, eye(N));
end

A2 = [];
for i = 1:N
    A2 = blkdiag(A2, -G_max(i)*eye(T));
end

A3 = [];
for i = 1:T
    A3 = repmat(-eye(T), 1, N);
end

A4 = -A1;

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

A6 = [];
for i = 1:T
    A6 = blkdiag(A6, -eye(N) + diag(ones(1, N-1), 1));
end

A7 = -diag(ones(1, N*T-1), 1);

%% Assemble the matrix A:

A = [A1,            A2,             zeros(N*T);
     A3,            zeros(T, N*T),  zeros(T, N*T);
     zeros(N*T),    A4,             A5     ;
     zeros(N*T),    A6,             A7     ];

% A predominantly consists of zeroes. Squeezing them out can save a lot of
% space -- therefore sparse representation.
A = sparse(A);

%% Create vector b

v = -[zeros(1, N*T), D, zeros(1, 2*N*T)]';

%% Clean up

clear A1 A2 A3 A4 A5 A6 A7 Agen t;

result = qp(N,T,Q,c,A,v);