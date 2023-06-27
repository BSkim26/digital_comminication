clc;
clear all;
close all;

%% Load BPSK data
load('LBC_BPSK_Fading_KBS.mat', 'BER');
EbNo_BPSK = 0:1:20;
BER_BPSK = BER;

%% Load QPSK data
load('LBC_QPSK_Fading_KBS.mat', 'BER');
EbNo_QPSK = 0:1:20;
BER_QPSK = BER;

%% Load 16QAM data
load('LBC_16QAM_Fading_KBS.mat', 'BER');
EbNo_16QAM = 0:1:20;
BER_16QAM = BER;

%% Combine plots
figure;
semilogy(EbNo_BPSK, BER_BPSK, 'bo-');
hold on;
semilogy(EbNo_QPSK, BER_QPSK, 'rs-');
hold on;
semilogy(EbNo_16QAM, BER_16QAM, 'ko-');

xlabel('EbNo');
ylabel('BER');
legend('Experiment BPSK of AWGN', 'Experiment QPSK of AWGN', 'Experiment 16QAM of AWGN');
title('BPSK and QPSK and 16QAM of AWGN');
grid on;
