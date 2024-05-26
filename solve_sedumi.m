%% Courtesy of A.Kannan (HU Berlin) -- needs to be adapted!
%
% This function solves a QP subject to binary constraints
% of the form:
%
% min 0.5*y'*Q*y + c'*y
% x,z
% st: Ay <= b
% z \in {0,1}
% Note that y = [x;z]; is the vector of input variables.
%
% --INPUTS-----------------------------------------------------------------
%   Q       [n-by-n]  Hessian of the QP
%   c       [n-by-1]  Linear QP terms
%   A       [m-by-n]  Linear constraint matrix
%   b       [m-by-1]  Right hand side constraint vector
%   mbin    [scalar]  Number of binary variables (size(z))
%   opt     [integer] Algorithm used
%                     = 1, ADDM
%                     = 2, Barrier
%                     = 3, SDP
%                     = 4, CPLEX (standard solvers)
% --OUTPUTS----------------------------------------------------------------
%   yout    [n-by-1]  Optimal solution
%   fout    [scalar]  Optimal objective value
%   iter    [scalar]  Number of outer iterations
%
%   Aswin Kannan, Humboldt Univ. zu Berlin, Sep. 2023
%
%   The author thanks Prof. Uday Shanbhag, Penn State, who was responsible
%   for the initial ideas and several recommendations throughout. 
%
function result = solve_sedumi(network)
N = network.N;
T = network.T;
Q = network.Q_biobj;
c = network.c;
A = network.A;
b = network.b;

mbin = N*T*2;

n = size(c); m = size(A,1); nx  = n - mbin;
%   SDP
    %   min  0.5*(Q.X) + c'*x
    %  s,X,x,t,u
    %         Ax + s = b, u = 1,
    %         X_ii = x_i (i in binary)
    %           X - xx' >=0 (or)  [X x; t' u] >= 0 , s >= 0
    
    f = [Q c/2]';
    f = reshape(f,1,n*(n+1)); f = [zeros(m,1);f';zeros(n+1,1)];
    % vector arranged as s, reshaped(X, x) --> X(1,:),x1....,X(n,:),xn
    Amat = [eye(m), zeros(m,n^2+n),zeros(m,n+1)];
    for i = 1:n
        Amat(:,m+i*n+i) = A(:,i);
    end
    Amat = [Amat; [zeros(1,m+n^2+2*n),1]]; bm = [b;1];
    Xmat = zeros(n-nx,m+(n+1)^2,1);
    for i = nx+1:n
        Xmat(i,m+(i-1)*(n+1)+i) = 1; Xmat(i,m+i*n+i) = -1;
    end
    Amat = [Amat;Xmat]; bm = [bm;zeros(n,1)];
    % Finally for the binary constraint
    K.f = 0; K.l = m; K.q = 0; K.r = 0; K.s = n+1;
    % Use Sedumi after reformulation
    [out,~,INFO] = sedumi(Amat,bm,f,K);
    yout = out(m+n^2+n+1:m+n^2+2*n,1);
    fout = 0.5*yout'*Q*yout+c'*yout;
    iter = INFO.iter;

    result = yout;
end

