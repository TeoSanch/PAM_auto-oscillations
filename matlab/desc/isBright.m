function out = isBright(p, seuil)
% PAM 2017-2018 - Auto-oscillations ---------------------------------------
% argin p vecteur colonne de pression extérieure à la clarinette
% argin seuil de brillance entre .5 et 1)
% argout out 1  si le son est brillant, -1 sinon.
% La "mirtoolbox" est requise pour cette fonction.
% -------------------------------------------------------------------------

% 1. p -> .wav
fe = 44100; audiowrite('tmp_isBright.wav',p,fe);

% 1. .wav -> mirbrightness
mirverbose(0);
mirb = get(mirbrightness('tmp_isBright.wav'),'Data');
mirb = mirb{1,1}{1,1};

% 2. seuil
if mean(mirb) > seuil
    out = 1;
else
    out = -1;
end
end