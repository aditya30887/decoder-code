function [w] = myridge(X, Y, lambda)

% X and Y must be normalized beforehand
[m, l] = size(X);
[m, n] = size(Y);

Lambda = diag( ones(l,1).*lambda );
% Lambda = lambda.*eye(l, l);



w = [X;sqrt(Lambda)]\[Y;zeros(l, n)];


