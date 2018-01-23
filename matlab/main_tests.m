%% Main_tests
% PAM 2017-2018 - Auto-oscillations ---------------------------------------
% permet d'écouter les synthèses sonores, de lancer différents tests
% -------------------------------------------------------------------------

%% Init. - var. globales
clear all; close all; clc;
addpath('desc/'); addpath('modeles'); mirverbose(0);
Fe = 44100; % 
bool_plot = false; % changer pour afficher le signal temporel

%% exemple: modèle de clarinette
% variables
gamma_cl = 0.8;
zeta_cl = 1;
f0_cl = 440;
% synthèse sonore
pext_cl = clarinet(gamma_cl,zeta_cl,f0_cl);
% listen & plot
soundsc(pext_cl,Fe);
if bool_plot
    figure; plot(pext_cl); 
    title('pression acoustique - clarinette'); xlabel('temps'); ylabel('amplitude');
end
% run all tests
concatTests(pext_cl,f0_cl);


% test sur son normal, de canard, quasi-périodique
[cl_n,~] = audioread('audio/clnt_normal.wav');
[cl_c,~] = audioread('audio/clnt_canard.wav');
[cl_qp,~] = audioread('audio/clnt_quasip.wav');
concatTests(cl_n,f0_cl);
concatTests(cl_c,f0_cl);
concatTests(cl_qp,f0_cl);

%% exemple: modèle de saxophone
% variables
gamma_sax = 0.7;
zeta_sax = 0.9;
f0_sax = 440;
% synthèse sonore
pext_sax = conique(gamma_sax,zeta_sax,f0_sax);
% listen & plot
soundsc(pext_sax,Fe);
if bool_plot
    figure; plot(pext_sax); 
    title('pression acoustique - saxophone'); xlabel('temps'); ylabel('amplitude');
end
% run all tests
concatTests(pext_sax,f0_sax);

%% exemple: modèle de violon
% variables
vb = 0.2; % vitesse archet
Fb = 15; % force appliquée
beta = 0.07; % position archet (en %)
% synthèse sonore
s_v = violon(vb,Fb,beta);
% listen & plot
soundsc(s_v,Fe);
if bool_plot
    figure; plot(s_v); 
    title('pression acoustique - violon'); xlabel('temps'); ylabel('amplitude');
end

%% fonctions annexes
function [] = concatTests(pext,f0)
% réalise l'ensemble des tests et affiche les résultats à la console
% tests: isSound; isAccurate ; isBright ; isCanard ; isOctavie ;
% isQuasiPeriodic ; isRough.

if isSound(pext) == 1
    fprintf(...
    'isSound: %.0f isAccurate: %.0f isBright: %.0f isCanard: %.0f isOctavie: %.0f isQuasiPeriodique: %.0f isRough: %.0f\n',...
        isSound(pext), isAccurate(pext,f0), isBright(pext,0.7), isCanard(pext), ...
        isOctavie(pext,f0), isQuasiPeriodic(pext), isRough(pext,200));
    % attention: valeurs seuils arbitraires.
else
    fprintf('no sound\n');
end
delete 'tmp*'; % delete all temporary files
end