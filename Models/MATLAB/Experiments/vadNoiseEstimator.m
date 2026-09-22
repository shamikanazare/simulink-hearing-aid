%% Project 241 - Digital Hearing Aid
% Milestone 3.3
% Voice Activity Detection Based Noise Estimation

clc;
clear;
close all;


%% Load Audio

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

frameDuration = 0.02;   % 20 ms

frameLength = round(frameDuration*Fs);

hop = frameLength/2;


%% Number of Frames

numFrames = floor((length(noisy)-frameLength)/hop)+1;


energy = zeros(numFrames,1);



%% Calculate Frame Energy

for i = 1:numFrames

    startIndex = round((i-1)*hop)+1;

    frame = noisy(startIndex:startIndex+frameLength-1);

    energy(i)=sum(frame.^2);

end



%% Normalize Energy

energy = energy/max(energy);



%% Plot Energy

figure;

plot(energy)

xlabel("Frame Number")

ylabel("Normalized Energy")

title("Frame Energy for VAD")

grid on



%% Threshold

threshold = 0.1;


speechFrames = energy > threshold;



figure;

subplot(2,1,1)

plot(energy)

hold on

yline(threshold,'r')

title("Energy Threshold")


subplot(2,1,2)

stem(speechFrames)

title("Detected Speech Frames")