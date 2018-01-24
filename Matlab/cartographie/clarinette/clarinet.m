function [pext] = clarinet(gamma,xi,f0, t_max,Fe, plot_bool, sound_bool)
% PAM 2017-2018 - Auto-oscillations ---------------------------------------
% à partir de 2 param renvoie la pression extérieure d'un clarinette
% argin gamma débit
% argin xi pression lèvres
% argin t_max durée du son
% argin plot_ et sound_bool
% argin Fe fréquence d'échantillonage
% argout pext pression extérieure
% -------------------------------------------------------------------------

if nargin < 3
    gamma=0.6; % d�bit
    xi=0.4; % pression l�vre
    t_max=4; % durée du son
end
if nargin ~= 6
    plot_bool = false;
    sound_bool = false;
end

fe=44100; % fr�quence �chantillonnage
ts=1/fe; % time step
t=0:ts:t_max-ts; % vecteur temps
n=length(t);

fr=2300; % fr�quence mode anche
wr=2*pi*fr; % pulsation mode anche
qr=0.2;
c=343; % c�l�rit� du son
%L=0.5; % longueur du r�sonateur
L=c/(4*f0);
R=0.007; % rayon du tube cylindrique
theta=deg2rad(2);
xe=R/sin(theta/2);
%R=R*(1+5*L/(12*xe)); % rayon c�ne
% gamma=0.6; % d�bit
% xi=0.4; % pression l�vres
D=round(2*fe*L/c);

lv=4*10^(-8);
lt=5.6*10^(-8);
CpCv=1.4;
alpha=2/(R*c^(3/2))*(sqrt(lv)+((CpCv)-1)*sqrt(lt));

w1=c*pi*(1-(1/2))/L; % cylindre
w2=c*pi*(2-(1/2))/L; % cylindre
%w1=c*(12*pi*L+9*pi^2*xe+16*L)/(4*L*(4*L+3*pi*xe+4*xe)); % conique
%w2=c*(28*pi*L+49*pi^2*xe+16*L)/(4*L*(4*L+7*pi*xe+4*xe)); % conique


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

a1=(A12-sqrt(A12^2-F12^2))/(F12); % (15)
b0=(sqrt(2*F1*F2*(c1-c2)*(A12-sqrt(A12^2-F12^2))))/(F12); % (16)

Gp=1+(c/(2*fe*xe));

%bc0=1/Gp; % conical bore
bc0=1; % cylindrical bore
a0a=((fe^2)/(wr^2))+((fe*qr)/(2*wr));
b1a=1/a0a;
a1a=((2*(fe^2)/(wr^2))-1)/(a0a);
a2a=(((fe*qr)/(2*wr))-((fe^2)/(wr^2)))/(a0a);


x=zeros(n,1);
W=zeros(n,1);
ue=zeros(n,1);
pe=zeros(n,1);
pext=zeros(n,1);

%%% Je commence la boucle � D+1 pour pouvoir calculer ue(n-D)
%%% et pe(n-D), en vrai il faudrait utiliser un "circular buffer"
%%% pour �viter de commencer de D �chantillons en retard le signal

for n=D+1:length(t)
	x(n)=b1a*pe(n-1)+a1a*x(n-1)+a2a*x(n-2);
	V=-a1*ue(n-1)-b0*ue(n-D)+a1*pe(n-1)-b0*pe(n-D);
	W=heaviside(1-gamma+x(n))*xi*(1-gamma+x(n));
	ue(n)=0.5*sign(gamma-V)*(-bc0*W^2+W*sqrt((bc0*W)^2+4*abs(gamma-V)));
	pe(n)=bc0*ue(n)+V;
	pext(n)=(pe(n)+ue(n))-(pe(n-1)+ue(n-1));
end
if plot_bool
    %figure; %subplot(2,1,1);
    plot(t,pe,'linewidth',1);
    % set(gca,'fontsize',24)
%     xlabel('temps (s)'); ylabel('amplitude pression (Pa)')
%     title('Pression int�rieure au cours du temps')
%     xlim([0 0.3])
%     subplot(2,1,2);
    plot(pext); title(sprintf('gamma = %s et xi = %s',gamma,xi));
    xlim([0 7000]);
    ylabel('amplitude pextc'); ylim([-0.061 0.061]);
end
if sound_bool
    soundsc(pext,fe);
end
end