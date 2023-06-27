clc;
clear all;
close all;

%% Load BPSK data
load('BPSK_AWGN_KBS.mat', 'BER');
EbNo_BPSK_AWGN = 0:1:20;
BER_BPSK_AWGN = BER;

%% Load QPSK data
load('QPSK_AWGN_KBS.mat', 'BER');
EbNo_QPSK_AWGN = 0:1:20;
BER_QPSK_AWGN = BER;

%% Load 16QAM data
load('16QAM_AWGN_KBS.mat', 'BER');
EbNo_16QAM_AWGN = 0:1:20;
BER_16QAM_AWGN = BER;

%% Load BPSK data
load('BPSK_Fading_KBS.mat', 'BER');
EbNo_BPSK_Fading = 0:2:50;
BER_BPSK_Fading = BER;

%% Load QPSK data
load('QPSK_Fading_KBS.mat', 'BER');
EbNo_QPSK_Fading = 0:2:50;
BER_QPSK_Fading = BER;

%% Load 16QAM data
load('16QAM_Fading_KBS.mat', 'BER');
EbNo_16QAM_Fading = 0:2:50;
BER_16QAM_Fading = BER;


%% Combine plots
figure;
semilogy(EbNo_BPSK_AWGN, BER_BPSK_AWGN, 'bo-', 'DisplayName', 'Experiment BPSK of AWGN');
hold on;
semilogy(EbNo_QPSK_AWGN, BER_QPSK_AWGN, 'rs-', 'DisplayName', 'Experiment QPSK of AWGN');
hold on;
semilogy(EbNo_16QAM_AWGN, BER_16QAM_AWGN, 'ko-', 'DisplayName', 'Experiment 16QAM of AWGN');
hold on;
semilogy(EbNo_BPSK_Fading, BER_BPSK_Fading, 'bo-', 'DisplayName', 'Experiment BPSK of Fading Channel');
hold on;
semilogy(EbNo_QPSK_Fading, BER_QPSK_Fading, 'rs-', 'DisplayName', 'Experiment QPSK of Fading Channel');
hold on;
semilogy(EbNo_16QAM_Fading, BER_16QAM_Fading, 'ko-', 'DisplayName', 'Experiment 16QAM of Fading Channel');

xlabel('EbNo');
ylabel('BER');
legend('Location', 'best');
title('BPSK, QPSK, and 16QAM');
grid on;

