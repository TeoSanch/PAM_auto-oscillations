function out = isOctavie(pext, fth)
% PAM 2017-2018 - Auto-oscillations ---------------------------------------
% argin pext vecteur colonne de pression extérieure - résonateur conique
% argin fth la f0 théorique à laquelle on va comparer la f0 trouvée par
% l'algorithme de yin.
% argout out 1 si le son octavie, -1 sinon.
% Cette fonction est adaptée aux résonateurs coniques qui "octavient", et 
% non pour les résonateurs cylindriques qui "quintoient".
% Pour adapter à la clarinette, changer le seuil.
% La fonction yin (disponible à http://audition.ens.fr/adc/) est requise
% pour cette fonction.
% -------------------------------------------------------------------------

% 0.
Fe = 44100;

% 1. calcul f0 
p.sr = Fe;
r=yin(pext,p);
[~, idx] = min(r.ap0);
f0 = 2^(r.f0(idx))*440; % fréquence donnée par algo de yin

% 2. seuillage
if f0 > 1.7*fth % 1.7*fth et pas 2*fth pour marge 
    out = 1;
else
    out = -1;
end
end