%This function only used for function KaltrainP
%Get a state model which S=[x,y,vx,vy,ax,ay,constant];
%make sure x(t)=x(t-1)+v(t-1); y(t)=y(t-1)+y(t-1)
% v(t)=v(t-1)+a(t-1)
function [A,Q]=getS7(trainS)
s1=size(trainS);


% Make  State Model 
A1=trainS(5:6,2:s1(2))/trainS(5:6,1:s1(2)-1);
A(1,:)=[1,0,1,0,0,0,0];
A(2,:)=[0,1,0,1,0,0,0];
A(3,:)=[0,0,1,0,1,0,0];
A(4,:)=[0,0,0,1,0,1,0];
A(7,:)=[0,0,0,0,0,0,1];
A(5,:)=[0,0,0,0,A1(1,1),A1(1,2),0];
A(6,:)=[0,0,0,0,A1(2,1),A1(2,2),0];


Q1=(A1*trainS(5:6,1:s1(2)-1)-trainS(5:6,2:s1(2)))*...
(A1*trainS(5:6,1:s1(2)-1)-trainS(5:6,2:s1(2)))'./(s1(2)-1);

Q=zeros(7,7);
Q(5:6,5:6)=Q1;
