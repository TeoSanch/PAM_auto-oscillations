function v = violon(vb_e,Fb_e,beta, t_max, Fe)

bool_plot = false;
global dt Nh i

type_excitation = 0;
% 0 : frottement
% 1 : impulsion
% 2 : pincement

%% Paramètres de la corde
T = 39.15; % tension (en N)
mu = 2.34E-3; % masse linéique (en kg/m)
L = 0.33; % longueur (en m)
Zc = sqrt(mu*T); % impédance caractéristique
c = sqrt(T/mu); % vitesse de propagation des ondes

%% Paramètres de la loi de frottement
mu_s = 0.5; % coefficient de frottement statique (sans unité)
mu_d = 0.2; % coefficient de frottement dynamique (sans unité)
v0 = 0.025; % paramètre de forme de la courbe (en m/s)

%% Paramètres de jeu
% beta = 0.07; % position relative de l'archet le long de la corde (sans unité)
% Fb = 1; % force d'appui de l'archet sur la corde (en N)
% 
% vb = 0.05; % vitesse de l'archet (en m/s)*

%% Paramètres de simulation
Fe = 44100; % fréquence d'échantillonnage (en Hz)
dt = 1/Fe; % pas temporel

t_max = 4; % durée de la simulation (en s)
t = [0:dt:t_max]; % vecteur temps
Fb=Fb_e*ones(1,length(t));
vb=vb_e*ones(1,length(t));

%% Définition des fonctions de réflexion
tau1 = (2*beta*L)/c; % durée d'un aller/retour d'une onde entre l'archet et le chevalet (portion 1)
tau2 = (2*L*(1-beta))/c; % durée d'un aller/retour d'une onde entre l'archet et le doigt (portion 2)

