%load Data
clc;clear;close;
load Data;
%Data contains Bineed Firing Rates, Position

Ntest=6; % number of testing Windows
TestWindow=1000;% testing Window length
Ntrain=6000; % number of training Data

% Get Velocity for each time bins 

for i=1:2
V(i,:)=diff(Pos(i,:));
end
V=[V,zeros(2,1)];

s=size(Pos);
const=ones(1,s(2));
DeltaT=0.1;
State=[Pos;V/DeltaT;const];

train.O=B(:,1:Ntrain);
train.S=State(:,1:Ntrain);

for i=1:Ntest
test.O(i,:,:)=B(:,Ntrain+1+TestWindow*(i-1):Ntrain+TestWindow*i);
test.S(i,:,:)=State(:,Ntrain+1+TestWindow*(i-1):Ntrain+TestWindow*i);
end

[pre1,cc1]=EnvoKal(train,test,6/7,1/7);