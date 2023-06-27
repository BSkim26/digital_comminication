clc;clear all; close all
%% Bits Generation
Bits=randi([0,1],1,1000000);                                    % 임의의 Bit 생성
Bit_length=length(Bits);                                        % Bit 길이 계산
Bitpersymbol=1;                                                 % Bit per Symbol
Symbol_length=Bit_length/Bitpersymbol;                          % Symbol 길이 계산
%% BPSK Modulation
BPSK_Mod=2*Bits-1;                                              % Bit:0 --> Smaple:-1 , Bit:1-->Sample:1
%% BPSK Constellation
figure;
hold on;

o_indices = find(BPSK_Mod == 1);
x_indices = find(BPSK_Mod ~= 1);

plot(real(BPSK_Mod(o_indices)), imag(BPSK_Mod(o_indices)), 'o');
plot(real(BPSK_Mod(x_indices)), imag(BPSK_Mod(x_indices)), 'x');

grid on;
axis([-4 4 -4 4]);


%% Setting EbNo
EbNo=0:2:50;                                                    % EbNo : 1~20dB
%% Setting AWGN
for idx_EbNo=1:length(EbNo)
    %% Setting Channel
    Channel=(randn(Symbol_length,1)+(randn(Symbol_length,1))*1i)/sqrt(2);        % Rayleigh Fading Channel
    %% Setting Noise
    amplitude_noise=sqrt(1/(Bitpersymbol*10^(EbNo(idx_EbNo)/10)));                              % Noise의 Amplitude
    noise=((randn(Symbol_length,1)+(randn(Symbol_length,1))*1i))*amplitude_noise/sqrt(2);       % Noise 생성
    
    %% Multiplication Channel, Adding Noise
    Rx_signal=BPSK_Mod'.*Channel+noise;                                                         % 신호가 Channel을 지나고 Noise를 더함
   % figure; plot(real(Rx_signal),'bx'); hold on;
   % plot(real(BPSK_Mod));
    %% Equalizer
    Eq_Signal=Rx_signal./Channel;                                                                % Equalizer
    % figure; plot(real(Rx_signal),'bx'); hold on;
   % plot(real(BPSK_Mod));


   % figure;
   %  scatter(real(Eq_Signal),imag(Eq_Signal),'b+'); hold on;
   %  xlabel('I');ylabel('Q');grid on;
   %  scatter(real(BPSK_Mod),imag(BPSK_Mod),'r+');
   %  xline(0,'k--','linewidth',2);
   
    %% BPSK Demodulation
    BPSK_Demod=zeros(1,Bit_length);                                    % Set value of Bits
    for idx=1:Bit_length                                               % Repetition of BPSK_Mod
        if Eq_Signal(idx)>0                                            % Demodulate BPSK symbol
            BPSK_Demod(idx)=1;                                         % BPSK symbol : positive number --> Bits : 1
        end
    end
    %% BER Calculation
    error=sum(Bits~=BPSK_Demod);                                       % Calculate error
    BER(idx_EbNo)=error/Bit_length;                                    % Calculate BER
end
%% BPSK Rayleigh fading Theoretical BER
EbNo_Theoretical_dB=0:1:20;                                            % EbNo dB scale
EbNo_Theoretical=10.^(EbNo_Theoretical_dB/10);                         % EbNo Power sclae

for idx=1:length(EbNo_Theoretical)
    BER_Theoretical(idx)=(1/2)*(1-(1/sqrt(1+1/EbNo_Theoretical(idx))));% BER Calculation
end
%% Figure
figure;semilogy(EbNo,BER,'bo-')
hold on
semilogy(EbNo_Theoretical_dB,BER_Theoretical,'rs-')
xlabel('EbNo')                          % X축 이름
ylabel('BER')                           % Y축 이름
legend('Experiment BPSK of Fading Channel','Theoretical BPSK of Fading Channel')
axis([0 20 10^-5 10^-0])
title('BPSK of Rayleigh Fading Channel')
grid on
save('BPSK_Fading_KBS.mat','BER')