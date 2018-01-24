function [pext] = clarinet(gamma, zeta, f0, t_max, Fe, plot_bool, sound_bool)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% La fonction clarinet prend en entrée :
%
% gamma : relatif à la pression injectée 
%         dans l'instrument
%         valeur typique ==> g_e = 0.6
%
% zeta_e : relatif à la force d'appui des
%          lèvres sur l'anche 
%          valeur typique ==> zeta_e=0.4
%
% f0 : fréquence fondamentale désirée
%
% t_max : durée du son
%
% Fe : fréquence d'échantillonnage
%
% La fonction clarinet retourne :
%
% pext : Un vecteur contenant la pression extérieure générée
%        par le modèle
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    gamma=0.6; % dï¿½bit
    zeta=0.4; % pression lï¿½vre
    t_max=4; % durÃ©e du son
end
if nargin ~= 6
    plot_bool = false;
    sound_bool = false;
end

fe=44100; % fréquence d'échantillonnage
ts=1/fe; % pas d'échantillonnage temporel
t=0:ts:t_max-ts; % vecteur temps
n=length(t); % durée temps (samples)

fr=2300; % fréquence de résonance de l'anche
wr=2*pi*fr; % pulsation propre de résonance de l'anche
qr=0.2; % facteur d'amortissement de l'anche
c=343; % célérité du son dans l'air
L=c/(4*f0); % Longueur du résonateur
R=0.007; % rayon du résonateur

D=round(2*fe*L/c); % retard, en échantillons, de la propagation de l'onde
                   % dans le résonateur
                   
lv=4*10^(-8);
lt=5.6*10^(-8);
CpCv=1.4;
alpha=2/(R*c^(3/2))*(sqrt(lv)+((CpCv)-1)*sqrt(lt));

%%% Définition de paramètres, voir l'article : %%%%%%%%%%%%%%%%
%%% "Real-time synthesis of clarinet-like instruments %%%%%%%%%
%%%  using digital impedance models" de Philippe Guillemain %%%

w1=c*pi*(1-(1/2))/L;
w2=c*pi*(2-(1/2))/L; 

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

bc0=1; 
a0a=((fe^2)/(wr^2))+((fe*qr)/(2*wr));
b1a=1/a0a;
a1a=((2*(fe^2)/(wr^2))-1)/(a0a);
a2a=(((fe*qr)/(2*wr))-((fe^2)/(wr^2)))/(a0a);

%%% Algorithme itératif %%%

x=zeros(n,1);
W=zeros(n,1);
ue=zeros(n,1);
pe=zeros(n,1);
pext=zeros(n,1);


for n=D+1:length(t)
	x(n)=b1a*pe(n-1)+a1a*x(n-1)+a2a*x(n-2);
	V=-a1*ue(n-1)-b0*ue(n-D)+a1*pe(n-1)-b0*pe(n-D);
	W=heaviside(1-gamma+x(n))*zeta*(1-gamma+x(n));
	ue(n)=0.5*sign(gamma-V)*(-bc0*W^2+W*sqrt((bc0*W)^2+4*abs(gamma-V)));
	pe(n)=bc0*ue(n)+V;
	pext(n)=(pe(n)+ue(n))-(pe(n-1)+ue(n-1));
end
if plot_bool
    %figure; %subplot(2,1,1);
    plot(t,pe,'linewidth',1);
    % set(gca,'fontsize',24)
%     xlabel('temps (s)'); ylabel('amplitude pression (Pa)')
%     title('Pression intï¿½rieure au cours du temps')
%     xlim([0 0.3])
%     subplot(2,1,2);
    plot(pext); title(sprintf('gamma = %s et xi = %s',gamma,zeta));
    xlim([0 7000]);
    ylabel('amplitude pextc'); ylim([-0.061 0.061]);
end
if sound_bool
    soundsc(pext,fe);
end
end