%% Project 241 - Digital Hearing Aid
% Milestone 7
% Hearing Loss Simulation


clc;
clear;
close all;


%% Load Clean Speech


audioPath = "C:\Users\admin\Desktop\SHARIF OS\01 Engineering\02 Projects\01 Active\Simulink-Hearing-Aid\data\datasets\TIMIT\TRAIN\DR1\FDAW0\SA1.WAV";


[x,Fs]=audioread(audioPath);


if size(x,2)>1
    x=mean(x,2);
end


x=x/max(abs(x));



%% Filter Bank


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



%% Split Signal


low=filtfilt(lowFilter,x);

mid=filtfilt(midFilter,x);

high=filtfilt(highFilter,x);



%% Simulated Hearing Loss


lowLoss = low * 10^(0/20);


midLoss = mid * 10^(-10/20);


highLoss = high * 10^(-25/20);



impaired = lowLoss + midLoss + highLoss;



impaired = impaired/max(abs(impaired));



%% Plot Spectrogram


figure


subplot(2,1,1)

spectrogram(x,512,400,512,Fs,'yaxis')

title("Normal Hearing - Original Speech")



subplot(2,1,2)

spectrogram(impaired,512,400,512,Fs,'yaxis')

title("Simulated Hearing Loss")



%% Listen


disp("Original Speech")

sound(x,Fs)


pause(length(x)/Fs+1)


disp("Simulated Hearing Loss")

sound(impaired,Fs)