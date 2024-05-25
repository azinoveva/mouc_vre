function result = solve_sedumi_alt(network)
%SOLVE_SEDUMI_ALT Summary of this function goes here
%   Detailed explanation goes here
%% Setup
Q = network.Q_biobj;
c = network.c;

A = network.A;
b = network.b;

n = length(c); 
m = size(A, 1);

%% Homogenize and express the objective function in terms of a lifted variable

Q_hat = zeros(n+1, n+1);

% the problem formulation is usually for 1/2 z'Qz; 
% whereas I don't have the 1/2 coefficient in the objective function
Q_hat(2:end, 2:end) = Q;
Q_hat(2:end, 1) = 0.5*c;
Q_hat(1, 2:end) = 0.5*c';

%% Do the same for constraints

Amat = cell(m,1);
for i = 1:m
    A_i = zeros(n+1, n+1);
    A_i(1, 1) = b(i);
    A_i(2:end, 1) = -A(i, :)';
    A_i(1, 2:end) = -A(i, :);
    Amat{i} = sparse(A_i);
end


% Convert the problem to SeDuMi form
% C must be a vector of the unique elements in the upper triangle of the matrix
c_sedumi = svec(Q_hat);

% A_i must be concatenated into a matrix where each column is svec(A_i)
A_sedumi = [];
for i = 1:m
    A_sedumi = [A_sedumi, svec(Amat{i})];
end

% b_sedumi is the vector of constraints
b_sedumi = zeros(m, 1);

% K solution cone
K.f = 0; K.l = m; K.q = 0; K.r = 0; K.s = n+1;

% Solve the SDP using SeDuMi
[x, y, info] = sedumi(A_sedumi, b_sedumi, c_sedumi, K);

% Extract solution
Z_opt = smat(x);
result = Z_opt(2:end, 1); % Optimal solution for the original z

end

function v = svec(X)
    % This function vectorizes a symmetric matrix X.
    % Only the upper triangular part (including diagonal) is considered.

    % Get the size of the matrix
    [n, ~] = size(X);

    % Initialize the vector v
    v = [];

    % Iterate over the upper triangular part of X
    for i = 1:n
        for j = i:n
            if i == j
                v = [v; X(i, j)];
            else
                v = [v; sqrt(2) * X(i, j)];
            end
        end
    end
end

function X = smat(v)
    % This function reconstructs a symmetric matrix X from its vectorized form v.
    
    % Determine the size of the original matrix
    n = (-1 + sqrt(1 + 8 * length(v))) / 2;

    % Initialize the matrix X
    X = zeros(n, n);

    % Counter for the elements in vector v
    k = 1;

    % Iterate over the upper triangular part of X
    for i = 1:n
        for j = i:n
            if i == j
                X(i, j) = v(k);
            else
                X(i, j) = v(k) / sqrt(2);
                X(j, i) = X(i, j);
            end
            k = k + 1;
        end
    end
end

