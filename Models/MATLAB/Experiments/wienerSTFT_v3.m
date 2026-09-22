%% Project 241 - Digital Hearing Aid
% Milestone 3.2: Ideal STFT Wiener Filter

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


% Exact noise (simulation)

noise = noisy - x;


%% STFT Parameters

windowLength = 512;

overlap = 400;

nfft = 512;


window = hann(windowLength);


%% STFT of signals

[X,F,T] = stft(x,Fs,...
    "Window",window,...
    "OverlapLength",overlap,...
    "FFTLength",nfft);


[Y,~,~] = stft(noisy,Fs,...
    "Window",window,...
    "OverlapLength",overlap,...
    "FFTLength",nfft);


[N,~,~] = stft(noise,Fs,...
    "Window",window,...
    "OverlapLength",overlap,...
    "FFTLength",nfft);



%% Power Spectra

speechPower = abs(X).^2;

noisePower = abs(N).^2;



%% Wiener Gain

G = speechPower ./ (speechPower + noisePower);


%% Apply Filter

Y_enhanced = G .* Y;



%% Reconstruction

enhanced = istft(Y_enhanced,Fs,...
    "Window",window,...
    "OverlapLength",overlap,...
    "FFTLength",nfft);



%% Length Matching

L = min(length(enhanced),length(x));

x_eval = x(1:L);
noisy_eval = noisy(1:L);
enhanced_eval = enhanced(1:L);



%% SNR Evaluation

beforeSNR = snr(noisy_eval,noisy_eval-x_eval);

afterSNR = snr(enhanced_eval,enhanced_eval-x_eval);


fprintf("Before Enhancement SNR: %.2f dB\n",beforeSNR);

fprintf("After Enhancement SNR: %.2f dB\n",afterSNR);

fprintf("Improvement: %.2f dB\n",afterSNR-beforeSNR);



%% Spectrogram Comparison


figure;

subplot(3,1,1)

spectrogram(x_eval,512,400,512,Fs,'yaxis')

title("Clean Speech")


subplot(3,1,2)

spectrogram(noisy_eval,512,400,512,Fs,'yaxis')

title("Noisy Speech - 5 dB")


subplot(3,1,3)

spectrogram(enhanced_eval,512,400,512,Fs,'yaxis')

title("Ideal Wiener Filter Output")



%% Listen

sound(enhanced_eval,Fs)