tau1 = round(tau1/dt)*dt; % ajustement des retards (pour tomber sur des valeurs entières d'échantillons)
tau2 = round(tau2/dt)*dt; % ajustement des retards (pour tomber sur des valeurs entières d'échantillons)

Nh = round(1.2*max(tau1,tau2)/dt); % nombre d'échantillons pour les fonctions de réflexion (20% de marge)
th=[0:Nh-1]*dt; % support temporel des fonctions de réflexion

epsilon = 0.005; % parametre d'amortissement

for time = 1:length(th)
    if th(time) > tau1
        r1(time) = -(epsilon*tau1)/(pi*((th(time)-tau1)^2+(epsilon*tau1)^2)); 
        r2(time) = -(epsilon*tau2)/(pi*((th(time)-tau2)^2+(epsilon*tau2)^2));
    else
        r1(time) = 0;
        r2(time) = 0;
    end
end

r1 = r1/abs(sum(r1))/dt; % normalisation
r2 = r2/abs(sum(r2))/dt;

if bool_plot
    figure(1)
    clf
    subplot(2,1,1)
    plot(th,r1,'-')
    ylim([-1.1 0.1]*max([abs(r1) abs(r2)]))
    xlabel('t')
    ylabel('r_1')

    subplot(2,1,2)
    plot(th,r2,'-')
    ylim([-1.1 0.1]*max([abs(r1) abs(r2)]))
    xlabel('t')
    ylabel('r_2')
end
%% Initialisation des variables
vo1 = zeros(size(t)); % vitesse de l'onde aller (portion 1)
vi1 = zeros(size(t)); % vitesse de l'onde retour (portion 1)
vo2 = zeros(size(t)); % vitesse de l'onde aller (portion 2)
vi2 = zeros(size(t)); % vitesse de l'onde retour (portion 2)
vh = zeros(size(t)); % vitesse due aux ondes retour ("historique")

v = zeros(size(t)); % vitesse au point de frottement
f = zeros(size(t)); % force de frottement
deltav = zeros(size(t)); % vitesse relative (vitesse corde - vitesse archet)

stick = zeros(size(t)); % variable d'état ADHÉRENCE / GLISSEMENT
stick(1) = 1;

%% Définition des types d'excitation (autres que frottement)
% IMPULSION
f_impulse = zeros(length(t),1);
f_impulse(1,1)=1;

% PINCEMENT
f_pluck = zeros(length(t),1);
duree_pincement=0.01*Fe;
coeff_pente=3;
pente=coeff_pente*t(1:duree_pincement);
f_pluck(1:duree_pincement,1)=pente;

%% Résolution itérative
for i=1:length(t)
    
    % Calcul des ondes retour
    vi1(i) = convolution(vo1,r1);
    vi2(i) = convolution(vo2,r2);
    
    % Calcul de la vitesse due aux ondes retour ("historique")
    vh(i) = vi1(i) + vi2(i);
    
    switch type_excitation
        
        case 0 % frottement
            
            % coefficients du polynome
            A = -1/v0;
            B = 1+((vh(i)-vb(i))/v0)+((mu_d*Fb(i))/(2*Zc*v0));
            C = vb(i)-vh(i)-((Fb(i)*mu_s)/(2*Zc)) ;
            
            Delta = B^2-4*A*C; ; % calcul du discriminant
            
            % solutions (racines du polynome)
            deltav1 = (-B+sqrt(Delta))/(2*A);
            deltav2 = (-B-sqrt(Delta))/(2*A) ;
            
            
            % RECHERCHE DU POINT SOLUTION
            
            if stick(i) == 1 % y a-t-il ADHÉRENCE ?
                
                % si oui,
                deltav(i) = 0; % vitesse relative
                f(i) = 2*Zc*(deltav(i)+vb(i)-vh(i)); % calcul de la force correspondante
                
                if abs(f(i)) <= mu_s   % la force est-elle en dessous de la valeur limite d'adhérence ?
                
                % si oui,
                stick(i+1) = 1; % on restera en situation d'ADHÉRENCE à l'itération suivante
                
            else
                
                % sinon,
                stick(i) = 0; % on passe en situation de GLISSEMENT
                
            end
            
            end
            
            
            if stick(i) == 0 % y a-t-il GLISSEMENT ?
                
                % si oui,
                if Delta >= 0 % y a-t-il des solutions réelles à l'équation polynomiale ?
                    
                    % si oui,
                    deltav(i) = deltav1; % vitesse relative
                    f(i) = 2*Zc*(deltav(i)+vb(i)-vh(i)); % calcul de la force correspondante
                    
                    stick(i+1) = 0; % on restera en situation de GLISSEMENT à l'itération suivante
                    
                else
                    
                    % sinon,
                    stick(i) = 0; % on passe en situation d'ADHÉRENCE
                    deltav(i) = 0; % vitesse relative
                    f(i) = 2*Zc*(deltav(i)+vb(i)-vh(i)); % calcul de la force correspondante
                    stick(i+1) = 1; % on restera en situation d'ADHÉRENCE à l'itération suivante
                    
                end
                
            end
            
            
            % Décommenter pour afficher le point solution (intersection dynamique corde / loi de frottement)
            %plotSolution
            
        case 1 % impulsion
            
            f(i) = f_impulse(i);
            
        case 2 % pincement
            
            f(i) = f_pluck(i);
            
    end
    
    % Calcul des ondes aller
    vo1(i) = vi2(i) + f(i)/(2*Zc);
    vo2(i) = vi1(i) + f(i)/(2*Zc);
    
    % Calcul de la vitesse
    v(i) = vo1(i) + vi1(i) ;
    
    
end

%% Affichage des résultats
if bool_plot
    figure(2)

    subplot(2,1,1)
    hold all
    plot(t,v,'-')
    title('vitesse du point frotté')
    xlabel('t (s)')
    ylabel('v (m/s)')

    subplot(2,1,2)
    hold all
    plot(t,f,'-')
    title('force de frottement')
    xlabel('t (s)')
    ylabel('f (N)')
end
end