%% Project 241 - Digital Hearing Aid
% Milestone 3.5
% VAD Guided Adaptive Wiener Filter (Debug Version)


clc;
clear;
close all;


%% Load Speech

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
% Same timing as VAD

frameLength = 320;

hop = 160;

nfft = 512;


window = hann(frameLength);



%% STFT

[Y,F,T] = stft(noisy,Fs,...
    "Window",window,...
    "OverlapLength",frameLength-hop,...
    "FFTLength",nfft);



Ypower = abs(Y).^2;


numFrames = size(Ypower,2);



%% =========================
% VAD
% ==========================


energy=zeros(numFrames,1);

flatness=zeros(numFrames,1);



for k=1:numFrames


    start=(k-1)*hop+1;


    if start+frameLength-1 <= length(noisy)

        frame=noisy(start:start+frameLength-1).*window;


        energy(k)=mean(frame.^2);


        spec=abs(fft(frame));

        spec=spec(1:nfft/2);


        flatness(k)=exp(mean(log(spec+eps)))...
            /(mean(spec)+eps);

    end

end



energy=(energy-min(energy))/...
    (max(energy)-min(energy)+eps);


flatness=(flatness-min(flatness))/...
    (max(flatness)-min(flatness)+eps);



speechScore = ...
    0.7*energy + ...
    0.3*(1-flatness);



threshold = prctile(speechScore,50);


speechDetected = speechScore > threshold;



fprintf("Speech Frames detected: %d / %d\n",...
    sum(speechDetected),numFrames);



%% Adaptive Noise Tracking

noisePSD=zeros(size(Ypower));


% Initial estimate

noiseFrames=find(~speechDetected);


initialFrames=noiseFrames(1:min(20,length(noiseFrames)));


noisePSD(:,1)=mean(Ypower(:,initialFrames),2);



alpha=0.98;


for k=2:numFrames


    if speechDetected(k)==0
        
        noisePSD(:,k)=...
            alpha*noisePSD(:,k-1)+...
            (1-alpha)*Ypower(:,k);

    else
        
        noisePSD(:,k)=noisePSD(:,k-1);

    end


end



%% =========================
% Wiener Filter
% ==========================


G = (Ypower-noisePSD)./(Ypower+eps);



% Conservative gain

G=max(G,0.7);

G=min(G,1);



%% Apply Filter


Yenhanced = G.*Y;



%% Reconstruction


enhanced = istft(Yenhanced,Fs,...
    "Window",window,...
    "OverlapLength",frameLength-hop,...
    "FFTLength",nfft);



%% Length Matching


L=min([length(x),length(noisy),length(enhanced)]);


x_eval=x(1:L);

noisy_eval=noisy(1:L);

enhanced_eval=enhanced(1:L);



%% SNR


beforeSNR = snr(noisy_eval,noisy_eval-x_eval);


afterSNR = snr(enhanced_eval,enhanced_eval-x_eval);



fprintf("\nBefore Enhancement SNR: %.2f dB\n",beforeSNR)

fprintf("After Enhancement SNR: %.2f dB\n",afterSNR)

fprintf("Improvement: %.2f dB\n",afterSNR-beforeSNR)



%% =========================
% Debug Plots
% ==========================


figure


subplot(3,1,1)

spectrogram(x_eval,512,400,512,Fs,'yaxis')

title("Clean Speech")



subplot(3,1,2)

spectrogram(noisy_eval,512,400,512,Fs,'yaxis')

title("Noisy Speech")



subplot(3,1,3)

spectrogram(enhanced_eval,512,400,512,Fs,'yaxis')

title("VAD Wiener Output")




figure


subplot(2,1,1)

imagesc(10*log10(Ypower+eps))

axis xy

title("Noisy Spectrum")



subplot(2,1,2)

imagesc(10*log10(noisePSD+eps))

axis xy

title("Estimated Noise Spectrum")



%% Listen

sound(enhanced_eval,Fs)