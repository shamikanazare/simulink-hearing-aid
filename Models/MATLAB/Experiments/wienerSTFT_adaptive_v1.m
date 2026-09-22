%% Project 241 - Digital Hearing Aid
% Milestone 3.3
% Adaptive Wiener Filter
% Minimum Statistics + Gain Smoothing


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



%% STFT Parameters

windowLength = 512;

overlap = 400;

nfft = 512;


window = hann(windowLength);



%% STFT

[Y,F,T] = stft(noisy,Fs,...
    "Window",window,...
    "OverlapLength",overlap,...
    "FFTLength",nfft);



%% Power Spectrum

Y_power = abs(Y).^2;



%% Minimum Statistics Noise Estimation

numFrames = size(Y_power,2);


noisePower = zeros(size(Y_power));


% Larger window = slower, safer tracking

minWindow = 50;



for k = 1:numFrames


    startIndex = max(1,k-minWindow+1);


    noisePower(:,k) = min(...
        Y_power(:,startIndex:k),[],2);


end



%% Smooth Noise Estimate


alphaNoise = 0.95;


for k = 2:numFrames

    noisePower(:,k) = ...
        alphaNoise*noisePower(:,k-1) + ...
        (1-alphaNoise)*noisePower(:,k);

end



%% Wiener Gain


G = (Y_power-noisePower) ./ ...
    (Y_power+eps);



% Limit gain range

G = max(G,0);

G = min(G,1);



% Preserve speech

G = max(G,0.5);



%% Smooth Gain

alphaGain = 0.8;


for k = 2:numFrames

    G(:,k) = alphaGain*G(:,k-1) + ...
        (1-alphaGain)*G(:,k);

end



%% Apply Wiener Filter


Y_enhanced = G .* Y;



%% Reconstruction


enhanced = istft(Y_enhanced,Fs,...
    "Window",window,...
    "OverlapLength",overlap,...
    "FFTLength",nfft);



%% Length Matching


L = min([length(x),length(noisy),length(enhanced)]);


x_eval = x(1:L);

noisy_eval = noisy(1:L);

enhanced_eval = enhanced(1:L);



%% SNR Evaluation


beforeSNR = snr(noisy_eval,...
    noisy_eval-x_eval);


afterSNR = snr(enhanced_eval,...
    enhanced_eval-x_eval);



fprintf("\n")

fprintf("Before Enhancement SNR: %.2f dB\n",beforeSNR)

fprintf("After Enhancement SNR: %.2f dB\n",afterSNR)

fprintf("Improvement: %.2f dB\n",afterSNR-beforeSNR)



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

title("Adaptive Wiener - Minimum Statistics")



%% Listen

sound(enhanced_eval,Fs)