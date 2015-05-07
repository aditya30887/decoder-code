%Refit Kalman Filter Testing
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
% pre: Prediction, 2*T matrix, T=time bins, 2 demension of velocity
% CC: all correlation coef, q*1 Vector;

function [pre,CC]=ReKaltest(para,testO,testS,FirstS)
s1=size(testS);
% Make the Kalman Filter
s.A=para.A;
s.Q=para.Q;
s.R=para.R;
s.H=para.C;
s.P=para.Q;
s.x=FirstS;

% Set the first prediction
pre=zeros(s1(1),s1(2));
pre(:,1)=FirstS(3:4);

% One Step prediction
for i=2:s1(2)
    s.x = s.A*s.x;
  s.z=testO(:,i);
s.P = s.A * s.P;
s.P(1:2,:)=0;
s.P=s.P*s.A';
s.P(:,1:2)=0;
s.P=s.P+s.Q;
 K = s.P*s.H'/(s.H*s.P*s.H'+s.R);
 s.x = s.x + K*(s.z-s.H*s.x);
 s.P = s.P - K*s.H*s.P; 
 pre(:,i)=s.x(3:4);
end

% Test the results

CC=zeros(s1(1),1);
for i=1:s1(1)
cc=corrcoef(pre(i,:),testS(i,:));
CC(i)=cc(1,2);
end
