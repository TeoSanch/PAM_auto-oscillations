function [out] = isSound(pext)
% PAM 2017-2018 - Auto-oscillations ---------------------------------------
% argin pext vecteur colonne de pression extérieure à la clarinette
% argout out = 1 s'il y a un son de joué, -1 sinon.
% -------------------------------------------------------------------------

% pression analyse
pext = pext(:); % force à être une colonne
pa = pext(floor(length(pext)*3/4):end); % ne pas prendre début (transitoire)

% critère
if max(abs(pa)) > 7*mean(pa) && max(abs(pa)) >= 10^(-3)
    out = 1;
else
    out = -1;
end
end