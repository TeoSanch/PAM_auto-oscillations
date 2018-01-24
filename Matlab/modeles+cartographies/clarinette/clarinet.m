function [pext] = clarinet(gamma, zeta, f0, t_max, Fe, plot_bool, sound_bool)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% La fonction clarinet prend en entr�e :
%
% gamma : relatif � la pression inject�e 
%         dans l'instrument
%         valeur typique ==> g_e = 0.6
%
% zeta_e : relatif � la force d'appui des
%          l�vres sur l'anche 
%          valeur typique ==> zeta_e=0.4
%
% f0 : fr�quence fondamentale d�sir�e
%
% t_max : dur�e du son
%
% Fe : fr�quence d'�chantillonnage
%
% La fonction clarinet retourne :
%
% pext : Un vecteur contenant la pression ext�rieure g�n�r�e
%        par le mod�le
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    gamma=0.6; % d�bit
    zeta=0.4; % pression l�vre
    t_max=4; % durée du son
end
if nargin ~= 6
    plot_bool = false;
    sound_bool = false;
end

fe=44100; % fr�quence d'�chantillonnage
ts=1/fe; % pas d'�chantillonnage temporel
t=0:ts:t_max-ts; % vecteur temps
n=length(t); % dur�e temps (samples)

fr=2300; % fr�quence de r�sonance de l'anche
wr=2*pi*fr; % pulsation propre de r�sonance de l'anche
qr=0.2; % facteur d'amortissement de l'anche
c=343; % c�l�rit� du son dans l'air
L=c/(4*f0); % Longueur du r�sonateur
R=0.007; % rayon du r�sonateur

D=round(2*fe*L/c); % retard, en �chantillons, de la propagation de l'onde
                   % dans le r�sonateur
                   
lv=4*10^(-8);
lt=5.6*10^(-8);
CpCv=1.4;
alpha=2/(R*c^(3/2))*(sqrt(lv)+((CpCv)-1)*sqrt(lt));

%%% D�finition de param�tres, voir l'article : %%%%%%%%%%%%%%%%
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

%%% Algorithme it�ratif %%%

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
%     title('Pression int�rieure au cours du temps')
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