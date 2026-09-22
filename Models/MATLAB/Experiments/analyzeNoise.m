%% Project 241 - Digital Hearing Aid
% Phase 3: MATLAB Implementation
% Milestone 2.2: Noise Analysis and SNR Measurement

clc;
clear;
close all;


%% Load Clean Speech

audioPath = "C:\Users\admin\Desktop\SHARIF OS\01 Engineering\02 Projects\01 Active\Simulink-Hearing-Aid\data\datasets\TIMIT\TRAIN\DR1\FDAW0\SA1.WAV";

[x, Fs] = audioread(audioPath);


% Convert stereo to mono

if size(x,2)>1
    x = mean(x,2);
end


% Normalize

x = x/max(abs(x));


%% Generate Noisy Signals

SNR_values = [0 5 10];

noisySignals = cell(length(SNR_values),1);


for i = 1:length(SNR_values)

    noisySignals{i} = awgn(x,SNR_values(i),'measured');

end


%% Calculate SNR

fprintf("\nSignal Quality Analysis\n");
fprintf("-----------------------\n");


for i = 1:length(SNR_values)

    measuredSNR = snr(noisySignals{i}, noisySignals{i}-x);

    fprintf("Target SNR: %d dB | Measured SNR: %.2f dB\n", ...
        SNR_values(i), measuredSNR);

end


%% Spectrogram Comparison

figure;

subplot(4,1,1)

spectrogram(x,512,400,512,Fs,'yaxis');

title("Clean Speech");


for i = 1:length(SNR_values)

    subplot(4,1,i+1)

    spectrogram(noisySignals{i},512,400,512,Fs,'yaxis');

    title("Noisy Speech - SNR = " + SNR_values(i)+" dB");

end