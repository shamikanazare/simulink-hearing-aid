%% Project 241 - Digital Hearing Aid
% Milestone 3.6
% Spectral Subtraction Noise Reduction


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



%% Add Noise

targetSNR=5;

noisy=awgn(x,targetSNR,'measured');



%% STFT Parameters


windowLength=512;

overlap=400;

nfft=512;


window=hann(windowLength);



%% STFT


[Y,F,T]=stft(noisy,Fs,...
    "Window",window,...
    "OverlapLength",overlap,...
    "FFTLength",nfft);



magnitude=abs(Y);

phase=angle(Y);



%% Noise Estimation using low-energy frames


frameEnergy = mean(magnitude.^2);


noiseFrames = find(frameEnergy < prctile(frameEnergy,30));


noiseMagnitude = mean(...
    magnitude(:,noiseFrames),2);



%% Spectral Subtraction Parameters


alpha=1;


beta=0.1;



%% Improved Spectral Subtraction


alpha = 0.8;      % noise subtraction factor

beta = 0.3;       % spectral floor


cleanMagnitude=zeros(size(magnitude));


for k=1:size(magnitude,2)


    S_power = magnitude(:,k).^2;


    N_power = noiseMagnitude.^2;


    enhancedPower = S_power - alpha*N_power;


    % spectral floor

    enhancedPower = max(enhancedPower,...
        beta*S_power);



    cleanMagnitude(:,k)=sqrt(enhancedPower);


end



%% Reconstruct Spectrum


Yenhanced = cleanMagnitude .* exp(1j*phase);



%% ISTFT


enhanced=istft(Yenhanced,Fs,...
    "Window",window,...
    "OverlapLength",overlap,...
    "FFTLength",nfft);

enhanced = real(enhanced);

enhanced = enhanced / max(abs(enhanced));
%% Length Matching


L=min([length(x),length(noisy),length(enhanced)]);


x_eval=x(1:L);

noisy_eval=noisy(1:L);

enhanced_eval=enhanced(1:L);



%% SNR


before=snr(noisy_eval,noisy_eval-x_eval);


after=snr(enhanced_eval,enhanced_eval-x_eval);



fprintf("\nBefore Enhancement SNR: %.2f dB\n",before)

fprintf("After Enhancement SNR: %.2f dB\n",after)

fprintf("Improvement: %.2f dB\n",after-before)



%% Spectrograms


figure


subplot(3,1,1)

spectrogram(x_eval,512,400,512,Fs,'yaxis')

title("Clean Speech")



subplot(3,1,2)

spectrogram(noisy_eval,512,400,512,Fs,'yaxis')

title("Noisy Speech")



subplot(3,1,3)

spectrogram(enhanced_eval,512,400,512,Fs,'yaxis')

title("Spectral Subtraction Output")



sound(enhanced_eval,Fs)