function vi = convolution(vo,r)
% Calcul par convolution de l'onde retour (vi)
% à l'itération i
% à partir d'une onde aller (vo)
% et de la fonction de réflexion (r)

global dt Nh i

if i<Nh
    vo_sub = [zeros(1,Nh-i) vo(1:i)]; % points utiles au produit de convolution (avec zero-padding)
else
    vo_sub = vo(i-Nh+1:i); % points utiles au produit de convolution
end

vi = dot(fliplr(vo_sub),r)*dt; % convolution
end