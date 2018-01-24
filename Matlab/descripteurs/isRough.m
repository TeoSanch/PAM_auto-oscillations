function [out] = isRough(pext)
% PAM 2017-2018 - Auto-oscillations ---------------------------------------
% argin pext vecteur colonne de pression extérieure à la clarinette
% argin optional seuil
% argout out 1  si le son est rugueux, -1 sinon.
% -------------------------------------------------------------------------
mirverbose(0);
Fe = 44100;
% if nargin < 2
%     seuil = 2000;
% end
seuil1 = 10;
seuil2 = 50;
seuil3 = 100;
seuil4 = 500;
seuil5 = 1000;
seuil6 = 1500;
seuil7 = 2000;
seuil8 = 2500;

% 1. pext -> .wav
audiowrite('temp_isRough.wav',pext,Fe);

% 2. .wav -> mirroughness
a = mirroughness('temp_isRough.wav');
tmp_mirroughness = get(a,'Data');
mirrou = tmp_mirroughness{1,1}{1,1};
%out = mean(mirrou(:)); % debug
% 3. mirentropy -> seuillage
rough = mean(mirrou(:))
if rough < seuil1
    out = -7;
elseif rough >= seuil1 && rough < seuil2
    out = -6;
elseif rough >= seuil2 && rough < seuil3
    out = -5;
elseif rough >= seuil3 && rough < seuil4
    out = -4;
elseif rough >= seuil4 && rough < seuil5
    out = -3;
elseif rough >= seuil5 && rough < seuil6
    out = -2
elseif rough >= seuil6 && rough < seuil7
    out = -1
elseif rough >= seuil7 && rough < seuil8
    out = 0;
else
    out = 1;
end
%fprintf('roughness: %.2f - out: %.0f\n',out_tmp,out); % debug
end