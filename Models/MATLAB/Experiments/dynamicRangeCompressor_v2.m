%% Project 241 - Digital Hearing Aid
% Milestone 4.1
% Envelope Based Dynamic Range Compressor


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



%% Create Hearing Aid Input

targetSNR = 5;

inputSignal = awgn(x,targetSNR,'measured');



%% Compressor Parameters


threshold_dB = -35;


ratio = 3;


maxGain_dB = 15;



attackTime = 0.010;     % 10 ms

releaseTime = 0.100;    % 100 ms



%% Envelope Parameters


alphaAttack = exp(-1/(Fs*attackTime));

alphaRelease = exp(-1/(Fs*releaseTime));



%% Processing


N = length(inputSignal);


output = zeros(size(inputSignal));


envelope = zeros(size(inputSignal));


gainHistory = zeros(size(inputSignal));



currentEnvelope = 0;

currentGain = 1;



for n = 1:N


    sample = inputSignal(n);



    % Envelope detector

    rectified = abs(sample);



    if rectified > currentEnvelope

        currentEnvelope = ...
            alphaAttack*currentEnvelope + ...
            (1-alphaAttack)*rectified;

    else

        currentEnvelope = ...
            alphaRelease*currentEnvelope + ...
            (1-alphaRelease)*rectified;

    end



    envelope(n)=currentEnvelope;



    %% Level calculation


    level_dB = 20*log10(currentEnvelope+eps);



    %% Gain computer


    if level_dB > threshold_dB


        compressedLevel = ...
            threshold_dB + ...
            (level_dB-threshold_dB)/ratio;


        gain_dB = compressedLevel-level_dB;


    else


        gain_dB = threshold_dB-level_dB;


    end



    % Limit gain

    gain_dB = min(gain_dB,maxGain_dB);



    targetGain = 10^(gain_dB/20);



    % Smooth gain changes

    currentGain = ...
        0.995*currentGain + ...
        0.005*targetGain;



    gainHistory(n)=currentGain;



    output(n)=sample*currentGain;


end



%% Normalize


output = output/max(abs(output));



%% Listen


disp("Playing noisy input")

sound(inputSignal,Fs)

pause(length(inputSignal)/Fs+1)



disp("Playing compressed output")

sound(output,Fs)



%% Plots


figure


subplot(3,1,1)

plot(inputSignal)

title("Noisy Input")



subplot(3,1,2)

plot(output)

title("Compressed Output")



subplot(3,1,3)

plot(20*log10(gainHistory))

title("Gain Variation (dB)")

xlabel("Samples")

ylabel("Gain dB")

grid on