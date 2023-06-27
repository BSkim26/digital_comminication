clc;clear all; close all
%% Bits Generation
Bits=randi([0,1],1,1000000).';                       % 임의의 Bit 생성
Bit_length=length(Bits);                             % Bit 길이 계산
Bitpersymbol=4;                                      % 1Symbol당 4Bit이므로 4
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
%% Modulation of 16QAM
Re_16QAM = ones(Code_Send_length/4,1);              % Set Real value of 16QAM Symbol
Im_16QAM = ones(Code_Send_length/4,1);              % Set Imaginary value of 16QAM Symbol
for i = 1:(Code_Send_length/4)                      % Repetition of Bit_length/4
    if Code_Send(4*i-3)==1                          % 첫번째 비트가 1이면
       Im_16QAM(i,1) = Im_16QAM(i,1)*3;             % 허수부를 3배 설정
    end
    if Code_Send(4*i-2)==1                          % 두번째 비트가 1이면
       Im_16QAM(i,1) = Im_16QAM(i,1)*-1;            % 허수부를 -1 곱해서 반전
    end
    if Code_Send(4*i-1)==1                          % 세번째 비트가 1이면
       Re_16QAM(i,1) = Re_16QAM(i,1)*3;             % 실수부를 3배 설정
    end
    if Code_Send(4*i)==1                            % 네번째 비트가 1이면
       Re_16QAM(i,1) = Re_16QAM(i,1)*-1;            % 실수부를 -1 곱해서 반전
    end
end
Mod_16QAM = (Re_16QAM + 1j*Im_16QAM)/sqrt(10);      % 루트 10으로 나눠서 nomalize


%% Constellation
figure;plot(Mod_16QAM,'o')                         % Contellation을 o로 표현            
hold on
grid on
axis([-4 4 -4 4])                                  % axis : x--> -4~4  y--> -4~4
%% Setting EbNo
EbNo=0:1:20;                                       % EbNo : 1~20dB
%% Setting AWGN
for i_EbNo=1:length(EbNo)                          % EbNo의 길이인 20까지 1씩 증가
    %% Setting Noise  
    amplitude_noise=sqrt(1/(Bitpersymbol*10^(EbNo(i_EbNo)/10)));                             % Noise의 Amplitude
    noise=((randn(Code_Send_length/4,1)+(randn(Code_Send_length/4,1))*1i))*amplitude_noise/sqrt(2);  % Noise 생성
    %% Adding Noise
    Rx_signal=Mod_16QAM+noise;
    %% 16 QAM Demodulation
    Demod_16QAM=zeros(Code_Send_length,1);         % bit 길이 만큼 0으로 세팅
    for i = 1: (Code_Send_length/4)                % Bit_length/4만큼 반복
        if real(Rx_signal(i,1)) < 0                % Symbol의 실수부가 음수면
            Demod_16QAM(4*i,1) = 1;                    % 네번째 비트에 1대입
        end   
        if abs(real(Rx_signal(i,1))) > 2/sqrt(10)      % Symbol의 실수부의 절댓값이 2/sqrt(10)보다 크면
            Demod_16QAM(4*i-1,1) = 1;                  % 세번째 비트에 1대입
        end
        if imag(Rx_signal(i,1)) < 0                % Symbol의 허수부가 음수면
            Demod_16QAM(4*i-2,1) = 1;              % 두번째 비트에 1대입
        end
        if abs(imag(Rx_signal(i,1))) > 2/sqrt(10)      % Symbol의 허수부의 절댓값이 2/sqrt(10)보다 크면
            Demod_16QAM(4*i-3,1) = 1;              % 첫번째 비트에 1대입
        end
    end
    Code_Send = zeros(Code_length,7);                    % Demodulation된 Codewords를 (Code_length x 7)로 선언, 0으로 초기화
    for i = 1:Code_length                                % Code length만큼 반복
        Code_Send(i,:) = Demod_16QAM(i*7-6:i*7,1);       % Demodulation된 Codeword vector 생성
    end
    %% Parity Check and Error Correction
    H = [eye(3) P'];                                 % Parity Check Matrix 생성
    Error_Pattern= vertcat(zeros(1,7), eye(7));      % Error Pattern 생성
    Code_Cor = zeros(Code_length,7);                 % 보정된 Codeword를 위한 행렬 생성
    for i = 1:Code_length                            % Code length만큼 반복
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
    Message_Send = zeros(Code_length,4);                                % Message vector (Code_length x 4) 크기로 생성, 0으로 초기화
    for i = 1:Code_length                                               % Code length 만큼 반복
        Message_Send(i,:) = Code_Cor(i,4:7);                            % Codeword에서 Message 추출
    end

    Bits_Rec=zeros(Bit_length,1);                                              % 수신 Bits 세팅
    for i=1:Code_length                                                        % Code length 만큼 반복
        Bits_Rec(i*4-3:i*4,1) = Bits_Rec(i*4-3:i*4,1)+Message_Send(i,:)';      % Message vector를 수신 Bits로 변환
    end
    %% BER Calculation
    error=sum(Bits~=Bits_Rec);                        % Calculate error
    BER(i_EbNo)=error/Bit_length;                     % Calculate BER
end
%% AWGN Theoretical BER
EbNo_Theoretical_dB=0:1:20;                             % 이론적인 EbNo을 1부터 20까지 dB로 표현
EbNo_Theoretical=10.^(EbNo_Theoretical_dB/10);          % 선형 단위로 변환

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

save('LBC_16QAM_AWGN_KBS.mat','BER')