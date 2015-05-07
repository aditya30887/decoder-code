function [A, B] = getGammaSS(Nb, mu)

A = diag(repmat(1-mu, Nb, 1)) + diag(repmat(mu, Nb-1, 1), -1);
B = zeros(Nb, 1); B(1) = 1-mu;

