%% Project 241 - Digital Hearing Aid
% Milestone 6
% Complete Hearing Aid Pipeline v1


clc;
clear;
close all;


%% Load Speech

audioPath = "C:\Users\admin\Desktop\SHARIF OS\01 Engineering\02 Projects\01 Active\Simulink-Hearing-Aid\data\datasets\TIMIT\TRAIN\DR1\FDAW0\SA1.WAV";


[x,Fs]=audioread(audioPath);


if size(x,2)>1
    x=mean(x,2);
end


x=x/max(abs(x));



%% Create Noisy Input


targetSNR=5;


noisy=awgn(x,targetSNR,'measured');



%% ------------------------------------------------
% Stage 1: Conservative Noise Reduction
% Ideal Wiener benchmark mode
% ------------------------------------------------


noise = noisy-x;


window=hann(512);

overlap=400;

nfft=512;



[X,~,~]=stft(x,Fs,...
    "Window",window,...
    "OverlapLength",overlap,...
    "FFTLength",nfft);



[Y,~,~]=stft(noisy,Fs,...
    "Window",window,...
    "OverlapLength",overlap,...
    "FFTLength",nfft);



[N,~,~]=stft(noise,Fs,...
    "Window",window,...
    "OverlapLength",overlap,...
    "FFTLength",nfft);



speechPower=abs(X).^2;

noisePower=abs(N).^2;



G=speechPower./...
    (speechPower+noisePower);



% protect speech

G=max(G,0.7);



Yclean=G.*Y;



enhanced=istft(Yclean,Fs,...
    "Window",window,...
    "OverlapLength",overlap,...
    "FFTLength",nfft);



enhanced=real(enhanced);



%% Match Length


L=min(length(enhanced),length(x));


enhanced=enhanced(1:L);



%% ------------------------------------------------
% Stage 2: Frequency Shaping
% ------------------------------------------------


lowFilter=designfilt('lowpassiir',...
    'FilterOrder',8,...
    'HalfPowerFrequency',1000,...
    'SampleRate',Fs);


midFilter=designfilt('bandpassiir',...
    'FilterOrder',8,...
    'HalfPowerFrequency1',1000,...
    'HalfPowerFrequency2',3000,...
    'SampleRate',Fs);


highFilter=designfilt('highpassiir',...
    'FilterOrder',8,...
    'HalfPowerFrequency',3000,...
    'SampleRate',Fs);



low=filtfilt(lowFilter,enhanced);

mid=filtfilt(midFilter,enhanced);

high=filtfilt(highFilter,enhanced);



lowGain=10^(2/20);

midGain=10^(3/20);

highGain=10^(5/20);



shaped=...
    low*lowGain + ...
    mid*midGain + ...
    high*highGain;



%% ------------------------------------------------
% Stage 3: Output Limiter
% ------------------------------------------------


limit=0.95;


shaped=max(min(shaped,limit),-limit);



output=shaped/max(abs(shaped));

beforeSNR = snr(noisy(1:L), noisy(1:L)-x(1:L));

afterSNR = snr(output(1:L), output(1:L)-x(1:L));


fprintf("\nBefore SNR: %.2f dB\n",beforeSNR)

fprintf("After SNR: %.2f dB\n",afterSNR)

fprintf("Improvement: %.2f dB\n",afterSNR-beforeSNR)

figure

plot(output-noisy(1:length(output)))

title("Difference between Input and Hearing Aid Output")

xlabel("Samples")

%% Listen


disp("Noisy input")

sound(noisy,Fs)


pause(length(noisy)/Fs+1)



disp("Hearing aid output")

sound(output,Fs)



%% Spectrogram


figure


subplot(2,1,1)

spectrogram(noisy,512,400,512,Fs,'yaxis')

title("Noisy Input")



subplot(2,1,2)

spectrogram(output,512,400,512,Fs,'yaxis')

title("Hearing Aid Output")