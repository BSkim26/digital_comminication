clc;
clear all;
close all;

%% Load BPSK data
load('BPSK_AWGN_Constellation_KBS.mat', 'BPSK_Mod');
BPSK_Mod_1 = BPSK_Mod;

%% Load BPSK data
load('Con_BPSK_AWGN_Constellation_KBS.mat', 'BPSK_Mod');
BPSK_Mod_2 = BPSK_Mod;

%% Combine plots
figure;
plot(real(BPSK_Mod_1), imag(BPSK_Mod_1), 'bo');
hold on;
plot(real(BPSK_Mod_2), imag(BPSK_Mod_2), 'ro');
grid on;
axis([-4 4 -4 4]);
legend('BPSK 1', 'BPSK 2');
xlabel('In-Phase');
ylabel('Quadrature');
title('Combined BPSK Constellation');
