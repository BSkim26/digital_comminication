clc;
clear all;
close all;

%% Load QPSK data
load('QPSK_AWGN_KBS.mat', 'BER');
EbNo_QPSK_AWGN = 0:1:20;
BER_QPSK_AWGN = BER;

%% Load QPSK data
load('QPSK_Fading_KBS.mat', 'BER');
EbNo_QPSK_Fading = 0:2:50;
BER_QPSK_Fading = BER;

%% QPSK AWGN Theoretical BER
EbNo_Theoretical_dB=0:1:20;
EbNo_Theoretical=10.^(EbNo_Theoretical_dB/10);

BER_Theoretical=(1/2)*erfc(sqrt(EbNo_Theoretical));

%% QPSK Rayleigh fading Theoretical BER
EbNo_Theoretical_dB_Fad=0:2:50;                          
EbNo_Theoretical_Fad=10.^(EbNo_Theoretical_dB_Fad/10);                       

for idx=1:length(EbNo_Theoretical_Fad)
    BER_Theoretical_Fad(idx)=(1/2)*(1-(1/sqrt(1+1/EbNo_Theoretical_Fad(idx))));
end

%% Combine plots
figure;
semilogy(EbNo_QPSK_AWGN, BER_QPSK_AWGN, 'bo-', 'DisplayName', 'Experiment QPSK of AWGN');
hold on;
semilogy(EbNo_QPSK_Fading, BER_QPSK_Fading, 'ro-', 'DisplayName', 'Experiment QPSK of Fading Channel');
hold on;
semilogy(EbNo_Theoretical_dB, BER_Theoretical, 'bs-', 'DisplayName', 'Simulation QPSK of AWGN');
hold on;
semilogy(EbNo_Theoretical_dB_Fad, BER_Theoretical_Fad, 'rs-', 'DisplayName', 'Simulation QPSK of Fading Channel');

xlabel('EbNo');
ylabel('BER');
legend('Location', 'best');
axis([0 50 10^-5 10^-0]);
title('QPSK');
grid on;

