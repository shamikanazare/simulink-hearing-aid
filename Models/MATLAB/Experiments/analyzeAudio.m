%% Project 241 - Digital Hearing Aid
% Phase 3: MATLAB Implementation
% Milestone 1: Audio Signal Analysis

clc;
clear;
close all;

%% Load Audio File

audioPath = "C:\Users\admin\Desktop\SHARIF OS\01 Engineering\02 Projects\01 Active\Simulink-Hearing-Aid\data\datasets\TIMIT\TRAIN\DR1\FDAW0\SA1.WAV";

[x, Fs] = audioread(audioPath);


%% Basic Audio Information

duration = length(x)/Fs;

fprintf("Sampling Frequency: %.2f Hz\n", Fs);
fprintf("Number of Samples: %d\n", length(x));
fprintf("Duration: %.2f seconds\n", duration);


%% Convert Stereo to Mono (if required)

if size(x,2) > 1
    x = mean(x,2);
end


%% Time Vector

t = (0:length(x)-1)/Fs;


%% Plot Time Domain Signal

figure;

plot(t,x);

xlabel("Time (seconds)");
ylabel("Amplitude");

title("Input Speech Signal - Time Domain");

grid on;


%% Frequency Spectrum

N = length(x);

X = fft(x);

f = (0:N-1)*(Fs/N);

magnitude = abs(X)/N;


figure;

plot(f(1:N/2), magnitude(1:N/2));

xlabel("Frequency (Hz)");
ylabel("Magnitude");

title("Speech Signal Spectrum");

grid on;


%% Spectrogram

figure;

spectrogram(x,512,400,512,Fs,'yaxis');

title("Speech Signal Spectrogram");