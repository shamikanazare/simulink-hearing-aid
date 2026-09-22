%% Project 241 - Digital Hearing Aid
% Decision Directed Wiener Filter v2
% Speech Preservation Improved Version


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

frameLength = 320;     % 20 ms @ 16 kHz

hop = 160;             % 10 ms shift


window = hann(frameLength);



numFrames = floor((length(noisy)-frameLength)/hop)+1;


fprintf("Frames: %d\n",numFrames)



%% Initialization


enhanced = zeros(size(noisy));


% Noise power estimate

noisePower = zeros(frameLength,1);



% Previous enhanced speech spectrum

previousSpeech = zeros(frameLength,1);



% Smoothing factor

alpha = 0.95;



%% Processing Loop


for i = 1:numFrames


    startIndex = (i-1)*hop + 1;



    frame = noisy(startIndex:startIndex+frameLength-1);



    % Windowing

    frame = frame .* window;



    % FFT

    Y = fft(frame);



    powerSpectrum = abs(Y).^2;



    %% Noise Estimation


    if i <= 5
        
        % Initial noise estimate
        
        noisePower = noisePower + powerSpectrum/5;


    else
        
        % Conservative noise tracking
        
        noisePower = alpha*noisePower + ...
            (1-alpha)*min(noisePower,powerSpectrum);

    end



    %% A Posteriori SNR


    gamma = powerSpectrum ./ ...
        (noisePower + eps);



    %% Decision Directed A Priori SNR


    xi = alpha*(abs(previousSpeech).^2 ./ ...
        (noisePower + eps)) ...
        +(1-alpha)*max(gamma-1,0);



    % Limit excessive gain

    xi = min(xi,20);



    %% Wiener Gain


    gain = xi ./ (1+xi);



    % Speech preservation floor

    gain = max(gain,0.3);



    %% Apply Gain


    enhancedSpectrum = gain .* Y;



    % Store previous speech estimate

    previousSpeech = enhancedSpectrum;



    %% IFFT


    enhancedFrame = real(ifft(enhancedSpectrum));



    %% Overlap Add


    enhanced(startIndex:startIndex+frameLength-1) = ...
        enhanced(startIndex:startIndex+frameLength-1) + ...
        enhancedFrame .* window;


end



%% Normalize


enhanced = enhanced/max(abs(enhanced));



%% SNR Evaluation


L = min([length(x),length(noisy),length(enhanced)]);



cleanEval = x(1:L);

noisyEval = noisy(1:L);

enhancedEval = enhanced(1:L);



beforeSNR = snr(noisyEval,noisyEval-cleanEval);


afterSNR = snr(enhancedEval,enhancedEval-cleanEval);



fprintf("\n")

fprintf("Before SNR: %.2f dB\n",beforeSNR)

fprintf("After SNR: %.2f dB\n",afterSNR)

fprintf("Improvement: %.2f dB\n",afterSNR-beforeSNR)



%% Spectrogram Comparison


figure;


subplot(3,1,1)

spectrogram(cleanEval,512,400,512,Fs,'yaxis')

title("Clean Speech")



subplot(3,1,2)

spectrogram(noisyEval,512,400,512,Fs,'yaxis')

title("Noisy Speech (5 dB SNR)")



subplot(3,1,3)

spectrogram(enhancedEval,512,400,512,Fs,'yaxis')

title("Decision Directed Wiener v2")



%% Listen

sound(enhancedEval,Fs)