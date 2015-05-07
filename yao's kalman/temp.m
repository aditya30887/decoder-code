%load Data
clc;clear;close;
load Data;
%Data contains Bineed Firing Rates, Position
s=size(Pos);
V=zeros(s(1),s(2));
SP=[zeros(size(B,1),1),B];

Ntest=3000; % number of testing Data
Ntrain=6000; % number of training Data

% Get Velocity for each time bins 
for i=1:2
temp1=[Pos(i,2:s(2)),zeros(1,1)];
v=temp1-Pos(i,:);
V(i,:)=v;
end




s=size(Pos);
const=ones(1,s(2));

%State Variables 
State=[Pos;V .*100;const];
trainO=SP(:,1:Ntrain);
trainS=State(:,1:Ntrain);
[para]=Kaltrain(trainO,trainS);
%Train Parameters
b=size(SP);
C=para.C;
A=para.A;
Q=para.Q;





%Train Parameters
R=para.R;

%First step
testO=SP(:,Ntrain+1:Ntrain+Ntest);
testS=State(:,Ntrain+1:Ntrain+Ntest);
FirstS=State(:,Ntrain+1);
[pre,CC]=Kaltest(testO,testS,FirstS);
