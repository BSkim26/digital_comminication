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


% Mod_16QAM_real = real(Mod_16QAM);
% Mod_16QAM_imag = imag(Mod_16QAM);
% 
% figure;
% hold on;
% grid on;
% axis([-4 4 -4 4]);

% % Plotting the 16 distinct regions
% plot(Mod_16QAM_real(Mod_16QAM_real < -2/sqrt(10) & Mod_16QAM_imag < -2/sqrt(10)), Mod_16QAM_imag(Mod_16QAM_real < -2/sqrt(10) & Mod_16QAM_imag < -2/sqrt(10)), 'ro');
% plot(Mod_16QAM_real(Mod_16QAM_real < -2/sqrt(10) & Mod_16QAM_imag >= -2/sqrt(10) & Mod_16QAM_imag < 0), Mod_16QAM_imag(Mod_16QAM_real < -2/sqrt(10) & Mod_16QAM_imag >= -2/sqrt(10) & Mod_16QAM_imag < 0), 'go');
% plot(Mod_16QAM_real(Mod_16QAM_real < -2/sqrt(10) & Mod_16QAM_imag >= 0 & Mod_16QAM_imag < 2/sqrt(10)), Mod_16QAM_imag(Mod_16QAM_real < -2/sqrt(10) & Mod_16QAM_imag >= 0 & Mod_16QAM_imag < 2/sqrt(10)), 'bo');
% plot(Mod_16QAM_real(Mod_16QAM_real < -2/sqrt(10) & Mod_16QAM_imag >= 2/sqrt(10)), Mod_16QAM_imag(Mod_16QAM_real < -2/sqrt(10) & Mod_16QAM_imag >= 2/sqrt(10)), 'mo'); 
% plot(Mod_16QAM_real(Mod_16QAM_real >= -2/sqrt(10) & Mod_16QAM_real < 0 & Mod_16QAM_imag < -2/sqrt(10)), Mod_16QAM_imag(Mod_16QAM_real >= -2/sqrt(10) & Mod_16QAM_real < 0 & Mod_16QAM_imag < -2/sqrt(10)), 'co'); 
% plot(Mod_16QAM_real(Mod_16QAM_real >= -2/sqrt(10) & Mod_16QAM_real < 0 & Mod_16QAM_imag >= -2/sqrt(10) & Mod_16QAM_imag < 0), Mod_16QAM_imag(Mod_16QAM_real >= -2/sqrt(10) & Mod_16QAM_real < 0 & Mod_16QAM_imag >= -2/sqrt(10) & Mod_16QAM_imag < 0), 'yo'); 
% plot(Mod_16QAM_real(Mod_16QAM_real >= -2/sqrt(10) & Mod_16QAM_real < 0 & Mod_16QAM_imag >= 0 & Mod_16QAM_imag < 2/sqrt(10)), Mod_16QAM_imag(Mod_16QAM_real >= -2/sqrt(10) & Mod_16QAM_real < 0 & Mod_16QAM_imag >= 0 & Mod_16QAM_imag < 2/sqrt(10)), 'ko');
% plot(Mod_16QAM_real(Mod_16QAM_real >= -2/sqrt(10) & Mod_16QAM_real < 0 & Mod_16QAM_imag >= 2/sqrt(10)), Mod_16QAM_imag(Mod_16QAM_real >= -2/sqrt(10) & Mod_16QAM_real < 0 & Mod_16QAM_imag >= 2/sqrt(10)), 'rs'); 
% plot(Mod_16QAM_real(Mod_16QAM_real >= 0 & Mod_16QAM_real < 2/sqrt(10) & Mod_16QAM_imag < -2/sqrt(10)), Mod_16QAM_imag(Mod_16QAM_real >= 0 & Mod_16QAM_real < 2/sqrt(10) & Mod_16QAM_imag < -2/sqrt(10)), 'gs');
% plot(Mod_16QAM_real(Mod_16QAM_real >= 0 & Mod_16QAM_real < 2/sqrt(10) & Mod_16QAM_imag >= -2/sqrt(10) & Mod_16QAM_imag < 0), Mod_16QAM_imag(Mod_16QAM_real >= 0 & Mod_16QAM_real < 2/sqrt(10) & Mod_16QAM_imag >= -2/sqrt(10) & Mod_16QAM_imag < 0), 'bs'); 
% plot(Mod_16QAM_real(Mod_16QAM_real >= 0 & Mod_16QAM_real < 2/sqrt(10) & Mod_16QAM_imag >= 0 & Mod_16QAM_imag < 2/sqrt(10)), Mod_16QAM_imag(Mod_16QAM_real >= 0 & Mod_16QAM_real < 2/sqrt(10) & Mod_16QAM_imag >= 0 & Mod_16QAM_imag < 2/sqrt(10)), 'ms'); 
% plot(Mod_16QAM_real(Mod_16QAM_real >= 0 & Mod_16QAM_real < 2/sqrt(10) & Mod_16QAM_imag >= 2/sqrt(10)), Mod_16QAM_imag(Mod_16QAM_real >= 0 & Mod_16QAM_real < 2/sqrt(10) & Mod_16QAM_imag >= 2/sqrt(10)), 'cs'); 
% plot(Mod_16QAM_real(Mod_16QAM_real >= 2/sqrt(10) & Mod_16QAM_imag < -2/sqrt(10)), Mod_16QAM_imag(Mod_16QAM_real >= 2/sqrt(10) & Mod_16QAM_imag < -2/sqrt(10)), 'ys');
% plot(Mod_16QAM_real(Mod_16QAM_real >= 2/sqrt(10) & Mod_16QAM_imag >= -2/sqrt(10) & Mod_16QAM_imag < 0), Mod_16QAM_imag(Mod_16QAM_real >= 2/sqrt(10) & Mod_16QAM_imag >= -2/sqrt(10) & Mod_16QAM_imag < 0), 'ks'); 
% plot(Mod_16QAM_real(Mod_16QAM_real >= 2/sqrt(10) & Mod_16QAM_imag >= 0 & Mod_16QAM_imag < 2/sqrt(10)), Mod_16QAM_imag(Mod_16QAM_real >= 2/sqrt(10) & Mod_16QAM_imag >= 0 & Mod_16QAM_imag < 2/sqrt(10)), 'rd'); 
% plot(Mod_16QAM_real(Mod_16QAM_real >= 2/sqrt(10) & Mod_16QAM_imag >= 2/sqrt(10)), Mod_16QAM_imag(Mod_16QAM_real >= 2/sqrt(10) & Mod_16QAM_imag >= 2/sqrt(10)), 'gd'); 
% 
% xlabel('Real');
% ylabel('Imaginary');
% title('16-QAM Constellation');
% 
% % Creating a legend
% legend('1111', '0111', '0011', '1011', '1101', '0101', '0001', '1001', '1100', '0100', '0000', '1000', '1110', '0110', '0010', '1010');


