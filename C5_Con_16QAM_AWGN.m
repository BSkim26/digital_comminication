clc;clear all; close all
%% Bits Generation
Bits=randi([0,1],1,10000000).';                 % 임의의 Bit 생성
Bit_length=length(Bits);                        % Bit 길이 계산
Bitpersymbol=4;                                 % 1symbol당 4bits 표현
Symbol_length=Bit_length/Bitpersymbol;          % Symbol 길이 계산
%% Convolutional Code Encoding
trellis = poly2trellis(3,{'1+D+D2','1+D2'});    % trellis 구조 설정
Code = convenc(Bits,trellis);                   % Encoding
Code_length=length(Code);                       % Code Length 구하기
%% Modulation of 16QAM
Re_16QAM = ones(Code_length/4,1);              % Set Real value of 16QAM Symbol
Im_16QAM = ones(Code_length/4,1);              % Set Imaginary value of 16QAM Symbol
for i = 1:(Code_length/4)                      % Repetition of Bit_length/4
    if Code(4*i-3)==1                          % 첫번째 비트가 1이면
       Im_16QAM(i,1) = Im_16QAM(i,1)*3;        % 허수부를 3배 설정
    end
    if Code(4*i-2)==1                          % 두번째 비트가 1이면
       Im_16QAM(i,1) = Im_16QAM(i,1)*-1;       % 허수부를 -1 곱해서 반전
    end
    if Code(4*i-1)==1                          % 세번째 비트가 1이면
       Re_16QAM(i,1) = Re_16QAM(i,1)*3;        % 실수부를 3배 설정
    end
    if Code(4*i)==1                            % 네번째 비트가 1이면
       Re_16QAM(i,1) = Re_16QAM(i,1)*-1;       % 실수부를 -1 곱해서 반전
    end
end
Mod_16QAM = (Re_16QAM + 1j*Im_16QAM)/sqrt(10);      % 루트 10으로 나눠서 nomalize
%% Constellation
figure;plot(Mod_16QAM,'o')                         % Contellation을 o로 표현  
hold on
grid on
axis([-4 4 -4 4])                               % axis : x--> -4~4  y--> -4~4
save('Con_16QAM_AWGN_Constellation_KBS.mat','Mod_16QAM')
%% Setting EbNo
EbNo=0:1:20;                                       % EbNo : 1~20dB
%% Setting AWGN
for idx_EbNo=1:length(EbNo)                          % EbNo의 길이인 20까지 1씩 증가
    %% Setting Noise  
    amplitude_noise=sqrt(1/(Bitpersymbol*10^(EbNo(idx_EbNo)/10)));                         % Noise의 Amplitude
    noise=((randn(Code_length/4,1)+(randn(Code_length/4,1))*1i))*amplitude_noise/sqrt(2);  % Noise 생성
    %% Adding Noise
    Rx_signal=Mod_16QAM+noise;                % 노이즈와 더해서 송신 signal을 표현
    %% 16 QAM Demodulation
    Demod_16QAM=zeros(Code_length,1);         % bit 길이 만큼 0으로 세팅
    for idx = 1: (Code_length/4)              % Bit_length/4만큼 반복
        if real(Rx_signal(idx,1)) < 0         % Symbol의 실수부가 음수면
            Demod_16QAM(4*idx,1) = 1;               % 네번째 비트에 1대입
        end
        if abs(real(Rx_signal(idx,1))) > 2/sqrt(10) % Symbol의 실수부의 절댓값이 2/sqrt(10)보다 크면
            Demod_16QAM(4*idx-1,1) = 1;             % 세번째 비트에 1대입
        end
        if imag(Rx_signal(idx,1)) < 0         % Symbol의 허수부가 음수면
            Demod_16QAM(4*idx-2,1) = 1;       % 두번째 비트에 1대입
        end
        if abs(imag(Rx_signal(idx,1))) > 2/sqrt(10) % Symbol의 허수부의 절댓값이 2/sqrt(10)보다 크면
            Demod_16QAM(4*idx-3,1) = 1;       % 첫번째 비트에 1대입
        end
    end
    %% Decode Convolutional Code by Using Viterbi Decoder
    tb = 10;                                        % Traceback Depth 10으로 설정
    Bits_Rec = vitdec(Demod_16QAM,trellis,tb,'trunc','hard');  % Convolutionally decode binary data by using Viterbi algorithm
    %% BER Calculation
    error=sum(Bits~=Bits_Rec);               % Calculate error
    BER(idx_EbNo)=error/Bit_length;          % Calculate BER
end
%% AWGN Theoretical BER
EbNo_Theoretical_dB=0:1:20;                         % 이론적인 EbNo을 1부터 20까지 dB로 표현
EbNo_Theoretical=10.^(EbNo_Theoretical_dB/10);      % 선형 단위로 변환

BER_Theoretical=(3/8)*erfc(sqrt((2/5)*EbNo_Theoretical)); % 이론적인 EbNo 계산
%% Figure
figure;
semilogy(EbNo,BER,'bo-')
hold on
semilogy(EbNo_Theoretical_dB,BER_Theoretical,'rs-')
xlabel('EbNo')
ylabel('BER')
legend('Experiment 16QAM of AWGN','Theoretical 16QAM of AWGN')
title('16QAM of AWGN');
axis([0 20 10^-5 10^-0])
grid on

save('Con_16QAM_AWGN_KBS.mat','BER')