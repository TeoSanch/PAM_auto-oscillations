function pext = saxophone(gamma, zeta, f0, t_max, Fe)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% La fonction saxophone prend en entr�e :
%
% gamma : relatif � la pression inject�e 
%         dans l'instrument
%         valeur typique ==> g_e = 0.55
%
% zeta_e : relatif � la force d'appui des
%          l�vres sur l'anche 
%          valeur typique ==> zeta_e=0.5
%
% f0 : fr�quence fondamentale d�sir�e
%
% t_max : dur�e du son
%
% Fe : fr�quence d'�chantillonnage
%
% La fonction saxophone retourne :
%
% pext : Un vecteur contenant la pression ext�rieure g�n�r�e
%        par le mod�le
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    ts=1/Fe; % time step
    t=0:ts:t_max-ts; % vecteur temps
    n=length(t); % dur�e du temps (samples)

    fr=2500; % fr�quence de r�sonance de l'anche
    wr=2*pi*fr; % pulsation propre de r�sonance de l'anche
    qr=0.2; % facteur d'amortissement de l'anche
    c=343; % c�l�rit� du son dans l'air
    L=c/(4*f0); % Longueur du tube
    R=0.004; % rayon du r�sonateur

    theta=deg2rad(1.5); % angle de d�viation du r�sonateur
    xe=R/sin(theta/2); 
    R=R*(1+(5*L)/(12*xe)); % rayon r�sonateur approxim�

    gamma=ones(1,length(t))*gamma; % vecteur gamma
    zeta=ones(1,length(t))*zeta; % vecteur zeta
    D=round(2*Fe*L/c); % retard, en �chantillons, de la propagation de l'onde
                       % dans le r�sonateur

    lv=4*10^(-8);
    lt=5.6*10^(-8);
    CpCv=1.4;
    alpha=2/(R*c^(3/2))*(sqrt(lv)+((CpCv)-1)*sqrt(lt));
    
    %%% D�finition de param�tres, voir l'article : %%%%%%%%%%%%%%%%
    %%% "Real-time synthesis of clarinet-like instruments %%%%%%%%%
    %%%  using digital impedance models" de Philippe Guillemain %%%

    w1=c*(12*pi*L+9*pi^2*xe+16*L)/(4*L*(4*L+3*pi*xe+4*xe)); % conique
    w2=c*(28*pi*L+49*pi^2*xe+16*L)/(4*L*(4*L+7*pi*xe+4*xe)); % conique

    w_tilde1=w1/Fe;
    w_tilde2=w2/Fe;

    c1=cos(w_tilde1);
    c2=cos(w_tilde2);

    Fw1_carre=exp(-2*alpha*c*sqrt(w1/2)/L);
    Fw2_carre=exp(-2*alpha*c*sqrt(w2/2)/L);

    F1=Fw1_carre;
    F2=Fw2_carre;

    A1=F1*c1;
    A2=F2*c2;

    A12=A1-A2;
    F12=F1-F2;

    a1=(A12-sqrt(A12^2-F12^2))/(F12);
    b0=(sqrt(2*F1*F2*(c1-c2)*(A12-sqrt(A12^2-F12^2))))/(F12);

    Gp=1+(c/(2*Fe*xe));
    Gm=1-(c/(2*Fe*xe));

    bc0=1/Gp; 
    bc1=-(a1+1)/Gp;
    bc2=a1/Gp;
    bcD=-b0/Gp;
    bcD1=b0/Gp;
    ac1=(a1*Gp+Gm)/Gp;
    ac2=-(a1*Gm)/Gp;
    acD=-(b0*Gm)/Gp;
    acD1=b0;
    a0a=((Fe^2)/(wr^2))+((Fe*qr)/(2*wr));
    b1a=1/a0a;
    a1a=((2*(Fe^2)/(wr^2))-1)/(a0a);
    a2a=(((Fe*qr)/(2*wr))-((Fe^2)/(wr^2)))/(a0a);


    x=zeros(n,1);
    W=zeros(n,1);
    ue=zeros(n,1);
    pe=zeros(n,1);
    pext=zeros(n,1);

    for n=D+2:length(t)
    x(n)=b1a*pe(n-1)+a1a*x(n-1)+a2a*x(n-2);
    V=bc1*ue(n-1)+bc2*ue(n-2)+bcD*ue(n-D)+bcD1*ue(n-D-1)+...
        ac1*pe(n-1)+ac2*pe(n-2)+acD*pe(n-D)+acD1*pe(n-D-1);
    W=heaviside(1-gamma(n)+x(n))*zeta(n)*(1-gamma(n)+x(n));
    ue(n)=0.5*sign(gamma(n)-V)*(-bc0*W^2+W*sqrt((bc0*W)^2+4*abs(gamma(n)-V)));
    pe(n)=bc0*ue(n)+V;
    pext(n)=(pe(n)+ue(n))-(pe(n-1)+ue(n-1));
    end
end

% soundsc(pext,fe)