save('16QAM_AWGN_Constellation_KBS.mat','Mod_16QAM')
%% Setting EbNo
EbNo=0:1:20;                                    % EbNo : 1~20dB
%% Setting AWGN
for idx_EbNo=1:length(EbNo)                     % EbNo의 길이인 20까지 1씩 증가
    %% Setting Noise  
    amplitude_noise=sqrt(1/(Bitpersymbol*10^(EbNo(idx_EbNo)/10)));  % Noise의 Amplitude                   
    noise=((randn(Symbol_length,1)+(randn(Symbol_length,1))*1i))*amplitude_noise/sqrt(2); % Noise 생성
    %% Adding Noise
    Rx_signal=Mod_16QAM+noise;                  % 노이즈와 더해서 송신 signal을 표현
   %  figure; plot(real(Rx_signal),'bx'); hold on;
   % plot(real(Mod_16QAM));

   % 
   % figure;
   %  scatter(real(Rx_signal),imag(Rx_signal),'b+'); hold on;
   %  xlabel('I');ylabel('Q');grid on;
   %  scatter(real(Mod_16QAM),imag(Mod_16QAM),'r+');
   %  xline(0,'k--','linewidth',2);
   %  yline(0,'k--','linewidth',2);
   %  xline(2/sqrt(10),'k--','linewidth',2);
   %  yline(2/sqrt(10),'k--','linewidth',2);
   %  xline(-2/sqrt(10),'k--','linewidth',2);
   %  yline(-2/sqrt(10),'k--','linewidth',2);
    %% 16 QAM Demodulation
    Demod_16QAM=zeros(Bit_length,1);            % bit 길이 만큼 0으로 세팅
    for idx = 1: (Bit_length/4)                 % Bit_length/4만큼 반복
        if real(Rx_signal(idx,1)) < 0           % Symbol의 실수부가 음수이면
            Demod_16QAM(4*idx,1) = 1;               % 네번째 비트에 1을 대입
        end
        if abs(real(Rx_signal(idx,1))) > 2/sqrt(10) % Symbol의 실수부의 절댓값이 2/sqrt(10)보다 크면
            Demod_16QAM(4*idx-1,1) = 1;             % 세번째 비트에 1을 대입
        end
        if imag(Rx_signal(idx,1)) < 0           % Symbol의 허수부가 음수이면
            Demod_16QAM(4*idx-2,1) = 1;         % 두번째 비트에 1을 대입
        end
        if abs(imag(Rx_signal(idx,1))) > 2/sqrt(10) % Symbol의 허수부의 절댓값이 2/sqrt(10)보다 크면
            Demod_16QAM(4*idx-3,1) = 1;         % 첫번째 비트에 1을 대입
        end
    end
    %% BER Calculation
    error=sum(Bits~=Demod_16QAM);                   % Calculate error
    BER(idx_EbNo)=error/Bit_length;                 % Calculate BER
end
%% AWGN Theoretical BER
EbNo_Theoretical_dB=0:1:20;                         % 이론적인 EbNo을 1부터 20까지 dB로 표현
EbNo_Theoretical=10.^(EbNo_Theoretical_dB/10);      % 선형 단위로 변환

BER_Theoretical=(3/8)*erfc(sqrt((2/5)*EbNo_Theoretical));   % 이론적인 EbNo 계산
%% Figure
figure;
semilogy(EbNo,BER,'bo-')
hold on
semilogy(EbNo_Theoretical_dB,BER_Theoretical,'rs-')
xlabel('EbNo')
ylabel('BER')
legend('Experiment 16QAM of AWGN','Theoretical 16QAM of AWGN')
axis([0 20 10^-5 10^-0])
title('16QAM of AWGN')
grid on

save('16QAM_AWGN_KBS.mat','BER')
