function out = isQuasiPeriodic(p)
% PAM 2017-2018 - Auto-oscillations ---------------------------------------
% argin p vecteur colonne de pression extérieure à la clarinette
% argout out 1  si le son est quasi-périodique, -1 sinon.
% La "mirtoolbox" est requise pour cette fonction.
% -------------------------------------------------------------------------

% 0.
mirverbose(0);
seuil = 10^(-4) ;% pour le saxophone 4*10^(-4);

% 1. calcul de la puissance
pwr = real(p.^p);

% 2. extraction enveloppe de la puissance
fe = 44100; audiowrite('tmp_QuasiPeriodic.wav',pwr,fe);
up = get(mirenvelope('tmp_QuasiPeriodic.wav'),'Data');
up = up{1,1}{1,1};

% 3. calcul du critère
epsilon = var(up(:))/mean(up(:))

% 4. seuillage
if epsilon < seuil
    out = -1;
else
    out = 1;
end
end