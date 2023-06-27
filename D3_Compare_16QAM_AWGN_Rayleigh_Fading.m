clc;
clear all;
close all;

%% Load 16QAM data
load('Con_16QAM_AWGN_KBS.mat', 'BER');
EbNo_16QAM_AWGN = 0:1:20;
BER_16QAM_AWGN_Con = BER;

%% Load 16QAM data
load('Con_16QAM_Fading_KBS.mat', 'BER');
EbNo_16QAM_Fading_Con = 0:2:50;
BER_16QAM_Fading_Con = BER;

%% Load 16QAM data
load('LBC_16QAM_AWGN_KBS.mat', 'BER');
EbNo_16QAM_AWGN_LBC = 0:1:20;
BER_16QAM_AWGN_LBC = BER;

%% Load 16QAM data
load('LBC_16QAM_Fading_KBS.mat', 'BER');
EbNo_16QAM_Fading_LBC = 0:2:50;
BER_16QAM_Fading_LBC = BER;

%% Load 16QAM data
load('16QAM_AWGN_KBS.mat', 'BER');
EbNo_16QAM_AWGN = 0:1:20;
BER_16QAM_AWGN = BER;

%% Load 16QAM data
load('16QAM_Fading_KBS.mat', 'BER');
EbNo_16QAM_Fading = 0:2:50;
BER_16QAM_Fading = BER;

%% AWGN Theoretical BER
EbNo_Theoretical_dB=0:1:20;                         
EbNo_Theoretical=10.^(EbNo_Theoretical_dB/10);      

BER_Theoretical=(3/8)*erfc(sqrt((2/5)*EbNo_Theoretical)); 

%% 16QAM Rayleigh fading Theoretical BER
EbNo_Theoretical_dB_Fad=0:2:50;                         
EbNo_Theoretical_Fad=10.^(EbNo_Theoretical_dB_Fad/10);      

for idx=1:length(EbNo_Theoretical_Fad)
    BER_Theoretical_Fad(idx)=(3.2/8)*(1-(1/sqrt(1+5/(2*EbNo_Theoretical_Fad(idx))))); 
end

%% Combine plots
figure;
semilogy(EbNo_Theoretical_dB, BER_Theoretical, 'bs-', 'DisplayName', 'Simulation 16QAM of AWGN');
hold on;
semilogy(EbNo_Theoretical_dB_Fad, BER_Theoretical_Fad, 'rs-', 'DisplayName', 'Simulation 16QAM of Fading Channel');
hold on;
semilogy(EbNo_16QAM_AWGN, BER_16QAM_AWGN_Con, 'bo-', 'DisplayName', 'Experiment 16QAM of AWGN (Con)');
hold on;
semilogy(EbNo_16QAM_Fading_Con, BER_16QAM_Fading_Con, 'ro-', 'DisplayName', 'Experiment 16QAM of Fading Channel (Con)');
hold on;
semilogy(EbNo_16QAM_AWGN_LBC, BER_16QAM_AWGN_LBC, 'bo--', 'DisplayName', 'Experiment 16QAM of AWGN (LBC)');
hold on;
semilogy(EbNo_16QAM_Fading_LBC, BER_16QAM_Fading_LBC, 'ro--', 'DisplayName', 'Experiment 16QAM of Fading Channel (LBC)');
hold on;
semilogy(EbNo_16QAM_AWGN, BER_16QAM_AWGN, 'bo:', 'DisplayName', 'Experiment 16QAM of AWGN');
hold on;
semilogy(EbNo_16QAM_Fading, BER_16QAM_Fading, 'ro:', 'DisplayName', 'Experiment 16QAM of Fading Channel');

xlabel('EbNo');
ylabel('BER');
legend('Location', 'best');
axis([0 50 10^-5 10^-0]);
title('16QAM');
grid on;
