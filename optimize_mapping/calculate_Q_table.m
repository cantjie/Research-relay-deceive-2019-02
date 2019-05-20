clc,clear

format long;
N = 64;
SNR_db = 4;

theta = 0 : 2*pi/N : 2*pi - 1e-5;
a = cos(pi/4 + theta);
b = sin(pi/4 + theta);

SNR = 10^(SNR_db/10);
pre_factor = sqrt(2*SNR);

x1 = pre_factor * a;
x2 = pre_factor * b;

Pe1 = qfunc(x1);
Pe2 = qfunc(x2);

index = 0 : N-1;
filename = ['Pe_at_SNR_',num2str(SNR_db),'.csv'];
dlmwrite(filename,[Pe1;Pe2],'delimiter',',','precision',6);