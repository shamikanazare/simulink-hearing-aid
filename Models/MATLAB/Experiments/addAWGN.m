%% Project 241 - Digital Hearing Aid
% Phase 3: MATLAB Implementation
% Milestone 2.1: AWGN Noise Modeling

clc;
clear;
close all;


%% Load Clean Speech

audioPath = "C:\Users\admin\Desktop\SHARIF OS\01 Engineering\02 Projects\01 Active\Simulink-Hearing-Aid\data\datasets\TIMIT\TRAIN\DR1\FDAW0\SA1.WAV";

[x, Fs] = audioread(audioPath);


% Convert to mono if required

if size(x,2) > 1
    x = mean(x,2);
end


%% Normalize Signal

x = x / max(abs(x));


%% Define SNR Levels

SNR_values = [0 5 10];


%% Generate Noisy Signals

noisySignals = cell(length(SNR_values),1);


for i = 1:length(SNR_values)

    noisySignals{i} = awgn(x,SNR_values(i),'measured');

end


%% Plot Time Domain Comparison

t = (0:length(x)-1)/Fs;


figure;

subplot(4,1,1)
plot(t,x)
title("Clean Speech")
xlabel("Time (s)")
ylabel("Amplitude")
grid on


for i = 1:length(SNR_values)

    subplot(4,1,i+1)

    plot(t,noisySignals{i})

    title("Noisy Speech - SNR = " + SNR_values(i) + " dB")

    xlabel("Time (s)")
    ylabel("Amplitude")

    grid on

end


%% Listen to Noisy Speech

sound(noisySignals{1},Fs)