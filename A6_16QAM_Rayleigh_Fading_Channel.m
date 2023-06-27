clc;clear all; close all
%% Bits Generation
Bits=randi([0,1],1,10000000).';                 % 임의의 Bit 생성
Bit_length=length(Bits);                        % Bit 길이 계산
Bitpersymbol=4;                                 % Bit per Symbol
Symbol_length=Bit_length/Bitpersymbol;          % Symbol 길이 계산
%% Modulation of 16QAM
Re_16QAM = ones(Bit_length/4,1);                % Set Real value of 16QAM Symbol
Im_16QAM = ones(Bit_length/4,1);                % Set Imaginary value of 16QAM Symbol
for idx = 1:(Bit_length/4)                      % Repetition of Bit_length/4
    if Bits(4*idx-3)==1                         % 첫번째 bit가 1이면
       Im_16QAM(idx,1) = Im_16QAM(idx,1)*3;     % 허수부를 3배 설정
    end
    if Bits(4*idx-2)==1                         % 두번째 bit가 1이면
       Im_16QAM(idx,1) = Im_16QAM(idx,1)*-1;    % 허수부를 -1 곱해서 반전
    end
    if Bits(4*idx-1)==1                         % 세번째 bit가 1이면
       Re_16QAM(idx,1) = Re_16QAM(idx,1)*3;     % 실수부를 3배 설정
    end
    if Bits(4*idx)==1                           % 네번째 bit가 1이면
       Re_16QAM(idx,1) = Re_16QAM(idx,1)*-1;    % 실수부를 -1 곱해서 반전
    end
end
Mod_16QAM = (Re_16QAM + 1j*Im_16QAM)/sqrt(10);  % 루트 10으로 나눠서 nomalize
%% Constellation
figure;plot(Mod_16QAM,'o')                      % Contellation을 o로 표현
hold on
grid on
axis([-4 4 -4 4])                               % axis : x--> -4~4  y--> -4~4                          
%% Setting EbNo
EbNo=0:2:50;                                    % EbNo : 1~20dB               
%% Setting AWGN
for idx_EbNo=1:length(EbNo)                     % EbNo의 길이인 20까지 1씩 증가
    %% Setting Noise
    amplitude_noise=sqrt(1/(Bitpersymbol*10^(EbNo(idx_EbNo)/10)));     % Noise의 Amplitude               
    noise=((randn(Symbol_length,1)+(randn(Symbol_length,1))*1i))*amplitude_noise/sqrt(2); % Noise 생성
    %% Setting Channel
    Channel=(randn(Symbol_length,1)+(randn(Symbol_length,1))*1i)/sqrt(2); % channel 설정
    %% Multiplication Channel, Adding Noise
    % Rx_signal=Mod_16QAM.*Channel;                                                  % 신호에 noise 더함
    Rx_signal=Mod_16QAM.*Channel+noise;
   %  figure; plot(real(Rx_signal),'bx'); hold on;
   % plot(real(Mod_16QAM));
    %% Equalizer
    Eq_signal=Rx_signal./Channel;               % Equalizer
   %         figure; plot(real(Eq_signal),'bx'); hold on;
   % plot(real(Mod_16QAM));

   % 
   % figure;
   %  scatter(real(Eq_signal),imag(Eq_signal),'b+'); hold on;
   %  xlabel('I');ylabel('Q');grid on;
   %  scatter(real(Mod_16QAM),imag(Mod_16QAM),'r+');
   %  xline(0,'k--','linewidth',2);
   %  yline(0,'k--','linewidth',2);
   %  xline(2/sqrt(10),'k--','linewidth',2);
   %  yline(2/sqrt(10),'k--','linewidth',2);
   %  xline(-2/sqrt(10),'k--','linewidth',2);
   %  yline(-2/sqrt(10),'k--','linewidth',2);
    %% 16 QAM Demodulation
    Demod_16QAM=zeros(Bit_length,1);           % 모든 비트를 0으로 세팅
    for idx = 1: (Bit_length/4)                % Bit_length/4만큼 반복
        if real(Eq_signal(idx,1)) < 0          % Symbol의 실수부가 음수면
            Demod_16QAM(4*idx,1) = 1;               % 네번째 비트에 1대입
        end
        if abs(real(Eq_signal(idx,1))) > 2/sqrt(10) % Symbol의 실수부의 절댓값이 2/sqrt(10)보다 크면
            Demod_16QAM(4*idx-1,1) = 1;             % 세번째 비트에 1대입
        end
        if imag(Eq_signal(idx,1)) < 0          % Symbol의 허수부가 음수면
            Demod_16QAM(4*idx-2,1) = 1;        % 두번째 비트에 1대입
        end
        if abs(imag(Eq_signal(idx,1))) > 2/sqrt(10) % Symbol의 허수부의 절댓값이 2/sqrt(10)보다 크면
            Demod_16QAM(4*idx-3,1) = 1;        % 첫번째 비트에 1대입
        end
    end
    %% BER Calculation
    error=sum(Bits~=Demod_16QAM);              % Calculate error
    BER(idx_EbNo)=error/Bit_length;        % Calculate BER
end
%% 16QAM Rayleigh fading Theoretical BER
EbNo_Theoretical_dB=0:1:20;                     % 이론적인 EbNo을 1부터 20까지 dB로 표현
EbNo_Theoretical=10.^(EbNo_Theoretical_dB/10);  % 선형 단위로 변환

for idx=1:length(EbNo_Theoretical)
    BER_Theoretical(idx)=(3.2/8)*(1-(1/sqrt(1+5/(2*EbNo_Theoretical(idx))))); % BER Calculation
end
%% Figure
figure;
semilogy(EbNo,BER,'bo-')
hold on
semilogy(EbNo_Theoretical_dB,BER_Theoretical,'rs-')
xlabel('EbNo')
ylabel('BER')
legend('Experiment 16QAM of Fading Channel','Theoretical 16QAM of Fading Channel')
axis([0 20 10^-5 10^-0])
title('16QAM of Rayleigh Fading Channel')
grid on

save('16QAM_Fading_KBS.mat','BER')
