% Kalman Filter
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
% C,R change with different testing section in this function
% train is a structure
% train.O is Training Observation n*T matrix, T=time bins
% train.S is Training State  m*T matrix, T=time bins
% test is a structure
% test.O is Testing Observation, p*T matrix, T=time bins
% test.S is Testing State, q*T matrix, T=time bins
% alpha controls learing rate for C, alpha should between 0 and 1
% beta controls learing rate for R, beta should between 0 and 1
% window is window length for each testing section 
% overlap

function [pre,cc]=EnvoKal(train,test,alpha,beta,window,overlap)

if alpha>1
    error('alpha should between 0 and 1');
else if alpha<0
    error('alpha should between 0 and 1');
   
    else if beta<0
    error('beta should between 0 and 1');
    else if beta>1
    error('beta should between 0 and 1');
        end
        end
    end
end


NewPara=Kaltrain(train);
s=size(test.S);
s1=size(train.O);

section=s(2)/window;
if section ~= fix(section)
    error('Testing Data cannot separate using this window')
end

if overlap>s1(2)
    error('Overlap should shorter than training data')
end

NewTrain.O=[zeros(s1(1),window),train.O(:,s1(2)-overlap+1:s1(2))];
NewTrain.S=[zeros(s(1),window),train.S(:,s1(2)-overlap+1:s1(2))];
cc=zeros(s(1),section);

for i=1:section
    % Get Testing Data
NewTest.O(:,:)=test.O(:,1+(i-1)*window:i*window);
NewTest.S(:,:)=test.S(:,1+(i-1)*window:i*window);
    %Testing
FirstS=NewTest.S(:,1);
[pre1,cc1]=Kaltest(NewPara,NewTest.O,NewTest.S,FirstS);
pre(:,1+(i-1)*window:i*window)=pre1;
cc(:,i)=cc1;
    %Get new traing data
NewTrain.O=[NewTrain.O,NewTest.O];
NewTrain.O(:,1:window)=[];
NewTrain.S=[NewTrain.S,NewTest.S];
NewTrain.S(:,1:window)=[];
    %Training
para1=Kaltrain(NewTrain);
    %Update parameters
NewPara.C=NewPara.C .*alpha+para1.C .*(1-alpha);
NewPara.R=NewPara.R .*beta+para1.R .*(1-beta);
end