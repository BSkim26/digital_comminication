clc;
clear all;
close all;

%% Load BPSK data
load('Con_BPSK_AWGN_KBS.mat', 'BER');
EbNo_BPSK_AWGN = 0:1:20;
BER_BPSK_AWGN = BER;

%% Load BPSK data
load('Con_BPSK_Fading_KBS.mat', 'BER');
EbNo_BPSK_Fading = 0:2:40;
BER_BPSK_Fading = BER;

%% BPSK AWGN Theoretical BER
EbNo_Theoretical_dB=0:1:20;
EbNo_Theoretical=10.^(EbNo_Theoretical_dB/10);

BER_Theoretical=(1/2)*erfc(sqrt(EbNo_Theoretical));

%% BPSK Rayleigh fading Theoretical BER
EbNo_Theoretical_dB_Fad=0:1:20;                          
EbNo_Theoretical_Fad=10.^(EbNo_Theoretical_dB_Fad/10);                       

for idx=1:length(EbNo_Theoretical_Fad)
    BER_Theoretical_Fad(idx)=(1/2)*(1-(1/sqrt(1+1/EbNo_Theoretical_Fad(idx))));
end

%% Combine plots
figure;
semilogy(EbNo_BPSK_AWGN, BER_BPSK_AWGN, 'bo-', 'DisplayName', 'Experiment BPSK of AWGN');
hold on;
semilogy(EbNo_BPSK_Fading, BER_BPSK_Fading, 'ro-', 'DisplayName', 'Experiment BPSK of Fading Channel');
hold on;
semilogy(EbNo_Theoretical_dB, BER_Theoretical, 'bs-', 'DisplayName', 'Simulation BPSK of AWGN');
hold on;
semilogy(EbNo_Theoretical_dB_Fad, BER_Theoretical_Fad, 'rs-', 'DisplayName', 'Simulation BPSK of Fading Channel');

xlabel('EbNo');
ylabel('BER');
legend('Location', 'best');
axis([0 20 10^-5 10^-0]);
title('BPSK');
grid on;

