clc;clear;close;
load MAP1Zee03232010001.mat
S=size(Data_ts);
A=0;
A1=size(posx);
A2=fix(A1(1)/100)+1;
B=zeros(S(2),A2);
for i=1:S(2)
  clear A;
  A=fix(Data_ts(i).ts  .*10)+1;
  b=size(A);
  for j=1:b(1)
      B(i,A(j))=  B(i,A(j))+1;
  end
end

C=zeros(S(2),A2);
for i=2:S(2)
C(i,:)=[0,B(i,2:A2)];
end
SP=[B;C];
Pos=zeros(2,A2);
    for j=1:A2
        Pos(1,j)=posx((j-1)*100+1);
    end
    for j=1:A2
        Pos(2,j)=posy((j-1)*100+1);
    end

s=size(stb);
k=1;
for i=1:s(1)
    if stb(i,2)==1;
        timestep(k)=stb(i,1);
        k=k+1;
    end
end
timestep=fix(timestep .*10)+1;
save Data B Pos timestep SP
% B means Binned Firing Rates 100ms bin in this case
% Pos means Position
