clc;
clear all;
close all;

%% Load BPSK data
load('QPSK_AWGN_Constellation_KBS.mat', 'QPSK_Mod');
QPSK_Mod_1 = QPSK_Mod;

%% Load BPSK data
load('Con_QPSK_AWGN_Constellation_KBS.mat', 'QPSK_Mod');
QPSK_Mod_2 = QPSK_Mod;

%% Combine plots
figure;
plot(real(QPSK_Mod_1), imag(QPSK_Mod_1), 'bo');
hold on;
plot(real(QPSK_Mod_2), imag(QPSK_Mod_2), 'ro');
grid on;
axis([-4 4 -4 4]);
legend('QPSK 1', 'QPSK 2');
xlabel('In-Phase');
ylabel('Quadrature');
title('Combined BPSK Constellation');
