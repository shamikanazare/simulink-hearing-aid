%% Project 241 - Digital Hearing Aid
% Milestone 3.4
% Speech Activity Detection Analysis


clc;
clear;
close all;



%% Load Speech


audioPath = "C:\Users\admin\Desktop\SHARIF OS\01 Engineering\02 Projects\01 Active\Simulink-Hearing-Aid\data\datasets\TIMIT\TRAIN\DR1\FDAW0\SA1.WAV";


[x,Fs] = audioread(audioPath);



if size(x,2)>1
    x=mean(x,2);
end


x=x/max(abs(x));



%% Add Noise


targetSNR = 5;

noisy = awgn(x,targetSNR,'measured');



%% Frame Parameters


frameLength = 320;     %20 ms

hop = 160;             %10 ms


window = hann(frameLength);



numFrames = floor((length(noisy)-frameLength)/hop)+1;



fprintf("Number of Frames: %d\n",numFrames)



%% Feature Storage


energy = zeros(numFrames,1);

zcr = zeros(numFrames,1);

flatness = zeros(numFrames,1);



%% Feature Extraction


for i=1:numFrames


    index=(i-1)*hop+1;


    frame=noisy(index:index+frameLength-1);


    frame=frame.*window;



    % Energy

    energy(i)=mean(frame.^2);



    % Zero Crossing Rate

    signs = sign(frame);

    zcr(i)=sum(abs(diff(signs)))/(2*length(frame));



    % Spectral Flatness

    spectrum=abs(fft(frame));

    spectrum=spectrum(1:frameLength/2);



    geometricMean=exp(mean(log(spectrum+eps)));

    arithmeticMean=mean(spectrum+eps);



    flatness(i)=geometricMean/arithmeticMean;



end



%% Normalize Features


energyN=(energy-min(energy)) / ...
    (max(energy)-min(energy)+eps);


zcrN=(zcr-min(zcr)) / ...
    (max(zcr)-min(zcr)+eps);


flatnessN=(flatness-min(flatness)) / ...
    (max(flatness)-min(flatness)+eps);



%% Speech Probability Score


speechScore = ...
    0.7*energyN + ...
    0.2*(1-flatnessN) + ...
    0.1*(1-zcrN);



%% Adaptive Threshold

lowScore = prctile(speechScore,20);

highScore = prctile(speechScore,80);


threshold = lowScore + 0.4*(highScore-lowScore);


speechDetected = speechScore > threshold;



%% Results


figure;


subplot(4,1,1)

plot(energyN)

title("Normalized Energy")

grid on



subplot(4,1,2)

plot(zcrN)

title("Zero Crossing Rate")

grid on



subplot(4,1,3)

plot(flatnessN)

title("Spectral Flatness")

grid on



subplot(4,1,4)

stem(speechDetected)

title("Speech Detection")

xlabel("Frame")

ylabel("Speech = 1")

grid on



fprintf("\nSpeech Frames: %d / %d\n",...
    sum(speechDetected),numFrames);


