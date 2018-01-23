function out = isCanard(pext)
% PAM 2017-2018 - Auto-oscillations ---------------------------------------
% argin pext vecteur colonne de pression extérieure à la clarinette
% argout out 1  si le son a la caractéristique d'un "canard", -1 sinon.
% La "mirtoolbox" est requise pour cette fonction.
% -------------------------------------------------------------------------

% 1. pext -> .wav
Fe = 44100;
audiowrite('tmp_isCanard.wav',pext,Fe);

% 2. .wav -> mirkurtosis + mirenvelope
mirverbose(0);
mirkur = get(mirkurtosis('tmp_isCanard.wav','Frame'),'Data');
mirenv = get(mirenvelope('tmp_isCanard.wav','Frame'),'Data');

vect_kur = cell2mat(mirkur{1,1}{1,1}); % transform data into matrix
vect_env = mirenv{1,1}{1,1};

% 3. mirkurtosis + mirenvelope -> seuillage
if max(vect_kur(:)) >= 20 && max(vect_env(:)) >= 0.013
    out = 1;
else 
    out = -1;
end
end