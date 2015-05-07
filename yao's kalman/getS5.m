%This function only used for function KaltrainP
%Get a state model which S=[x,y,vx,vy,constant];
%make sure x(t)=x(t-1)+v(t-1); y(t)=y(t-1)+y(t-1) 

function [A,Q]=getS5(trainS,DeltaT)
s1=size(trainS);


A1=trainS(3:4,2:s1(2))/trainS(3:4,1:s1(2)-1);

%Make  State Model 
A(1,:)=[1,0,DeltaT,0,0];
A(2,:)=[0,1,0,DeltaT,0];
A(5,:)=[0,0,0,0,1];
A(3,:)=[0,0,A1(1,1),A1(1,2),0];
A(4,:)=[0,0,A1(2,1),A1(2,2),0];



Q1=(A1*trainS(3:4,1:s1(2)-1)-trainS(3:4,2:s1(2)))*...
(A1*trainS(3:4,1:s1(2)-1)-trainS(3:4,2:s1(2)))'./(s1(2)-1);

Q=zeros(5,5);
Q(3:4,3:4)=Q1;

