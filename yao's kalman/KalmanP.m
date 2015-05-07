%load Data
clc;clear;close;
load Data;
s=size(Pos);
V=zeros(s(1),s(2));

SP=[zeros(185,1),B];
for i=1:2
temp=[Pos(i,2:s(2)),zeros(1,1)];
v=temp-Pos(i,:);
V(i,:)=v;
end

s=size(timestep);


s=size(Pos);
const=ones(1,s(2));
State=[Pos;V .*100;const];
b=size(SP);
C=zeros(b(1),5);
for i=1:b(1)
C(i,:)=regress(SP(i,1:6000)',State(:,1:6000)');
end

%Train Parameters
A=zeros(5,5);
A1=zeros(2,2);
for i=1:2
A1(i,:)=regress(State(i+2,2:6000)',State(3:4,1:5999)');
end
A(1,:)=[1,0,0.01,0,0];
A(2,:)=[0,1,0,0.01,0];
A(5,:)=[0,0,0,0,1];
A(3,:)=[0,0,A1(1,1),A1(1,2),0];
A(4,:)=[0,0,A1(2,1),A1(2,2),0];

Q1=0;
for i=1:5999
Q1=(A1*State(3:4,i)-State(3:4,i+1))*(A1*State(3:4,i)-State(3:4,i+1))'+Q1;
end
Q1=Q1 ./5999;

S1=A*State(:,1:5999);

Q=zeros(5,5);
Q(3,3)=Q1(1,1);
Q(3,4)=Q1(1,2);
Q(4,3)=Q1(2,1);
Q(4,4)=Q1(2,2);


R=0;
for i=1:5999
R=(C*State(:,i)-SP(:,i))*(C*State(:,i)-SP(:,i))'+R;
end
R=R ./5999;

%First step
k.A=A;
k.Q=Q;
k.R=R;
k.H=C;
k.x=State(:,6000);
k.P=Q;
k.z=SP(:,6001);
s=kalmanfilter(k);
predict=zeros(5,1000);
predict(:,1)=s.x;
%One step predict
for i=2:3000
    s.z=SP(:,6000+i);
    s=kalmanfilter(s);
    
    predict(:,i)=s.x;
end

plot(predict(2,:));
hold on
plot(State(2,6001:7000+2000))
for i=1:4
cc=corrcoef(predict(i,:),State(i,6001:7000+2000))
CC(i)=cc(1,2);
end