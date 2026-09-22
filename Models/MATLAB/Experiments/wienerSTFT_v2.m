%% Project 241 - Digital Hearing Aid
% Milestone 3.1: STFT Wiener Filter

clc;
clear;
close all;


%% Load Clean Speech

audioPath = "C:\Users\admin\Desktop\SHARIF OS\01 Engineering\02 Projects\01 Active\Simulink-Hearing-Aid\data\datasets\TIMIT\TRAIN\DR1\FDAW0\SA1.WAV";

[x,Fs] = audioread(audioPath);


if size(x,2)>1
    x = mean(x,2);
end


x = x/max(abs(x));


%% Add Noise

targetSNR = 5;

noisy = awgn(x,targetSNR,'measured');


% Since this is simulation:
% We know the exact noise

noise = noisy - x;


%% STFT Parameters

windowLength = 512;

overlap = 400;

nfft = 512;


%% STFT

[S,F,T] = stft(noisy,Fs,...
    "Window",hann(windowLength),...
    "OverlapLength",overlap,...
    "FFTLength",nfft);


[Nf,Nt] = size(S);


%% Noise STFT

[N,~,~] = stft(noise,Fs,...
    "Window",hann(windowLength),...
    "OverlapLength",overlap,...
    "FFTLength",nfft);


%% Power Spectra

signalPower = abs(S).^2;

noisePower = abs(N).^2;


%% Wiener Gain

G = signalPower ./ (signalPower + noisePower);


%% Apply Gain

S_enhanced = G .* S;


%% Reconstruct Signal

enhanced = istft(S_enhanced,Fs,...
    "Window",hann(windowLength),...
    "OverlapLength",overlap,...
    "FFTLength",nfft);


%% Normalize

enhanced = enhanced/max(abs(enhanced));


%% SNR Evaluation

% Match lengths after ISTFT reconstruction

minLength = min(length(enhanced), length(x));

x_eval = x(1:minLength);
noisy_eval = noisy(1:minLength);
enhanced_eval = enhanced(1:minLength);


beforeSNR = snr(noisy_eval,noisy_eval-x_eval);

afterSNR = snr(enhanced_eval,enhanced_eval-x_eval);

% SNR Improvement

improvement = afterSNR - beforeSNR;

fprintf("SNR Improvement: %.2f dB\n", improvement);


%% Spectrogram Comparison

figure;

subplot(3,1,1)

spectrogram(x,512,400,512,Fs,'yaxis')

title("Clean Speech")


subplot(3,1,2)

spectrogram(noisy,512,400,512,Fs,'yaxis')

title("Noisy Speech (5 dB)")


subplot(3,1,3)

spectrogram(enhanced,512,400,512,Fs,'yaxis')

title("STFT Wiener Enhanced Speech")


%% Listen

sound(enhanced,Fs)