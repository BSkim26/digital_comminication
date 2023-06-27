clc;clear all; close all
%% Bits Generation
Bits=randi([0,1],1,1000000);                                    % 임의의 Bit 생성
Bit_length=length(Bits);                                    % Bit 길이 계산
Bitpersymbol=1;                                             % 1Symbol당 1Bit이므로 1
Symbol_length=Bit_length/Bitpersymbol;                      % Symbol Length 계산
%% BPSK Modulation
BPSK_Mod=2*Bits-1;                                          % Bit:0 --> Smaple:-1 , Bit:1-->Sample:1
%% BPSK Constellation
figure;plot(real(BPSK_Mod),imag(BPSK_Mod),'o');
grid on;
axis([-4 4 -4 4])
save('BPSK_AWGN_Constellation_KBS.mat','BPSK_Mod')
%% Setting EbNo
EbNo=0:1:20; 
%% Setting AWGN
for idx_EbNo=1:length(EbNo)    
    %% Setting Noise
    amplitude_noise=sqrt(1/(Bitpersymbol*10^(EbNo(idx_EbNo)/10)));                              % Noise의 Amplitude
    noise=((randn(Symbol_length,1)+(randn(Symbol_length,1))*1i))*amplitude_noise/sqrt(2);       % Noise 생성
    
    %% Adding Noise
    Rx_signal=BPSK_Mod.'+noise;    
   % figure; plot(real(Rx_signal),'bx'); hold on;
   % plot(real(BPSK_Mod));


   % figure;
   %  scatter(real(Rx_signal),imag(Rx_signal),'b+'); hold on;
   %  xlabel('I');ylabel('Q');grid on;
   %  scatter(real(BPSK_Mod),imag(BPSK_Mod),'r+');
   %  xline(0,'k--','linewidth',2);
    %% BPSK Demodulation
    BPSK_Demod=zeros(1,Bit_length);                             % Set value of Bits
    for idx=1:Bit_length                                        % Repetition of BPSK_Mod
        if Rx_signal(idx)>0                                     % Demodulate BPSK symbol
            BPSK_Demod(idx)=1;                                  % BPSK symbol : positive number --> Bits : 1
        end
    end
    %% BER Calculation
    error=sum(Bits~=BPSK_Demod);                                 % Calculate error
    BER(idx_EbNo)=error/Bit_length;                              % Calculate BER
end
%% BPSK AWGN Theoretical BER
EbNo_Theoretical_dB=0:1:20;
EbNo_Theoretical=10.^(EbNo_Theoretical_dB/10);

BER_Theoretical=(1/2)*erfc(sqrt(EbNo_Theoretical));
%% Figure
figure;semilogy(EbNo,BER,'bo-')
hold on
semilogy(EbNo_Theoretical_dB,BER_Theoretical,'rs-')
xlabel('EbNo')
ylabel('BER')
legend('Experiment BPSK of AWGN','Theoretical BPSK of AWGN')
axis([0 20 10^-5 10^-0])
title('BPSK of AWGN')
grid on

save('BPSK_AWGN_KBS.mat','BER')