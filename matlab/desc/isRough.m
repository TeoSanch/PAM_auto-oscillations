function [out] = isRough(pext,seuil)
% PAM 2017-2018 - Auto-oscillations ---------------------------------------
% argin pext vecteur colonne de pression extérieure à la clarinette
% argin seuil
% argout out 1  si le son est rugueux, -1 sinon.
% La "mirtoolbox" est requise pour cette fonction.
% -------------------------------------------------------------------------

% 0.
mirverbose(0);
Fe = 44100;
if nargin < 2
    seuil = 200; % par exemple
end

% 1. pext -> .wav
audiowrite('tmp_isRough.wav',pext,Fe);

% 2. .wav -> mirroughness
tmp_mirroughness = get(mirroughness('tmp_isRough.wav'),'Data');
mirrou = tmp_mirroughness{1,1}{1,1};

% 3. mirroughness -> seuillage
if mean(mirrou(:)) > seuil
    out = 1;
else
    out = -1;
end
end