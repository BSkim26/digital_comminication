clc;clear all; close all
%% Bits Generation
Bits=randi([0,1],1,10000000);                   % 임의의 Bit 생성
Bit_length=length(Bits);                        % Bit 길이 계산
Bitpersymbol=1;                                 % symbol당 1bit 표현
Symbol_length=Bit_length/Bitpersymbol;          % Symbol 길이
%% Convolutional Code Encoding
trellis = poly2trellis(3,{'1+D+D2','1+D2'});    % trellis 구조 설정
Code = convenc(Bits,trellis);                   % Encoding
Code_length=length(Code);                       % Code Length 구하기
%% BPSK Modulation
BPSK_Mod=2*Code-1;                              % Bit:0 --> Smaple:-1 , Bit:1-->Sample:1
%% BPSK Constellation
figure;plot(real(BPSK_Mod),imag(BPSK_Mod),'o'); % Constellation 0로 표시
grid on;
axis([-4 4 -4 4])                               % axis : x--> -4~4  y--> -4~4
%% Setting EbNo
EbNo=0:2:50;                                       % EbNo : 1~20dB
%% Setting AWGN
for idx_EbNo=1:length(EbNo)                        % EbNo의 길이인 20까지 1씩 증가
    %% Setting Noise
    amplitude_noise=sqrt(1/(Bitpersymbol*10^(EbNo(idx_EbNo)/10)));                         % Noise의 Amplitude
    noise=((randn(Code_length,1)+(randn(Code_length,1))*1i))*amplitude_noise/sqrt(2);  % Noise 생성
    %% Setting Channel
    Channel=(randn(Code_length,1)+(randn(Code_length,1))*1i)/sqrt(2);  % channel 설정
    %% Multiplication Channel, Adding Noise
    Rx_signal=BPSK_Mod.'.*Channel+noise;        % 신호가 Channel을 지나고 noise가 더해짐
    %% Equalizer
    Eq_signal=Rx_signal./Channel;               % Equalizer
    %% BPSK Demodulation
    BPSK_Demod=zeros(1,Code_length);            % Set value of Bits
    for idx=1:Code_length                       % Repetition of Code_length  
        if Eq_signal(idx)>0                     % Demodulate BPSK symbol
            BPSK_Demod(idx)=1;                  % BPSK symbol : positive number --> Bits : 1
        end
    end
    %% Decode Convolutional Code by Using Viterbi Decoder
    tb = 10;                                        % Traceback Depth 10으로 설정
    Bits_Rec = vitdec(BPSK_Demod,trellis,tb,'trunc','hard');  % Convolutionally decode binary data by using Viterbi algorithm
    %% BER Calculation
    error=sum(Bits~=Bits_Rec);                  % Calculate error
    BER(idx_EbNo)=error/Bit_length;             % Calculate BER
end
%% BPSK Rayleigh fading Theoretical BER
EbNo_Theoretical_dB=0:2:50;                         % 이론적인 EbNo을 1부터 20까지 dB로 표현
EbNo_Theoretical=10.^(EbNo_Theoretical_dB/10);      % 선형 단위로 변환
for idx=1:length(EbNo_Theoretical)
    BER_Theoretical(idx)=(1/2)*(1-(1/sqrt(1+1/EbNo_Theoretical(idx)))); % 이론적인 EbNo 계산
end
%% Figure
figure;semilogy(EbNo,BER,'bo-')
hold on
semilogy(EbNo_Theoretical_dB,BER_Theoretical,'rs-')
xlabel('EbNo')
ylabel('BER')
legend('Experiment BPSK of Fading Channel','Theoretical BPSK of Fading Channel')
title('BPSK of Rayleigh Fading');
axis([0 50 10^-5 10^-0])
grid on

save('Con_BPSK_Fading_KBS','BER')
