import("stdfaust.lib");

fe = 44100;

fr = 3500;
wr = 2*ma.PI*fr;
qr = 0.2;
c = 343;
f0 = hslider("freq", 220, 10, 880, 1);
L = c/(4*f0);
r = 0.004;

theta_deg = 1.5;
theta = theta_deg*ma.PI/180;
xe = r/sin(theta/2);
R = r*(1+(5*L)/(12*xe));

gamma = hslider("gamma", 0, 0, 1, 0.01); // debit
zeta = hslider("zeta", 0, 0, 2, 0.01); // pression levres
D = int(2 * fe * L / c);

lv = 4 * 10^(-8);
lt = 5.6 * 10^(-8);
CpCv = 1.4;
alpha = 2 / (R * c^(3/2)) * (sqrt(lv) + ((CpCv) - 1) * sqrt(lt));

w1 = c*(12*ma.PI*L+9*(ma.PI)^2*xe+16*L)/(4*L*(4*L+3*ma.PI*xe+4*xe));
w2 = c*(28*ma.PI*L+49*(ma.PI)^2*xe+16*L)/(4*L*(4*L+7*ma.PI*xe+4*xe));

w_tilde1 = w1/fe;
w_tilde2 = w2/fe;

c1 = cos(w_tilde1);
c2 = cos(w_tilde2);

F1 = exp(-2*alpha*c*sqrt(w1/2)/L);
F2 = exp(-2*alpha*c*sqrt(w2/2)/L);

A1 = F1*c1;
A2 = F2*c2;

A12 = A1-A2;
F12 = F1-F2;

a1 = (A12-sqrt(A12^2-F12^2))/(F12);
b0 = (sqrt(2 * F1 * F2 * (c1 - c2) * (A12 - sqrt(A12^2 - F12^2)))) / F12;

Gp = 1 + (c / (2 * fe * xe));
Gm = 1-(c/(2*fe*xe));

bc0 = 1/Gp;
bc1 = -(a1+1)/Gp;
bc2 = a1/Gp;
bcD = -b0/Gp;
bcD1 = b0/Gp;
ac1 = (a1*Gp+Gm)/Gp;
ac2 = -(a1*Gm)/Gp;
acD = -b0*Gm/Gp;
acD1 = b0;
a0a = ((fe^2)/(wr^2))+((fe*qr)/(2*wr));
b1a = 1/a0a;
a1a = ((2*(fe^2)/(wr^2))-1)/(a0a);
a2a = (((fe*qr)/(2*wr))-((fe^2)/(wr^2)))/(a0a);


process = p(u(v,w(x)),v) + u(v,w(x)) - p(u(v',w(x')),v') - u(v',w(x'))
    letrec {
	'x = b1a * p(u(v,w(x)),v) + a1a * x + a2a * x';
    'v = bc1*u(v,w(x))+bc2*u'(v,w(x))+bcD*(u(v,w(x))@(D-1))+bcD1*(u(v,w(x))@(D- 2))+ac1*p(u(v,w(x)),v)+ac2*(p'(u(v,w(x)),v))+acD*(p(u(v,w(x)),v)@(D-1))+acD1*(p(u(v,w(x)),v)@(D-2));
   };



p(u,v) = bc0 * u + v;
u(v,w) = 0.5 * ma.signum(gamma - v) * (-bc0 * w^2 + w * sqrt((bc0*w)^2 + 4*abs(gamma-v)));
w(x)   = heaviside(1 - gamma + x) * zeta * (1 - gamma + x);

heaviside(x) = (1 + ma.signum(x)) / 2;


			
