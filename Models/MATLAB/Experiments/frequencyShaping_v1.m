%% Project 241 - Digital Hearing Aid
% Milestone 5
% Frequency Shaping Hearing Aid Model


clc;
clear;
close all;


%% Load Speech

audioPath = "C:\Users\admin\Desktop\SHARIF OS\01 Engineering\02 Projects\01 Active\Simulink-Hearing-Aid\data\datasets\TIMIT\TRAIN\DR1\FDAW0\SA1.WAV";


[x,Fs] = audioread(audioPath);


if size(x,2)>1
    x=mean(x,2);
end


x=x/max(abs(x));



%% Simulate Hearing Aid Input

targetSNR = 5;

inputSignal = awgn(x,targetSNR,'measured');



%% Filter Bank Design


% Low band
lowFilter = designfilt('lowpassiir',...
    'FilterOrder',8,...
    'HalfPowerFrequency',1000,...
    'SampleRate',Fs);


% Mid band

midFilter = designfilt('bandpassiir',...
    'FilterOrder',8,...
    'HalfPowerFrequency1',1000,...
    'HalfPowerFrequency2',3000,...
    'SampleRate',Fs);



% High band

highFilter = designfilt('highpassiir',...
    'FilterOrder',8,...
    'HalfPowerFrequency',3000,...
    'SampleRate',Fs);



%% Split Frequency Bands


lowBand = filtfilt(lowFilter,inputSignal);


midBand = filtfilt(midFilter,inputSignal);


highBand = filtfilt(highFilter,inputSignal);



%% Apply Hearing Loss Compensation


lowGain = 3;

midGain = 6;

highGain = 12;



lowOut = lowBand * 10^(lowGain/20);


midOut = midBand * 10^(midGain/20);


highOut = highBand * 10^(highGain/20);



%% Combine Bands


output = lowOut + midOut + highOut;



%% Normalize


output = output/max(abs(output));



%% Listen


disp("Original noisy input")

sound(inputSignal,Fs)


pause(length(inputSignal)/Fs+1)



disp("Frequency shaped hearing aid output")

sound(output,Fs)



%% Spectrogram Comparison


figure


subplot(2,1,1)

spectrogram(inputSignal,512,400,512,Fs,'yaxis')

title("Noisy Input")



subplot(2,1,2)

spectrogram(output,512,400,512,Fs,'yaxis')

title("Frequency Shaped Output")



%% Frequency Response


fvtool(lowFilter,midFilter,highFilter)