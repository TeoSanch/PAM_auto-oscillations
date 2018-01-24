function [pext] = basson(g_e, zeta_e, f0, t_max, Fe)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% La fonction basson prend en entrée :
%
% g_e : gamma, relatif à la pression injectée 
%       dans l'instrument
%       valeur typique ==> g_e = 0.6
%
% zeta_e : zeta, relatif à la force d'appui des
%          lèvres sur l'anche 
%       valeur typique ==> zeta_e=0.4
%
% f0 : fréquence fondamentale désirée
%
% t_max : durée du son
%
% Fe : fréquence d'échantillonnage
%
% La fonction basson retourne :
%
% pext : Un vecteur contenant la pression extérieure générée
%        par le modèle
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

phi_e=0; % rapport entre surface du jet et surface à l'entrée du résonateur
ts=1/Fe; % pas d'échantillonnage temporel
t=0:ts:t_max-ts; % vecteur temps
n=length(t); % durée temps (samples)

fr=3150; % fréquence de résonance de l'anche
wr=2*pi*fr; % pulsation propre de résonance de l'anche
rho=1.2; % masse volumique de l'air
c=335; % célérité dans l'air
H=7*10^(-3); % Hauteur entre les deux anches
Phi=phi_e*ones(1,length(t)); % vecteur Phi
qr=0.5; % facteur d'amortissement de l'anche
R=0.0055; % rayon du résonateur
L=c/(4*f0); % Longueur du résonateur
D=round(2*Fe*L/c); % retard, en échantillons, de la propagation de l'onde
                   % dans le résonateur

xi=zeta_e*ones(1,length(t)); % vecteur zeta
gamma=g_e*ones(1,length(t)); % vecteur gamma
betax=7.5*10^(-4); %
betau=6.1*10^(-3); %

lv=4*10^(-8);
lt=5.6*10^(-8);
CpCv=1.4;
alpha=2/(R*c^(3/2))*(sqrt(lv)+((CpCv)-1)*sqrt(lt));

%%% Définition des paramètres, voir l'article : %%%%%%%%%%%%%%%%%%%%%
%%% "A Digital Synthesis Model of Double-Reed Wind Instruments" %%%%
%%% de Philippe Guillemain %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


w1=c*pi*(1-(1/2))/L; % première fréquence
w2=c*pi*(2-(1/2))/L; % seconde fréquence

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

bc0=1;
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


%%% Algorithme itératif %%%

x=zeros(n,1);
W=zeros(n,1);
ue=zeros(n,1);
pe=zeros(n,1);
pext=zeros(n,1);

for n=D+2:length(t)
    V=-a1*ue(n-1)-b0*ue(n-D)+a1*pe(n-1)-b0*pe(n-D);
    x(n)=b1a*(pe(n-1)+Phi(n)*betau*ue(n-1)^2)+a1a*x(n-1)+a2a*x(n-2);
    W=heaviside(1-gamma(n)+x(n))*((xi(n)*(1-gamma(n)+x(n)))/(sqrt((1+Phi(n)*betax*(1-gamma(n)+x(n))^2))));
    ue(n)=0.5*sign(gamma(n)-V)*(-bc0*W^2+W*sqrt((bc0*W)^2+4*abs(gamma(n)-V)));
    pe(n)=bc0*ue(n)+V;
    pext(n)=(pe(n)+ue(n))-(pe(n-1)+ue(n-1));
end
end

% soundsc(pext,fe)