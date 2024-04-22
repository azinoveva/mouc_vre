%% Courtesy of A.Kannan (HU Berlin) -- needs to be adapted!

function [outputArg1] = sedumi(model)
%SEDUMI Summary of this function goes here
%   Detailed explanation goes here
    %   SDP
    %   min  0.5*(Q.X) + c'*x
    %  s,X,x,t,u
    %         Ax + s = b, u = 1,
    %         X_ii = x_i (i in binary)
    %           X - xx' >=0 (or)  [X x; t' u] >= 0 , s >= 0
    f = [0.5*Q c]';
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
end

