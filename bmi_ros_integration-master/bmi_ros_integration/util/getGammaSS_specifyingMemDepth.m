function [A, B, mu, impresp] = getGammaSS_specifyingMemDepth(Nb, Fs, memdepth)

mu = max(0,  min(1,  Nb/(memdepth*Fs)     ));

if mu == 1 || mu == 0
    fprintf('mu = %f\n', mu);
    error('gamma filter memory depth unachievable with specified order', mu);    
end

[A, B] = getGammaSS(Nb, mu);




x = zeros(Nb,1);
implength = round(memdepth*Fs*2);
Xout = zeros(implength, Nb);
for i = 1:implength
    if i ==1
        u = 1;
    else
        u = 0;
    end
    
    Xout(i, :) = x';
    x=A*x +B*u;
end
impresp = Xout;

% figure(323);
% plot((1:implength)./Fs, Xout);
% a = 3;
