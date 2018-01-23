function [out] = isAccurate(pext,fth)
% PAM 2017-2018 - Auto-oscillations ---------------------------------------
% argin pext vecteur colonne de pression extérieure à la clarinette
% argin fth la f0 théorique à laquelle on va comparer la freq. fondamentale
% trouvée par l'algorithme de yin.
% argout out 1 si le son est proche de la note théorique, -1 sinon.
% La fonction yin (disponible à http://audition.ens.fr/adc/) est requise
% pour cette fonction.
% -------------------------------------------------------------------------

% 0.
Fe = 44100;
seuil = 12; % en cents

% 1. calcul de f0, fondamentale de la note réellement jouée
p.sr = Fe;
r=yin(pext,p);
[~, idx] = min(r.ap0);
f0 = 2^(r.f0(idx))*440; % fréquence donnée par algo de yin

% 2. calcul de l'écart en cents
cents = 1200*log2(fth/f0);

% 3. seuillage
if abs(cents) < seuil
	out = 1;
else
	out = -1;
end
end