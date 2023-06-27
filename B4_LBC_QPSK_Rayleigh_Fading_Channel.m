clc;clear all; close all
%% Bits Generation
Bits=randi([0,1],1,1000000).';                       % 임의의 Bit 생성
Bit_length=length(Bits);                             % Bit 길이 계산
Bitpersymbol=2;                                      % 1Symbol당 2Bit이므로 2
Symbol_length=Bit_length/Bitpersymbol;               % Symbol Length 계산
%% Codeword Generation
P=[1 1 0;0 1 1;1 1 1;1 0 1];                         % Coefficient Matrix 생성
I=eye(4);                                            % Unit Matrix(4x4) 생성
G=[P I];                                             % Generator Matrix 생성
Code = zeros(Bit_length/4, 7);                       % 행이 Bit_length/4개이고 열이 7개인 code 생성, 0으로 초기화                               
Message = reshape(Bits, 4,[])';                      % Bits 배열을 4개씩 묶어서 Message 배열 생성

for i = 1:(Bit_length/4)                             % 행의 길이 만큼         
    Code(i, :) = mod(Message(i, :) * G, 2);          % M과 G를 곱 연산한 후 mod 2 계산
end

Code_length=length(Code);                            % Code length 계산 
Code_Send = zeros(Code_length*7,1);                  % 송신 코드 세팅
for i= 1:Code_length                                 % Code length만큼 계산
    Code_Send(i*7-6:i*7,1) = Code_Send(i*7-6:i*7,1)+Code(i,:)';  %Codeword를 한 줄로 변환
end
Code_Send_length=length(Code_Send);                     % 전송할 Codeword의 길이 계산
%% QPSK Modulation
Re_QPSK = ones(Code_Send_length/2,1);                   % Set Real value of QPSK Symbol
Im_QPSK = ones(Code_Send_length/2,1);                   % Set Imaginary value of QPSK Symbol
for i = 1:(Code_Send_length/2)                          % Repetition of Bit_length/2
    if Code_Send(i*2-1,1) == 1                          % Modulate Real value of QPSK bits
        Re_QPSK(i,1) = Re_QPSK(i,1)*(-1);               % Bits : 1 --> Real value of QPSK Symbol --> -1
    end
    if Code_Send(i*2,1) == 1                            % Modulate Imaginary value of QPSK bits
        Im_QPSK(i,1) = Im_QPSK(i,1)*(-1);               % Bits : 1 --> Imaginary value of QPSK Symbol --> -1
    end
