clc;
clear all;
close all;

%% Load BPSK data
load('16QAM_AWGN_Constellation_KBS.mat','Mod_16QAM');
Mod_16QAM_1 = Mod_16QAM;

%% Load BPSK data
load('Con_16QAM_AWGN_Constellation_KBS.mat','Mod_16QAM');
Mod_16QAM_2 = Mod_16QAM;

%% Combine plots
figure;
plot(real(Mod_16QAM_1), imag(Mod_16QAM_1), 'bo');
hold on;
plot(real(Mod_16QAM_2), imag(Mod_16QAM_2), 'ro');
grid on;
axis([-4 4 -4 4]);
legend('16QAM 1', '16QAM 2');
xlabel('In-Phase');
ylabel('Quadrature');
title('Combined BPSK Constellation');
