%load Data
clc;clear;close;
load Data;
k=size(Pos);
V=zeros(k(1),k(2));
SP=[zeros(185,1),B];
for i=1:2
temp=[Pos(i,2:k(2)),zeros(1,1)];
v=temp-Pos(i,:);
V(i,:)=v;
end

k=size(timestep);


k=size(Pos);
const=ones(1,k(2));
State=[Pos;V .*100;const];
b=size(SP);
%Train Parameters
C=zeros(b(1),5);
for i=1:b(1)
C(i,:)=regress(SP(i,1:6000)',State(:,1:6000)');
end


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
s.A=A;
s.Q=Q;
s.R=R;
s.H=C;

s.x=State(:,6000);
s.P=Q;
s.z=SP(:,6001);
s.x = s.A*s.x;
s.P = s.A * s.P;
s.P(1:2,:)=0;
s.P=s.P*s.A';
s.P(:,1:2)=0;
s.P=s.P+Q;
 K = s.P*s.H'/(s.H*s.P*s.H'+s.R);
 s.x = s.x + K*(s.z-s.H*s.x);
 s.P = s.P - K*s.H*s.P;
 pre=zeros(2,6000);
 pre(:,1)=s.x(3:4);
 %One step predict
 for i=2:6000
  s.x = s.A*s.x;
  s.z=SP(:,6000+i);
s.P = s.A * s.P;
s.P(1:2,:)=0;
s.P=s.P*s.A';
s.P(:,1:2)=0;
s.P=s.P+Q;
 K = s.P*s.H'/(s.H*s.P*s.H'+s.R);
 s.x = s.x + K*(s.z-s.H*s.x);
 s.P = s.P - K*s.H*s.P; 
 pre(:,i)=s.x(3:4);
 end
 
 for i=1:2
cc=corrcoef(pre(i,:),State(i+2,6001:12000))
CC(i)=cc(1,2);
end