%% Project 241 - Digital Hearing Aid
% Milestone 9
% Audiogram Based Hearing Aid Fitting


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



%% ==============================
% Simulated Patient Audiogram
% ===============================


freqPoints = [500 1000 2000 4000 8000];


hearingLoss = [5 10 20 35 40];



figure

plot(freqPoints,hearingLoss,'-o')

grid on

xlabel("Frequency (Hz)")

ylabel("Hearing Loss (dB)")

title("Patient Audiogram")



%% ==============================
% Create Filter Bank
% ===============================



lowFilter = designfilt('lowpassiir',...
    'FilterOrder',8,...
    'HalfPowerFrequency',1000,...
    'SampleRate',Fs);



midFilter = designfilt('bandpassiir',...
    'FilterOrder',8,...
    'HalfPowerFrequency1',1000,...
    'HalfPowerFrequency2',3000,...
    'SampleRate',Fs);



highFilter = designfilt('highpassiir',...
    'FilterOrder',8,...
    'HalfPowerFrequency',3000,...
    'SampleRate',Fs);



%% Split Bands


low=filtfilt(lowFilter,x);

mid=filtfilt(midFilter,x);

high=filtfilt(highFilter,x);



%% ==============================
% Estimate Band Loss
% ===============================


lowLoss = hearingLoss(1);

midLoss = mean(hearingLoss(2:3));

highLoss = mean(hearingLoss(4:5));



%% ==============================
% Prescription Gain
% ==============================


% Half gain rule
% Common fitting approximation

lowGain_dB = lowLoss/2;

midGain_dB = midLoss/2;

highGain_dB = highLoss/2;



fprintf("Prescribed Gains:\n")

fprintf("Low: %.1f dB\n",lowGain_dB)

fprintf("Mid: %.1f dB\n",midGain_dB)

fprintf("High: %.1f dB\n",highGain_dB)



%% Apply Gain


lowOut = low * 10^(lowGain_dB/20);

midOut = mid * 10^(midGain_dB/20);

highOut = high * 10^(highGain_dB/20);


output = lowOut + midOut + highOut;



%% Output Protection


output=tanh(output);


output=output/max(abs(output));



%% Listen


disp("Original Speech")

sound(x,Fs)


pause(length(x)/Fs+1)


disp("Fitted Hearing Aid Output")

sound(output,Fs)



%% Spectrogram Comparison


figure


subplot(2,1,1)

spectrogram(x,512,400,512,Fs,'yaxis')

title("Original Speech")



subplot(2,1,2)

spectrogram(output,512,400,512,Fs,'yaxis')

title("Audiogram Fitted Hearing Aid Output")