clc;clear all; close all
%% Bits Generation
Bits=randi([0,1],1,10000000);                % 임의의 Bit 생성
Bit_length=length(Bits);                     % Bit 길이 계산
Bitpersymbol=1;                              % symbol당 1bit 표현
Symbol_length=Bit_length/Bitpersymbol;       % Symbol 길이
%% Convolutional Code Encoding
trellis = poly2trellis(3,{'1+D+D2','1+D2'});    % trellis 구조 설정
Code = convenc(Bits,trellis);                   % Encoding
Code_length=length(Code);                       % Code Length 구하기
%% BPSK Modulation
BPSK_Mod=2*Code-1;                                 % Bit:0 --> Smaple:-1 , Bit:1-->Sample:1
save('Con_BPSK_AWGN_Constellation_KBS.mat','BPSK_Mod')
%% BPSK Constellation
figure;plot(real(BPSK_Mod),imag(BPSK_Mod),'o');    % Constellation 0로 표시
grid on;
axis([-4 4 -4 4])                                  % axis : x--> -4~4  y--> -4~4
%% Setting EbNo
EbNo=0:1:20;                                       % EbNo : 1~20dB
%% Setting AWGN
for idx_EbNo=1:length(EbNo)                        % EbNo의 길이인 20까지 1씩 증가
    %% Setting Noise
    amplitude_noise=sqrt(1/(Bitpersymbol*10^(EbNo(idx_EbNo)/10)));                    % Noise의 Amplitude
    noise=((randn(Code_length,1)+(randn(Code_length,1))*1i))*amplitude_noise/sqrt(2); % Noise 생성
    %% Adding Noise
    Rx_signal=BPSK_Mod.'+noise;                     % 노이즈와 더해서 송신 signal을 표현
    %% BPSK Demodulation
    BPSK_Demod=zeros(1,Code_length);                % Set value of Bits
    for idx=1:Code_length                           % Repetition of Code_length  
        if Rx_signal(idx)>0                         % Demodulate BPSK symbol
            BPSK_Demod(idx)=1;                      % BPSK symbol : positive number --> Bits : 1
        end
    end
    %% Decode Convolutional Code by Using Viterbi Decoder
    tb = 10;                                        % Traceback Depth 10으로 설정
    Bits_Rec = vitdec(BPSK_Demod,trellis,tb,'trunc','hard');  % Convolutionally decode binary data by using Viterbi algorithm
    %% BER Calculation
    error=sum(Bits~=Bits_Rec);                    % Calculate error
    BER(idx_EbNo)=error/Bit_length;               % Calculate BER
end
%% BPSK AWGN Theoretical BER
EbNo_Theoretical_dB=0:1:20;                         % 이론적인 EbNo을 1부터 20까지 dB로 표현
EbNo_Theoretical=10.^(EbNo_Theoretical_dB/10);      % 선형 단위로 변환

BER_Theoretical=(1/2)*erfc(sqrt(EbNo_Theoretical)); % 이론적인 EbNo 계산
%% Figure
figure;semilogy(EbNo,BER,'bo-')
hold on
semilogy(EbNo_Theoretical_dB,BER_Theoretical,'rs-')
xlabel('EbNo')
ylabel('BER')
legend('Experiment BPSK of AWGN','Theoretical BPSK of AWGN')
title('BPSK of AWGN');
axis([0 20 10^-5 10^-0])
grid on

save('Con_BPSK_AWGN_KBS.mat','BER')




