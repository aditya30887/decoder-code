% Train a Kalman Filter which allow
% x(t)=x(t-1)+v(t)

%This function using trainO and trainS to get a Kalman Filter 
% trainO is Training Observation n*T matrix, T=time bins
% trainS is Training State  m*T matrix, T=time bins
% DeltaT: velocity*DeltaT= position change, DeltaT in second   
%
% para is parameter. Contain A,Q,C,R which
% x = Ax + w       meaning the state vector x evolves during one time
%                  step by premultiplying by the "state transition
%                  matrix" A. There is also
%                  gaussian process noise w.
% y = Cx + v       meaning the observation vector y is a linear function
%                  of the state vector, and this linear relationship is
%                  represented by premultiplication by "observation
%                  matrix" C. There is also gaussian measurement
%                  noise v.
% where w ~ N(0,Q) meaning w is gaussian noise with covariance Q
%       v ~ N(0,R) meaning v is gaussian noise with covariance R

function [para]=KaltrainP(trainO,trainS,DeltaT)
s1=size(trainS);

%Observation Model
%Get Parameter C
para.C=trainO/trainS;
%Get covariance R
para.R=(para.C*trainS-trainO)*(para.C*trainS-trainO)' ./s1(2);

%Get State Model
if s1(1)==5
[para.A,para.Q]=getS5(trainS,DeltaT);
end

if s1(1)==7
   [para.A,para.Q]=getS7(trainS);
end 