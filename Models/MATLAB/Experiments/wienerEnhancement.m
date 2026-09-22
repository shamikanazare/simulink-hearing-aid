%% Project 241 - Digital Hearing Aid
% Milestone 3: Wiener Filter Enhancement

clc;
clear;
close all;


%% Load Speech

audioPath = "C:\Users\admin\Desktop\SHARIF OS\01 Engineering\02 Projects\01 Active\Simulink-Hearing-Aid\data\datasets\TIMIT\TRAIN\DR1\FDAW0\SA1.WAV";

[x, Fs] = audioread(audioPath);


if size(x,2)>1
    x = mean(x,2);
end


x = x/max(abs(x));


%% Add Noise

targetSNR = 5;

noisy = awgn(x,targetSNR,'measured');


%% Estimate Noise

% Assume first 0.5 seconds contain mostly noise
noiseSegment = noisy(1:round(0.5*Fs));


%% FFT

N = length(noisy);

Y = fft(noisy);

noiseFFT = fft(noiseSegment,N);


%% Power Spectrum

Py = abs(Y).^2;

Pv = abs(noiseFFT).^2;


%% Wiener Gain

G = max((Py-Pv)./Py,0);


%% Apply Filter

Xhat = G .* Y;


%% Reconstruct Signal

enhanced = real(ifft(Xhat));


%% Normalize

enhanced = enhanced/max(abs(enhanced));


%% Compare SNR

beforeSNR = snr(noisy,noisy-x);

afterSNR = snr(enhanced,enhanced-x);


fprintf("Before Enhancement SNR: %.2f dB\n",beforeSNR);

fprintf("After Enhancement SNR: %.2f dB\n",afterSNR);



%% Spectrogram Comparison

figure;

subplot(3,1,1)
spectrogram(x,512,400,512,Fs,'yaxis')
title("Clean Speech")


subplot(3,1,2)
spectrogram(noisy,512,400,512,Fs,'yaxis')
title("Noisy Speech")


subplot(3,1,3)
spectrogram(enhanced,512,400,512,Fs,'yaxis')
title("Wiener Filter Output")