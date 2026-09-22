%% Project 241
% Oracle Wiener Filter Benchmark


clc;
clear;
close all;


%% Load

audioPath = "C:\Users\admin\Desktop\SHARIF OS\01 Engineering\02 Projects\01 Active\Simulink-Hearing-Aid\data\datasets\TIMIT\TRAIN\DR1\FDAW0\SA1.WAV";


[x,Fs] = audioread(audioPath);


if size(x,2)>1
    x = mean(x,2);
end


x=x/max(abs(x));



%% Add noise

targetSNR = 5;

noisy = awgn(x,targetSNR,'measured');


noise = noisy-x;



%% STFT

frameLength=320;

hop=160;

window=hann(frameLength);


enhanced=zeros(size(noisy));



numFrames=floor((length(noisy)-frameLength)/hop)+1;



for i=1:numFrames


    idx=(i-1)*hop+1;


    speechFrame=x(idx:idx+frameLength-1).*window;

    noisyFrame=noisy(idx:idx+frameLength-1).*window;

    noiseFrame=noise(idx:idx+frameLength-1).*window;



    X=fft(speechFrame);

    Y=fft(noisyFrame);

    N=fft(noiseFrame);



    speechPower=abs(X).^2;

    noisePower=abs(N).^2;



    gain=speechPower ./ ...
        (speechPower+noisePower+eps);



    enhancedSpectrum=gain.*Y;



    frame=real(ifft(enhancedSpectrum));



    enhanced(idx:idx+frameLength-1)=...
        enhanced(idx:idx+frameLength-1)+...
        frame.*window;


end



enhanced=enhanced/max(abs(enhanced));



%% SNR


L=min([length(x),length(noisy),length(enhanced)]);



before=snr(noisy(1:L),noisy(1:L)-x(1:L));


after=snr(enhanced(1:L),enhanced(1:L)-x(1:L));


fprintf("Before SNR %.2f dB\n",before)

fprintf("After SNR %.2f dB\n",after)

fprintf("Improvement %.2f dB\n",after-before)



%% Plot

figure

subplot(3,1,1)
spectrogram(x,512,400,512,Fs,'yaxis')
title("Clean")


subplot(3,1,2)
spectrogram(noisy,512,400,512,Fs,'yaxis')
title("Noisy")


subplot(3,1,3)
spectrogram(enhanced,512,400,512,Fs,'yaxis')
title("Oracle Wiener")
