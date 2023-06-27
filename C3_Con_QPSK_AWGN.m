clc;clear all; close all
%% Bits Generation
Bits=randi([0,1],1,10000000).';                 % 임의의 Bit 생성
Bit_length=length(Bits);                        % Bit 길이 계산
Bitpersymbol=2;                                 % 1symbol당 2bits 표현
Symbol_length=Bit_length/Bitpersymbol;          % Symbol 길이 계산
%% Convolutional Code Encoding
trellis = poly2trellis(3,{'1+D+D2','1+D2'});    % trellis 구조 설정
Code = convenc(Bits,trellis);                   % Encoding
Code_length=length(Code);                       % Code Length 구하기
%% QPSK Modulation
Re_QPSK = ones(Code_length/2,1);                % Set Real value of QPSK Symbol
Im_QPSK = ones(Code_length/2,1);                % Set Imaginary value of QPSK Symbol
for idx = 1:(Code_length/2)                     % Repetition of Code_length/2
    if Code(idx*2-1,1) == 1                     % Modulate Real value of QPSK bits
        Re_QPSK(idx,1) = Re_QPSK(idx,1)*(-1);   % Bits : 1 --> Real value of QPSK Symbol --> -1
    end
    if Code(idx*2,1) == 1                       % Modulate Imaginary value of QPSK bits
        Im_QPSK(idx,1) = Im_QPSK(idx,1)*(-1);   % Bits : 1 --> Imaginary value of QPSK Symbol --> -1
    end
end
QPSK_Mod = (Re_QPSK+1j*Im_QPSK)/sqrt(2);        % sqrt(2) : Normalized factor
%% Constellation
figure;plot(QPSK_Mod,'o')
hold on
plot(QPSK_Mod,'o')
grid on
axis([-4 4 -4 4])                               % axis : x--> -4~4  y--> -4~4
save('Con_QPSK_AWGN_Constellation_KBS.mat','QPSK_Mod')
%% Setting EbNo
EbNo=0:1:20;                                    % EbNo : 1~20dB
%% Setting AWGN
for idx_EbNo=1:length(EbNo)                     % EbNo의 길이인 20까지 1씩 증가
    %% Setting Noise
    amplitude_noise=sqrt(1/(Bitpersymbol*10^(EbNo(idx_EbNo)/10)));                        % Noise의 Amplitude
    noise=((randn(Code_length/2,1)+(randn(Code_length/2,1))*1i))*amplitude_noise/sqrt(2); % Noise 생성
    %% Adding Noise
    Rx_signal=QPSK_Mod+noise;                   % 노이즈와 더해서 송신 signal을 표현
    %% QPSK Demodulation
    QPSK_Demod=zeros(Code_length,1);            % Set value of Bits
    for idx = 1:(Code_length/2)                 % Repetition of Code_length/2
        if imag(Rx_signal(idx,1)) < 0           % Demodulate Imaginary value of QPSK symbol
            QPSK_Demod(2*idx,1) = 1;            % Imaginary value of QPSK symbol : negative number --> Bits : 1
        end
        if real(Rx_signal(idx,1)) < 0           % Demodulate Real value of QPSK symbol
            QPSK_Demod(2*idx-1,1) = 1;          % Real value of QPSK symbol : negative number --> Bits : 1
        end
    end
    %% Decode Convolutional Code by Using Viterbi Decoder
    tb = 10;                                        % Traceback Depth 10으로 설정
    Bits_Rec = vitdec(QPSK_Demod,trellis,tb,'trunc','hard');  % Convolutionally decode binary data by using Viterbi algorithm
    %% BER Calculation
    error=sum(Bits~=Bits_Rec);              % Calculate error
    BER(idx_EbNo)=error/Bit_length;         % Calculate BER
end
%% AWGN Theoretical BER
EbNo_Theoretical_dB=0:1:20;                         % 이론적인 EbNo을 1부터 20까지 dB로 표현
EbNo_Theoretical=10.^(EbNo_Theoretical_dB/10);      % 선형 단위로 변환
BER_Theoretical=(1/2)*erfc(sqrt(EbNo_Theoretical)); % 이론적인 EbNo 계산
%% Figure
figure;
semilogy(EbNo,BER,'bo-')
hold on 
semilogy(EbNo_Theoretical_dB,BER_Theoretical,'rs-')
xlabel('EbNo')
ylabel('BER')
legend('Experiment QPSK of AWGN','Theoretical QPSK of AWGN')
title('QPSK of AWGN');
axis([0 20 10^-5 10^-0])
grid on

save('Con_QPSK_AWGN_KBS.mat','BER')