function [pext] = basson(g_e, zeta_e, f0, t_max, Fe)
phi_e=0;
ts=1/Fe;
% t_max=5; 
t=0:ts:t_max-ts;
n=length(t);

fr=3150;
wr=2*pi*fr;
rho=1.2;
c=335;
H=7*10^(-3);
Phi=phi_e*ones(1,length(t));
qr=0.5;
R=0.0055;
L=c/(4*f0);
D=round(2*Fe*L/c);

xi=zeta_e*ones(1,length(t));
gamma=g_e*ones(1,length(t));
betax=7.5*10^(-4);
betau=6.1*10^(-3);

lv=4*10^(-8);
lt=5.6*10^(-8);
CpCv=1.4;
alpha=2/(R*c^(3/2))*(sqrt(lv)+((CpCv)-1)*sqrt(lt));

w1=c*pi*(1-(1/2))/L; % cylindre
w2=c*pi*(2-(1/2))/L; % cylindre

w_tilde1=w1/Fe;
w_tilde2=w2/Fe;

c1=cos(w_tilde1);
c2=cos(w_tilde2);

Fw1_carre=exp(-2*alpha*c*sqrt(w1/2)/L);
Fw2_carre=exp(-2*alpha*c*sqrt(w2/2)/L);

F1=Fw1_carre;
F2=Fw2_carre;

A1=F1*c1;
A2=F2*c2;

A12=A1-A2;
F12=F1-F2;

a1=(A12-sqrt(A12^2-F12^2))/(F12);
b0=(sqrt(2*F1*F2*(c1-c2)*(A12-sqrt(A12^2-F12^2))))/(F12);

xe=0;

Gp=1+(c/(2*Fe*xe));
Gm=1-(c/(2*Fe*xe));

%bc0=1/Gp; % conical bore
bc0=1; % cylindrical bore
bc1=-(a1+1)/Gp;
bc2=a1/Gp;
bc3=0;
bc4=0;

ac1=(a1*Gp+Gm)/Gp;
ac2=-(a1*Gm)/Gp;
ac3=0;
ac4=0;

a0a=((Fe^2)/(wr^2))+((Fe*qr)/(2*wr));
b1a=1/a0a;
a1a=((2*(Fe^2)/(wr^2))-1)/(a0a);
a2a=(((Fe*qr)/(2*wr))-((Fe^2)/(wr^2)))/(a0a);

x=zeros(n,1);
W=zeros(n,1);
ue=zeros(n,1);
pe=zeros(n,1);
pext=zeros(n,1);

for n=D+2:length(t)
    V=-a1*ue(n-1)-b0*ue(n-D)+a1*pe(n-1)-b0*pe(n-D);
    x(n)=b1a*(pe(n-1)+Phi(n)*betau*ue(n-1)^2)+a1a*x(n-1)+a2a*x(n-2);
    W=heaviside(1-gamma(n)+x(n))*((xi(n)*(1-gamma(n)+x(n)))/(sqrt((1+Phi(n)*betax*(1-gamma(n)+x(n))^2))));
    %ue(n)=W(n)*sign(gamma(n)-pe(n))*sqrt(abs(gamma(n)-pe(n)));
    ue(n)=0.5*sign(gamma(n)-V)*(-bc0*W^2+W*sqrt((bc0*W)^2+4*abs(gamma(n)-V)));
    pe(n)=bc0*ue(n)+V;
    pext(n)=(pe(n)+ue(n))-(pe(n-1)+ue(n-1));
end
end