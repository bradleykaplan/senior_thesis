mu=1;
lambda=1;
%A=[[-2*lambda,0,2*lambda,0,0,0];[2*mu,-(2*lambda+2*mu),0,0,2*lambda,0];[0,0,-(2*lambda+2*mu),2*lambda,0,2*lambda];[0,4*lambda,0,-4*lambda,0,0];[0,0,4*mu,0,-4*mu,0];[0,4*mu,0,0,0,-4*mu]];
A=[[-lambda,.5*lambda,.5*lambda,0,0,0];[mu,-(lambda+mu),0,0,.5*lambda,.5*lambda];[0,0,-(lambda+mu),mu,.5*lambda,.5*lambda];[0,lambda,lambda,-2*lambda,0,0];[0,0,2*mu,0,-2*mu,0];[0,2*mu,0,0,0,-2*mu]];
T=7;
dt= .01;
time_vect=0:dt:T;
ntimes=length(time_vect);

P=zeros(ntimes,6);
P(1,:)=[0,0,0,1,0,0];

for k=2:ntimes
    P(k,:)=P(k-1,:)+dt*P(k-1,:)*A;
end

figure;
plot(time_vect,P(:,1),'b');
hold on
plot(time_vect,P(:,2),'b');
plot(time_vect,P(:,3),'b');
plot(time_vect,P(:,4),'b');
plot(time_vect,P(:,5),'b');
plot(time_vect,P(:,6),'b');
%plot(P(:,1)+P(:,2)+P(:,3)+P(:,4)+P(:,5)+P(:,6));