end
QPSK_Mod = (Re_QPSK+1j*Im_QPSK)/sqrt(2);                % sqrt(2) : Normalized factor
%% Constellation
figure;plot(QPSK_Mod,'o')
hold on
plot(QPSK_Mod,'o')
grid on
axis([-4 4 -4 4])                                  % axis : x--> -4~4  y--> -4~4
%% Setting EbNo 
EbNo=0:2:50;                                       % EbNo : 1~20dB
%% Setting AWGN
for i_EbNo=1:length(EbNo)                          % EbNo의 길이인 20까지 1씩 증가
    %% Setting Noise
    amplitude_noise=sqrt(1/(Bitpersymbol*10^(EbNo(i_EbNo)/10)));                               % Noise의 Amplitude
    noise=((randn(Code_Send_length/2,1)+(randn(Code_Send_length/2,1))*1i))*amplitude_noise/sqrt(2);    % Noise 생성
    %% Setting Channel
    Channel=(randn(Code_Send_length/2,1)+(randn(Code_Send_length/2,1))*1i)/sqrt(2); 
    %% Multiplication Channel, Adding Noise
    Rx_signal=QPSK_Mod.*Channel+noise;               % 신호가 Channel을 지나고 noise가 더해짐
    %% Equalizer
    Eq_signal=Rx_signal./Channel;                    % Equalizer
    %% QPSK Demodulation
    QPSK_Demod=zeros(Code_Send_length,1);           % Set value of Bits
    for i = 1:(Code_Send_length/2)                  % Repetition of QPSK_Mod
        if imag(Eq_signal(i,1)) < 0                % Demodulate Imaginary value of QPSK symbol
            QPSK_Demod(2*i,1) = 1;                 % Imaginary value of QPSK symbol : negative number --> Bits : 1
        end
        if real(Eq_signal(i,1)) < 0                % Demodulate Real value of QPSK symbol
            QPSK_Demod(2*i-1,1) = 1;               % Real value of QPSK symbol : negative number --> Bits : 1
        end
    end
    Code_Send = zeros(Code_length,7);              % Demodulation된 Codewords를 (Code_length x 7)로 선언, 0으로 초기화
    for i = 1:Code_length                          % Code length만큼 반복
        Code_Send(i,:) = QPSK_Demod(i*7-6:i*7,1);  % Demodulation된 Codeword vector 생성
    end
    %% Parity Check and Error Correction
    H = [eye(3) P'];                                     % Parity Check Matrix 생성
    Error_Pattern= vertcat(zeros(1,7), eye(7));          % Error Pattern 생성
    Code_Cor = zeros(Code_length,7);                     % 보정된 Codeword를 위한 행렬 생성
    for i = 1:Code_length                                % Code length만큼 반복
        s= mod(Code_Send(i,:)*H',2);                     % Syndrome 계산
        if  s==[0 0 0];                                  % Syndrome이 [0 0 0]인 경우
            Error_pattern = Error_Pattern(1,:);          % Error pattern = [0 0 0 0 0 0 0]
        elseif  s==[1 0 0];                              % Syndrome이 [1 0 0]인 경우
            Error_pattern = Error_Pattern(2,:);          % Error pattern = [1 0 0 0 0 0 0]
        elseif  s==[0 1 0];                              % Syndrome이 [0 1 0]인 경우
            Error_pattern = Error_Pattern(3,:);          % Error pattern = [0 1 0 0 0 0 0]
        elseif  s==[0 0 1];                              % Syndrome이 [0 0 1]인 경우
            Error_pattern = Error_Pattern(4,:);          % Error pattern = [0 0 1 0 0 0 0]
        elseif  s==[1 1 0];                              % Syndrome이 [1 1 0]인 경우
            Error_pattern = Error_Pattern(5,:);          % Error pattern = [0 0 0 1 0 0 0]
        elseif  s==[0 1 1];                              % Syndrome이 [0 1 1]인 경우
            Error_pattern = Error_Pattern(6,:);          % Error pattern = [0 0 0 0 1 0 0]
        elseif  s==[1 1 1];                              % Syndrome이 [1 1 1]인 경우
            Error_pattern = Error_Pattern(7,:);          % Error pattern = [0 0 0 0 0 1 0]
        elseif  s==[1 0 1];                              % Syndrome이 [1 0 1]인 경우
            Error_pattern = Error_Pattern(8,:);          % Error pattern = [0 0 0 0 0 0 1]
        end
        Code_Cor(i,:)=mod(Code_Send(i,:)+Error_pattern,2); % Error pattern을 더해주고 mod 2 하여 correction
    end
    Message_Send = zeros(Code_length,4);                               % Message vector (Code_length x 4) 크기로 생성, 0으로 초기화
    for i = 1:Code_length                                              % Code length 만큼 반복
        Message_Send(i,:) = Code_Cor(i,4:7);                           % Codeword에서 Message 추출
    end
    Bits_Rec=zeros(Bit_length,1);                                          % 수신 Bits 세팅
    for i=1:Code_length                                                    % Code length 만큼 반복
        Bits_Rec(i*4-3:i*4,1) = Bits_Rec(i*4-3:i*4,1)+Message_Send(i,:)';  % Message vector를 수신 Bits로 변환
    end
    %% BER Calculation
    error=sum(Bits~=Bits_Rec);                    % Calculate error
    BER(i_EbNo)=error/Bit_length;                 % Calculate BER
end
%% AWGN Theoretical BER
EbNo_Theoretical_dB=0:2:50;                       % 이론적인 EbNo을 1부터 20까지 dB로 표현          
EbNo_Theoretical=10.^(EbNo_Theoretical_dB/10);    % 선형 단위로 변환
for i=1:length(EbNo_Theoretical)
    BER_Theoretical(i)=(1/2)*(1-(1/sqrt(1+1/EbNo_Theoretical(i)))); % 이론적인 EbNo 계산
end
%% Figure
figure;
semilogy(EbNo,BER,'bo-')
hold on 
semilogy(EbNo_Theoretical_dB,BER_Theoretical,'rs-')
xlabel('EbNo')
ylabel('BER')
legend('Experiment QPSK of AWGN','Theoretical QPSK of AWGN')
title('QPSK of Rayleigh Fading Channel');
axis([0 50 10^-5 10^-0])
grid on

save('LBC_QPSK_Fading_KBS.mat','BER')