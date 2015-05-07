%Kalman Filter
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
% Training Data change every test section 
% train is a structure
% train.O is Training Observation n*T matrix, T=time bins
% train.S is Training State  m*T matrix, T=time bins
% test is a structure
% test.O is Testing Observation, a*p*T matrix, T=time bins,a=test section
% test.S is Testing State, a*q*T matrix, T=time bins
function [pre,cc]=ShiftKal(train,test)
NewPara=Kaltrain(train.O,train.S);

s=size(test.S);
pre=zeros(s(1),s(2),s(3));
cc=zeros(s(2),s(1));
NewTrainO=train.O;
NewTrainS=train.S;
for i=1:s(1)
testO(:,:)=test.O(1,:,:);
testS(:,:)=test.S(1,:,:);
FirstS=testS(:,1);
[pre1,cc1]=Kaltest(NewPara,testO,testS,FirstS);
pre(i,:,:)=pre1;
cc(:,i)=cc1;
NewTrainO=[NewTrainO,testO];
NewTrainO(:,1:s(3))=[];
NewTrainS=[NewTrainS,testS];
NewTrainS(:,1:s(3))=[];
NewPara=Kaltrain(NewTrainO,NewTrainS);

end