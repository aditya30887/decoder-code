%load Data
clc;clear;close;
load Data;
%Data contains Bineed Firing Rates, Position
s=size(Pos);
V=zeros(s(1),s(2));
SP=[zeros(size(B,1),1),B];

training_per = 0.6; 

Ntest=size(B,2) - round(training_per * size(B,2)); % number of testing Data
Ntrain=round(training_per * size(B,2)); % number of training Data

% Get Velocity for each time bins 
for i=1:2
temp=[Pos(i,2:s(2)),zeros(1,1)];
v=temp-Pos(i,:);
V(i,:)=v;
end




s=size(Pos);
const=ones(1,s(2));
scale=100;
%State Variables 
State=[Pos;V*scale;const];

%Train Parameters
trainO=SP(:,1:Ntrain);
trainS=State(:,1:Ntrain);
[para]=KaltrainP(trainO,trainS,scale);

%Testing 
testO=SP(:,Ntrain+1:Ntrain+Ntest);
testS=State(:,Ntrain+1:Ntrain+Ntest);
FirstS=testS(:,1);
[pre,CC]=Kaltest(para,testO,testS,FirstS);
