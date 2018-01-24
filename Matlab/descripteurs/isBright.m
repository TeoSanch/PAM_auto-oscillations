function out = isBright(p, seuil)
% PAM 2017-2018 - Auto-oscillations ---------------------------------------
% argin p vecteur colonne de pression extérieure à la clarinette
% argin seuil de brillance entre .5 et 1)
% argout out 1  si le son est brillant, -1 sinon.
% La "mirtoolbox" est requise pour cette fonction.
% -------------------------------------------------------------------------
seuil1 = 0.55;
seuil2 = 0.6;
seuil3 = 0.65;
seuil4 = 0.7;
seuil5 = 0.75;
seuil6 = 0.8;
seuil7 = 0.85;
seuil8 = 0.9;

% 1. p -> .wav
fe = 44100; audiowrite('tmp_isBright.wav',p,fe);

% 1. .wav -> mirbrightness
mirverbose(0);
mirb = get(mirbrightness('tmp_isBright.wav'),'Data');
mirb = mirb{1,1}{1,1};
bright = mean(mirb);
% 2. seuil
if bright < seuil1
    out = -7;
elseif bright >= seuil1 && bright < seuil2
    out = -6;
elseif bright >= seuil2 && bright < seuil3
    out = -5;
elseif bright >= seuil3 && bright < seuil4
    out = -4;
elseif bright >= seuil4 && bright < seuil5
    out = -3;
elseif bright >= seuil5 && bright < seuil6
    out = -2
elseif bright >= seuil6 && bright < seuil7
    out = -1
elseif bright >= seuil7 && bright < seuil8
    out = 0;
else
    out = 1;
end
end