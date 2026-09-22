%% Project 241 - Digital Hearing Aid
% Adaptive Wiener Filter with Noise Tracking
% Version: v1.1 Debug

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



%% Frame Parameters

% 20 ms frame
frameLength = round(0.02*Fs);

% 10 ms hop
hop = round(0.01*Fs);


window = hann(frameLength);



%% Number of Frames

numFrames = floor((length(noisy)-frameLength)/hop)+1;


fprintf("Sampling Frequency: %.0f Hz\n",Fs)

fprintf("Frame Length: %d samples\n",frameLength)

fprintf("Hop Size: %d samples\n",hop)

fprintf("Number of Frames: %d\n",numFrames)



%% Initialization

enhanced = zeros(size(noisy));


% Initial noise spectrum

noiseSpectrum = zeros(frameLength,1);



% Noise smoothing factor

alpha = 0.98;



% VAD threshold

threshold = 0.02;



% Debug storage

speechDecision = zeros(numFrames,1);

energyValues = zeros(numFrames,1);



%% Adaptive Wiener Processing


for i = 1:numFrames


    startIndex = (i-1)*hop + 1;


    frame = noisy(startIndex:startIndex+frameLength-1);



    % Apply window

    frameWindowed = frame .* window;



    % FFT

    Y = fft(frameWindowed);



    % Frame energy

    frameEnergy = mean(frame.^2);


    energyValues(i)=frameEnergy;



    % Voice activity detection

    isNoise = frameEnergy < threshold;



    if isNoise

        % Update noise estimate

        noiseSpectrum = alpha*noiseSpectrum + ...
            (1-alpha)*abs(Y).^2;

        speechDecision(i)=0;

    else

        speechDecision(i)=1;

    end



    %% Wiener Filter


    signalPower = abs(Y).^2 - noiseSpectrum;


    signalPower = max(signalPower,0);



    gain = signalPower ./ ...
        (signalPower + noiseSpectrum + eps);



    % Prevent removing speech completely

    gain = max(gain,0.1);



    % Apply filter

    enhancedSpectrum = gain .* Y;



    % IFFT

    enhancedFrame = real(ifft(enhancedSpectrum));



    % Overlap Add

    enhanced(startIndex:startIndex+frameLength-1) = ...
        enhanced(startIndex:startIndex+frameLength-1) + ...
        enhancedFrame .* window;



end



%% Normalize Output

enhanced = enhanced/max(abs(enhanced));



%% Match Length

L = min([length(x),length(noisy),length(enhanced)]);


x_eval = x(1:L);

noisy_eval = noisy(1:L);

enhanced_eval = enhanced(1:L);



%% SNR Evaluation


beforeSNR = snr(noisy_eval,noisy_eval-x_eval);


afterSNR = snr(enhanced_eval,enhanced_eval-x_eval);



fprintf("\n")

fprintf("Before SNR: %.2f dB\n",beforeSNR)

fprintf("After SNR: %.2f dB\n",afterSNR)

fprintf("Improvement: %.2f dB\n",afterSNR-beforeSNR)



%% VAD Visualization


figure;

plot(energyValues)

hold on

yline(threshold,'r','Threshold')

title("Frame Energy and VAD Threshold")

xlabel("Frame Number")

ylabel("Energy")

grid on



figure;

stem(speechDecision)

title("VAD Speech Decision")

xlabel("Frame Number")

ylabel("Speech = 1")

grid on



%% Spectrogram Comparison


figure;


subplot(3,1,1)

spectrogram(x_eval,512,400,512,Fs,'yaxis')

title("Clean Speech")



subplot(3,1,2)

spectrogram(noisy_eval,512,400,512,Fs,'yaxis')

title("Noisy Speech (5 dB SNR)")



subplot(3,1,3)

spectrogram(enhanced_eval,512,400,512,Fs,'yaxis')

title("Adaptive Wiener Output")



%% Listen

sound(enhanced_eval,Fs)