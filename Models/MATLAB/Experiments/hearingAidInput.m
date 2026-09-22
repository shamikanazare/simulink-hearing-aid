%% Project 241 - Hearing Aid
% Input Signal Simulation


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


%% Add Background Noise

targetSNR = 5;


noisy = awgn(x,targetSNR,'measured');



%% Listen Comparison


disp("Playing Clean Speech")
sound(x,Fs)

pause(length(x)/Fs + 1)



disp("Playing Noisy Speech")
sound(noisy,Fs)



%% Spectrogram


figure

subplot(2,1,1)

spectrogram(x,512,400,512,Fs,'yaxis')

title("Clean Speech")


subplot(2,1,2)

spectrogram(noisy,512,400,512,Fs,'yaxis')

title("Hearing Aid Input - Noisy Speech")