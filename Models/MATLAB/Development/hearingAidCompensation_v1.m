%% Project 241 - Digital Hearing Aid
% Milestone 8
% Hearing Aid Frequency Compensation


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



%% ==========================
% Simulate Hearing Loss
% ===========================


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



low=filtfilt(lowFilter,x);

mid=filtfilt(midFilter,x);

high=filtfilt(highFilter,x);



% Hearing loss

impaired = ...
    low*10^(0/20)+...
    mid*10^(-10/20)+...
    high*10^(-25/20);



impaired=impaired/max(abs(impaired));



%% ==========================
% Hearing Aid Compensation
% ===========================


low2=filtfilt(lowFilter,impaired);

mid2=filtfilt(midFilter,impaired);

high2=filtfilt(highFilter,impaired);



% Prescription gain

lowGain = 1;

midGain = 10^(10/20);

highGain = 10^(20/20);



compensated = ...
    low2*lowGain + ...
    mid2*midGain + ...
    high2*highGain;



%% Output Protection


% Soft limiter

compensated = tanh(compensated);



compensated = compensated/max(abs(compensated));



%% Listen


disp("Original Speech")

sound(x,Fs)

pause(length(x)/Fs+1)



disp("Hearing Loss")

sound(impaired,Fs)

pause(length(x)/Fs+1)



disp("Hearing Aid Output")

sound(compensated,Fs)



%% Spectrogram


figure


subplot(3,1,1)

spectrogram(x,512,400,512,Fs,'yaxis')

title("Original Speech")



subplot(3,1,2)

spectrogram(impaired,512,400,512,Fs,'yaxis')

title("Simulated Hearing Loss")



subplot(3,1,3)

spectrogram(compensated,512,400,512,Fs,'yaxis')

title("Hearing Aid Compensation Output")