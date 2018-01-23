function pext = conique(gamma_e,zeta_e,f0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Cylindrique %%%%%%%%%%%%%%%%%
%%%%%%% Pour comprendre le programme, %%%%%%%%
%%%% se référer à l'article de Guillemain %%%%
%%% (et surtout la partie D pour la boucle)%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bool_plot = false;
fe=44100; % fréquence échantillonnage
ts=1/fe; % time step
t_max=4; % durée du son
t=0:ts:t_max-ts; % vecteur temps
n=length(t);

fr=2500; % fréquence mode anche
wr=2*pi*fr; % pulsation mode anche
qr=0.2;
c=343; % célérité du son
%f0=110;
% L=0.8; % longueur du résonateur
L=c/(4*f0);
R=0.004; % rayon du tube cylindrique

theta=deg2rad(2);
xe=R/sin(theta/2);
R=R*(1+(5*L)/(12*xe)); % rayon cône

%gamma=0.5; % débit
gamma=gamma_e*ones(1,length(t));
%xi=0.5; % pression lèvres
zeta=zeta_e*ones(1,length(t));
D=round(2*fe*L/c);

lv=4*10^(-8);
lt=5.6*10^(-8);
CpCv=1.4;
alpha=2/(R*c^(3/2))*(sqrt(lv)+((CpCv)-1)*sqrt(lt));

%w1=c*pi*(1-(1/2))/L; % cylindre
%w2=c*pi*(2-(1/2))/L; % cylindre
w1=c*(12*pi*L+9*pi^2*xe+16*L)/(4*L*(4*L+3*pi*xe+4*xe)); % conique
w2=c*(28*pi*L+49*pi^2*xe+16*L)/(4*L*(4*L+7*pi*xe+4*xe)); % conique


w_tilde1=w1/fe;
w_tilde2=w2/fe;

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

Gp=1+(c/(2*fe*xe));
Gm=1-(c/(2*fe*xe));

bc0=1/Gp; % conical bore
%bc0=1; % cylindrical bore
bc1=-(a1+1)/Gp;
bc2=a1/Gp;
bcD=-b0/Gp;
bcD1=b0/Gp;
ac1=(a1*Gp+Gm)/Gp;
ac2=-(a1*Gm)/Gp;
acD=-(b0*Gm)/Gp;
acD1=b0;
a0a=((fe^2)/(wr^2))+((fe*qr)/(2*wr));
b1a=1/a0a;
a1a=((2*(fe^2)/(wr^2))-1)/(a0a);
a2a=(((fe*qr)/(2*wr))-((fe^2)/(wr^2)))/(a0a);


x=zeros(n,1);
W=zeros(n,1);
ue=zeros(n,1);
pe=zeros(n,1);
pext=zeros(n,1);

%%% Je commence la boucle à D+1 pour pouvoir calculer ue(n-D)
%%% et pe(n-D), en vrai il faudrait utiliser un "circular buffer"
%%% pour éviter de commencer de D échantillons en retard le signal

for n=D+2:length(t)
    x(n)=b1a*pe(n-1)+a1a*x(n-1)+a2a*x(n-2);
    %V=-a1*ue(n-1)-b0*ue(n-D)+a1*pe(n-1)-b0*pe(n-D);
    V=bc1*ue(n-1)+bc2*ue(n-2)+bcD*ue(n-D)+bcD1*ue(n-D-1)+...
        ac1*pe(n-1)+ac2*pe(n-2)+acD*pe(n-D)+acD1*pe(n-D-1);
    W=heaviside(1-gamma(n)+x(n))*zeta(n)*(1-gamma(n)+x(n));
    ue(n)=0.5*sign(gamma(n)-V)*(-bc0*W^2+W*sqrt((bc0*W)^2+4*abs(gamma(n)-V)));
    pe(n)=bc0*ue(n)+V;
    pext(n)=(pe(n)+ue(n))-(pe(n-1)+ue(n-1));
end


if bool_plot
    figure;
    plot(t,pe,'linewidth',1)
    set(gca,'fontsize',24)
    xlabel('temps (s)','fontsize',24)
    ylabel('amplitude pression (Pa)','fontsize',24)
    title('Pression intérieure au cours du temps','fontsize',36);
    %xlim([0 0.2])
    % figure;
    % plot(pext)
end
