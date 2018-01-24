function out = isOctavie(pext, fth)
% PAM 2017-2018 - Auto-oscillations ---------------------------------------
% argin pext vecteur colonne de pression extérieure - résonateur conique
% argin optional fth la f0 théorique à laquelle on va comparer la f0
% trouvée par yin.
% argout out 1  si le son octavie, -1 sinon.
% -------------------------------------------------------------------------

% 0.
Fe = 44100;
if nargin ~= 2
    fth = 220;
end

% 1. calcul f0 
thresh =0.7;
p.sr = Fe;
r=yin(pext,p);
[~, idx] = min(r.ap0);
f0 = 2^(r.f0(idx))*440; % fréquence donnée par algo de yin
fth*(2+thresh)
fth*(2-thresh)
if f0 < fth*(2+thresh) && f0 > fth*(2-thresh); % 1.7 et pas 2 pour marge
    out = 1;
else
    out = -1;
end
% fprintf('f0: %f - out: %f\n',f0,out);
end