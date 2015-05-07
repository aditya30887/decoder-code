%Basic Kalman Filter Testing
%para contains all parameters A,Q,C,R which
%x = Ax + w       meaning the state vector x evolves during one time
%                  step by premultiplying by the "state transition
%                  matrix" A. There is also
%                  gaussian process noise w.
% y = Cx + v       meaning the observation vector y is a linear function
%                  of the state vector, and this linear relationship is
%                  represented by premultiplication by "observation
%                  matrix" H. There is also gaussian measurement
%                  noise v.
% where w ~ N(0,Q) meaning w is gaussian noise with covariance Q
%       v ~ N(0,R) meaning v is gaussian noise with covariance R
% testO is Testing Observation, p*T matrix, T=time bins
% testS is Testing State, q*T matrix, T=time bins
% FirstS: First Prediction, it should be known is BMI task. Like zero
% position
% pre: Prediction, q*T matrix, T=time bins
% CC: all correlation coef, q*1 Vector;

function [pre,CC]=Kaltest(para,testO,testS,FirstS)
s1=size(testS);
% Make the Kalman Filter
k.A=para.A;
k.Q=para.Q;
k.R=para.R;
k.H=para.C;
k.P=para.Q;
k.x=FirstS;

% Set the first prediction
pre=zeros(s1(1),s1(2));
pre(:,1)=FirstS;

% One Step prediction
for i=2:s1(2)
    k.z=testO(:,i);
     k=kalmanfilter(k);
     pre(:,i)=k.x;
end

% Test the results

CC=zeros(s1(1),1);
for i=1:s1(1)
cc=corrcoef(pre(i,:),testS(i,:));
CC(i)=cc(1,2);
end
