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
% QPSK Constellation
figure;
hold on;

plot(QPSK_Mod(Re_QPSK == 1 & Im_QPSK == 1), 'ro');     % Symbol area 1 (Real: 1, Imaginary: 1) - Red Circle
plot(QPSK_Mod(Re_QPSK == -1 & Im_QPSK == 1), 'bs');    % Symbol area 2 (Real: -1, Imaginary: 1) - Blue Square
plot(QPSK_Mod(Re_QPSK == -1 & Im_QPSK == -1), 'gd');   % Symbol area 3 (Real: -1, Imaginary: -1) - Green Diamond
plot(QPSK_Mod(Re_QPSK == 1 & Im_QPSK == -1), 'mv');    % Symbol area 4 (Real: 1, Imaginary: -1) - Magenta Triangle

grid on;
axis([-4 4 -4 4]);                                   % axis: x--> -4~4, y--> -4~4

% Add legend
legend('00', '01', '11', '00');
%% Setting EbNo
EbNo=0:2:50;                                    % EbNo : 1~20dB
%% Setting AWGN
for idx_EbNo=1:length(EbNo)
    Channel=(randn(Symbol_length,1)+(randn(Symbol_length,1))*1i)/sqrt(2);     % Rayleigh Fading Channel
    %% Setting Noise
    amplitude_noise=sqrt(1/(Bitpersymbol*10^(EbNo(idx_EbNo)/10)));                           % Noise의 Amplitude          
    noise=((randn(Symbol_length,1)+(randn(Symbol_length,1))*1i))*amplitude_noise/sqrt(2);    % Noise 생성
    
    %% Adding Noise
    % Rx_signal=QPSK_Mod.*Channel;                                                  % 신호에 noise 더함
    Rx_signal=QPSK_Mod.*Channel+noise;
   %  figure; plot(real(Rx_signal),'bx'); hold on;
   % plot(real(QPSK_Mod));
    %% Equalizer
    Eq_Signal=Rx_signal./Channel;                                                            % Equalizer
   %     figure; plot(real(Eq_Signal),'bx'); hold on;
   % plot(real(QPSK_Mod));


   % figure;
   %  scatter(real(Eq_Signal),imag(Eq_Signal),'b+'); hold on;
   %  xlabel('I');ylabel('Q');grid on;
   %  scatter(real(QPSK_Mod),imag(QPSK_Mod),'r+');
   %  xline(0,'k--','linewidth',2);
   %  yline(0,'k--','linewidth',2);
    %% QPSK Demodulation
    QPSK_Demod=zeros(Bit_length,1);                 % Set value of Bits
    for idx = 1:(Bit_length/2)                      % Repetition of Bit_length/2
        if imag(Eq_Signal(idx,1)) < 0                % Demodulate Imaginary value of QPSK symbol
            QPSK_Demod(2*idx,1) = 1;                % Imaginary value of QPSK symbol : negative number --> Bits : 1
        end
        if real(Eq_Signal(idx,1)) < 0                % Demodulate Real value of QPSK symbol
            QPSK_Demod(2*idx-1,1) = 1;              % Real value of QPSK symbol : negative number --> Bits : 1
        end
    end
    %% BER Calculation
    error=sum(Bits~=QPSK_Demod);                                 % Calculate error
    BER(idx_EbNo)=error/Bit_length;                              % Calculate BER
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
legend('Experiment QPSK of Fading Channel','Theoretical QPSK of Fading Channel')
axis([0 20 10^-5 10^-0])
grid on
save('QPSK_Fading_KBS.mat','BER')