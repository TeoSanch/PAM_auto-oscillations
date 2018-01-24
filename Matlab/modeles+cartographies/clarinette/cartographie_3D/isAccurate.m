function [out] = isAccurate(pext,seuil,fth)
% PAM 2017-2018 - Auto-oscillations ---------------------------------------
% argin pext vecteur colonne de pression extérieure à la clarinette
% argin optional seuil
% argin optional fth la f0 théorique à laquelle on va comparer la f0
% trouvée par yin. Si on ne donne pas de fth, on regarde les cents p/r à la
% f0 trouvée yin.
% argout out 1  si le son est proche de la note théorique, -1 sinon.
% -------------------------------------------------------------------------
Fe = 44100;
if nargin < 2
    fth = 0.1;
    seuil = 10;
elseif nargin <3
    fth = -0.1;
end

% 1. calcul f0 théorique
% calculer la hauteur de note théorique par rapport à la longueur du tube?
% fth = 1;

% 2. calcul f0 et cents
p.sr = Fe;
r=yin(pext,p);
[~, idx] = min(r.ap0);
f0 = 2^(r.f0(idx))*440 % fréquence donnée par algo de yin
if fth == -0.1
    cents = 100*(12*r.f0(idx)-round(12*r.f0(idx))); % cents par rapport à 
% f0 donné par algo de yin
else
    cents = 1200*log2(fth/f0);
end

% 3. seuillage
if abs(cents) < seuil
	out = 1;
else
	out = -1;
end
end