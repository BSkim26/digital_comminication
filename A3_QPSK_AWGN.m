clc;clear all; close all
%% Bits Generation
Bits=randi([0,1],1,1000000).';                  % 임의의 Bit 생성
Bit_length=length(Bits);                        % Bit 길이 계산
Bitpersymbol=2;                                 % Bit per Symbol
Symbol_length=Bit_length/Bitpersymbol;          % Symbol 길이 계산
%% QPSK Modulation
Re_QPSK = ones(Bit_length/2,1);                 % Set Real value of QPSK Symbol
Im_QPSK = ones(Bit_length/2,1);                 % Set Imaginary value of QPSK Symbol
for idx = 1:(Bit_length/2)                      % Repetition of Bit_length/2
    if Bits(idx*2-1,1) == 1                     % Modulate Real value of QPSK bits
        Re_QPSK(idx,1) = Re_QPSK(idx,1)*(-1);   % Bits : 1 --> Real value of QPSK Symbol --> -1
    end
    if Bits(idx*2,1) == 1                       % Modulate Imaginary value of QPSK bits
        Im_QPSK(idx,1) = Im_QPSK(idx,1)*(-1);   % Bits : 1 --> Imaginary value of QPSK Symbol --> -1
    end
end
QPSK_Mod = (Re_QPSK+1j*Im_QPSK)/sqrt(2);       % sqrt(2) : Normalized factor
%% QPSK Constellation
figure;plot(QPSK_Mod,'o')
grid on
axis([-4 4 -4 4])                               % axis : x--> -4~4  y--> -4~4
save('QPSK_AWGN_Constellation_KBS.mat','QPSK_Mod')
%% Setting EbNo
EbNo=0:1:20;                                    % EbNo : 1~20dB
%% Setting AWGN
for idx_EbNo=1:length(EbNo)
    %% Setting Noise
    amplitude_noise=sqrt(1/(Bitpersymbol*10^(EbNo(idx_EbNo)/10)));                           % Noise의 Amplitude
    noise=((randn(Symbol_length,1)+(randn(Symbol_length,1))*1i))*amplitude_noise/sqrt(2);    % Noise 생성
    
    %% Adding Noise
    Rx_signal=QPSK_Mod+noise;   
   %     figure; plot(real(Rx_signal),'bx'); hold on;
   % plot(real(QPSK_Mod));


   % figure;
   %  scatter(real(Rx_signal),imag(Rx_signal),'b+'); hold on;
   %  xlabel('I');ylabel('Q');grid on;
   %  scatter(real(QPSK_Mod),imag(QPSK_Mod),'r+');
   %  xline(0,'k--','linewidth',2);
   %  yline(0,'k--','linewidth',2);
    %% QPSK Demodulation
    QPSK_Demod=zeros(Bit_length,1);                 % Set value of Bits
    for idx = 1:(Bit_length/2)                      % Repetition of Bit_length/2
        if imag(Rx_signal(idx,1)) < 0               % Demodulate Imaginary value of QPSK symbol
            QPSK_Demod(2*idx,1) = 1;                % Imaginary value of QPSK symbol : negative number --> Bits : 1
        end
        if real(Rx_signal(idx,1)) < 0               % Demodulate Real value of QPSK symbol
            QPSK_Demod(2*idx-1,1) = 1;              % Real value of QPSK symbol : negative number --> Bits : 1
        end
    end
    %% BER Calculation
    error=sum(Bits~=QPSK_Demod);                                           % Calculate error
    BER(idx_EbNo)=error/Bit_length;                                        % Calculate BER
end
%% QPSK AWGN Theoretical BER
EbNo_Theoretical_dB=0:1:20;
EbNo_Theoretical=10.^(EbNo_Theoretical_dB/10);

BER_Theoretical=(1/2)*erfc(sqrt(EbNo_Theoretical));
%% Figure
figure;semilogy(EbNo,BER,'bo-')
hold on
semilogy(EbNo_Theoretical_dB,BER_Theoretical,'rs-')
xlabel('EbNo')
ylabel('BER')
legend('Experiment QPSK of AWGN','Theoretical QPSK of AWGN')
axis([0 20 10^-5 10^-0])
title('QPSK of AWGN')
grid on
save('QPSK_AWGN_KBS.mat','BER')