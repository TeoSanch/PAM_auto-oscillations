import("stdfaust.lib");

pi = 3.14159;

fe = 44100; // frequence echantillonnage
ts = 1 / fe; // time step

fr = 2300; // frequence mode anche
wr = 2 * pi * fr; // pulsation mode anche
qr = 0.2;
c = 343; // celerite du son
f0 = 440;
L = 0.5; // longueur du resonateur
// L = c / (4 * f0);
R = 0.007; // rayon du tube cylindrique
theta = 2 * pi / 180;
xe = R / sin(theta / 2);
//R = R * (1 + 5 * L / (12 * xe)); // rayon cone
gamma = hslider("gamma", 0, 0, 1, 0.01); // debit
zeta = hslider("zeta", 0, 0, 4, 0.01); // pression levres
D = int(2 * fe * L / c);

lv = 4 * 10^(-8);
lt = 5.6 * 10^(-8);
CpCv = 1.4;
alpha = 2 / (R * c^(3/2)) * (sqrt(lv) + ((CpCv) - 1) * sqrt(lt));

w1 = c * pi * (1 - (1/2)) / L; // cylindre
w2 = c * pi * (2 - (1/2)) / L; // cylindre
//w1 = c * (12 * pi * L + 9 * pi^2 * xe + 16 * L) / (4 * L * (4 * L + 3 * pi * xe + 4 * xe)); // conique
//w2 = c * (28 * pi * L + 49 * pi^2 * xe + 16 * L) / (4 * L * (4 * L + 7 * pi * xe + 4 * xe)); // conique


w_tilde1 = w1 / fe;
w_tilde2 = w2 / fe;

c1 = cos(w_tilde1);
c2 = cos(w_tilde2);

Fw1_carre = exp(-2 * alpha * c * sqrt(w1/2) / L);
Fw2_carre = exp(-2 * alpha * c * sqrt(w2/2) / L);

F1 = Fw1_carre;
F2 = Fw2_carre;

A1 = F1 * c1;
A2 = F2 * c2;

A12 = A1 - A2;
F12 = F1 - F2;

a1 = (A12 - sqrt(A12^2 - F12^2)) / (F12);
b0 = (sqrt(2 * F1 * F2 * (c1 - c2) * (A12 - sqrt(A12^2 - F12^2)))) / F12;

Gp = 1 + (c / (2 * fe * xe));

//bc0 = 1 / Gp; // conical bore
bc0 = 1; // cylindrical bore
a0a = ((fe^2) / (wr^2)) + ((fe * qr) / (2 * wr));
b1a = 1 / a0a;
a1a = ((2 * (fe^2) / (wr^2)) - 1) / (a0a);
a2a = (((fe * qr) / (2*wr)) - ((fe^2) / (wr^2))) / (a0a);

//process = p(u(v,w(x)),v) + u(v,w(x)) - (p(u(v,w(x)),v)' + u(v,w(x))')
process = p(u(v,w(x)),v)
    letrec {
	'x = b1a * p(u(v,w(x)),v) + a1a * x + a2a * x';
	'v = -a1 * u(v,w(x)) - b0 * (u(v,w(x))@(D-1)) + a1 * p(u(v,w(x)),v) - b0 * (p(u(v,w(x)),v)@(D-1));
    };



p(u,v) = bc0 * u + v;
u(v,w) = 0.5 * ma.signum(gamma - v) * (-bc0 * w^2 + w * sqrt((bc0*w)^2 + 4*abs(gamma-v)));
w(x)   = heaviside(1 - gamma + x) * zeta * (1 - gamma + x);

heaviside(x) = (1 + ma.signum(x)) / 2;
