clc;clear all; close all
%% Bits Generation
Bits=randi([0,1],1,1000000);
Bit_length=length(Bits);                           % Bit 길이 계산
Bitpersymbol=1;                                    % 1Symbol당 1Bit이므로 1
Symbol_length=Bit_length/Bitpersymbol;             % Symbol Length 계산
%% Codeword Generation
P=[1 1 0;0 1 1;1 1 1;1 0 1];                       % Coefficient Matrix 생성
I=eye(4);                                          % Unit Matrix(4x4) 생성
G=[P I];                                           % Generator Matrix 생성

Code = zeros(Bit_length/4, 7);                     % 행이 Bit_length/4개이고 열이 7개인 code 생성, 0으로 초기화
Message = reshape(Bits, 4,[])';                    % Bits 배열을 4개씩 묶어서 Message 배열 생성

for i = 1:(Bit_length/4)                           % 행의 길이 만큼 
    Code(i, :) = mod(Message(i, :) * G, 2);        % M과 G를 곱 연산한 후 mod 2 계산
end

Code_length=length(Code);                          % Code length 계산 
Code_Send = zeros(1,Code_length*7);                % 송신 코드 세팅
for i= 1:Code_length                               % Code length만큼 계산
    Code_Send(i*7-6:i*7) = Code_Send(i*7-6:i*7)+Code(i,:); % Codeword를 한 줄로 변환
end
Code_Send_length=length(Code_Send);                     % 전송할 Codeword의 길이 계산
%% BPSK Modulation
BPSK_Mod=2*Code_Send-1;                                 % Bit:0 --> Smaple:-1 , Bit:1-->Sample:1
%% BPSK Constellation
figure;plot(real(BPSK_Mod),imag(BPSK_Mod),'o');         % Constellation 0로 표시
grid on;
axis([-4 4 -4 4])                                       % axis : x--> -4~4  y--> -4~4
%% Setting EbNo
EbNo=0:2:50;                                            % EbNo : 1~20dB
%% Setting AWGN
for i_EbNo=1:length(EbNo)                               % EbNo의 길이인 20까지 1씩 증가
    %% Setting Noise
    amplitude_noise=sqrt(1/(Bitpersymbol*10^(EbNo(i_EbNo)/10)));                        % Noise의 Amplitude
    noise=((randn(Code_Send_length,1)+(randn(Code_Send_length,1))*1i))*amplitude_noise/sqrt(2); % Noise 생성
    %% Setting Channel
    Channel=(randn(Code_Send_length,1)+(randn(Code_Send_length,1))*1i)/sqrt(2);    
    %% Multiplication Channel, Adding Noise
    Rx_signal=BPSK_Mod.'.*Channel+noise;             % 신호가 Channel을 지나고 noise가 더해짐 
    %% Equalizer
    Eq_signal=Rx_signal./Channel;                    % Equalizer
    %% BPSK Demodulation
    BPSK_Demod=zeros(1,Code_Send_length);             % Set value of Bits
    for i=1:Code_Send_length                          % Repetition of BPSK_Mod
        if Eq_signal(i)>0                             % Demodulate BPSK symbol
            BPSK_Demod(i)=1;                          % BPSK symbol : positive number --> Bits : 1
        end
    end
    Code_Send = zeros(Code_length,7);                 % Demodulation된 Codewords를 (Code_length x 7)로 선언, 0으로 초기화
    for i = 1:Code_length                             % Code length만큼 반복
        Code_Send(i,:) = BPSK_Demod(1,i*7-6:i*7);     % Demodulation된 Codeword vector 생성
    end
    %% Parity Check and Error Correction
    H = [eye(3) P'];                                 % Parity Check Matrix 생성
    Error_Pattern= vertcat(zeros(1,7), eye(7));      % Error Pattern 생성
    Code_Cor = zeros(Code_length,7);                 % 보정된 Codeword를 위한 행렬 생성
    for i = 1:Code_length                            % Code length만큼 반복
        s= mod(Code_Send(i,:)*H',2);                        % Syndrome 계산
        if  s==[0 0 0];                                     % Syndrome이 [0 0 0]일 경우
            Error_pattern = Error_Pattern(1,:);             % Error pattern = [0 0 0 0 0 0 0]
        elseif  s==[1 0 0];                                 % Syndrome이 [1 0 0]일 경우
            Error_pattern = Error_Pattern(2,:);             % Error pattern = [1 0 0 0 0 0 0]
        elseif  s==[0 1 0];                                 % Syndrome이 [0 1 0]일 경우
            Error_pattern = Error_Pattern(3,:);             % Error pattern = [0 1 0 0 0 0 0]
        elseif  s==[0 0 1];                                 % Syndrome이 [0 0 1]일 경우
            Error_pattern = Error_Pattern(4,:);             % Error pattern = [0 0 1 0 0 0 0]
        elseif  s==[1 1 0];                                 % Syndrome이 [1 1 0]일 경우
            Error_pattern = Error_Pattern(5,:);             % Error pattern = [0 0 0 1 0 0 0]
        elseif  s==[0 1 1];                                 % Syndrome이 [0 1 1]일 경우
            Error_pattern = Error_Pattern(6,:);             % Error pattern = [0 0 0 0 1 0 0]
        elseif  s==[1 1 1];                                 % Syndrome이 [1 1 1]일 경우
            Error_pattern = Error_Pattern(7,:);             % Error pattern = [0 0 0 0 0 1 0]
        elseif  s==[1 0 1];                                 % Syndrome이 [1 0 1]일 경우
            Error_pattern = Error_Pattern(8,:);             % Error pattern = [0 0 0 0 0 0 1]
        end
        Code_Cor(i,:)=mod(Code_Send(i,:)+Error_pattern,2); % Error pattern을 더해주고 mod 2 하여 correction
    end
    Message_Send = zeros(Code_length,4);                             % Message vector (Code_length x 4) 크기로 생성, 0으로 초기화
    for i = 1:Code_length                                            % Code length 만큼 반복
        Message_Send(i,:) = Code_Cor(i,4:7);       % Codeword에서 Message 추출
    end
    Bits_Rec=zeros(1,Bit_length);                                    % 수신 Bits 세팅
    for i=1:Code_length                                              % Code length 만큼 반복
        Bits_Rec(i*4-3:i*4) = Bits_Rec(i*4-3:i*4)+Message_Send(i,:); % Message vector를 수신 Bits로 변환
    end
    %% BER Calculation
    error=sum(Bits~=Bits_Rec);                         % Calculate error
    BER(i_EbNo)=error/Bit_length;                      % Calculate BER
end
%% BPSK Rayleigh fading Theoretical BER
EbNo_Theoretical_dB=0:2:50;                             % 이론적인 EbNo을 1부터 20까지 dB로 표현
EbNo_Theoretical=10.^(EbNo_Theoretical_dB/10);          % 선형 단위로 변환
for i=1:length(EbNo_Theoretical)
    BER_Theoretical(i)=(1/2)*(1-(1/sqrt(1+1/EbNo_Theoretical(i)))); % BER Calculation
end
%% Figure
figure;semilogy(EbNo,BER,'bo-')
hold on
semilogy(EbNo_Theoretical_dB,BER_Theoretical,'rs-')
xlabel('EbNo')
ylabel('BER')
legend('Experiment BPSK of AWGN','Theoretical BPSK of AWGN')
title('BPSK of Rayleigh Fading Channel');
axis([0 50 10^-5 10^-0])
grid on

save('LBC_BPSK_Fading_KBS.mat','BER')