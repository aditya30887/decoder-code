% Train a Basic Kalman Filter 
% This function using trainO and trainS to get a Kalman Filter 
% trainO is Training Observation n*T matrix, T=time bins
% trainS is Training State  m*T matrix, T=time bins
%
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

function [para]=Kaltrain(trainO,trainS)
s1=size(trainS);

%Get Parameter A,C
para.A=trainS(:,2:s1(2))/trainS(:,1:s1(2)-1);
para.C=trainO/trainS;


%Get covariance Q,R
para.Q=(para.A*trainS(:,1:s1(2)-1)-trainS(:,2:s1(2)))*...
(para.A*trainS(:,1:s1(2)-1)-trainS(:,2:s1(2)))'./(s1(2)-1);

para.R=(para.C*trainS-trainO)*(para.C*trainS-trainO)' ./s1(2);


