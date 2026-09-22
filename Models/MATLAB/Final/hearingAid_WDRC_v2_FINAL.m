%% Project 241 - Digital Hearing Aid
% Milestone 10
% Complete Audiogram Based Hearing Aid


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



%% =========================
% Patient Audiogram
% ==========================


freq = [500 1000 2000 4000 8000];


loss = [5 10 20 35 40];



figure

plot(freq,loss,'-o','LineWidth',2)

grid on

xlabel("Frequency (Hz)")

ylabel("Loss (dB)")

title("Patient Hearing Loss Profile")



%% =========================
% Filter Bank
% ==========================


lowFilter = designfilt('lowpassiir',...
    'FilterOrder',8,...
    'HalfPowerFrequency',1000,...
    'SampleRate',Fs);



midFilter = designfilt('bandpassiir',...
    'FilterOrder',8,...
    'HalfPowerFrequency1',1000,...
    'HalfPowerFrequency2',3000,...
    'SampleRate',Fs);



highFilter = designfilt('highpassiir',...
    'FilterOrder',8,...
    'HalfPowerFrequency',3000,...
    'SampleRate',Fs);



%% =========================
% Split Original Speech
% ==========================


low=filtfilt(lowFilter,x);

mid=filtfilt(midFilter,x);

high=filtfilt(highFilter,x);



%% =========================
% Apply Hearing Loss
% ==========================


lowLoss = low*10^(-loss(1)/20);


midLoss = mid*10^(-mean(loss(2:3))/20);


highLoss = high*10^(-mean(loss(4:5))/20);



impaired = lowLoss + midLoss + highLoss;


impaired = impaired/max(abs(impaired));



%% =========================
% Hearing Aid Fitting
% Half Gain Rule
% ==========================


lowGain = loss(1)/2;


midGain = mean(loss(2:3))/2;


highGain = mean(loss(4:5))/2;



fprintf("\nPrescription Gain\n")

fprintf("Low : %.2f dB\n",lowGain)

fprintf("Mid : %.2f dB\n",midGain)

fprintf("High: %.2f dB\n",highGain)



%% Split Impaired Signal


low2=filtfilt(lowFilter,impaired);

mid2=filtfilt(midFilter,impaired);

high2=filtfilt(highFilter,impaired);



%% Apply Compensation


lowOut = low2 * 10^(lowGain/20);

midOut = mid2 * 10^(midGain/20);

highOut = high2 * 10^(highGain/20);


output = lowOut + midOut + highOut;

%% =====================================
% Envelope Based WDRC
% ======================================


% Parameters

threshold_dB = -25;

compressionRatio = 3;


attackTime = 0.01;     % seconds

releaseTime = 0.1;    % seconds



% Envelope detection

envelope = abs(output);


% Smooth envelope

attackCoeff = exp(-1/(Fs*attackTime));

releaseCoeff = exp(-1/(Fs*releaseTime));


gain = zeros(size(output));

currentGain = 1;



for n = 1:length(output)

    
    level = envelope(n);


    level_dB = 20*log10(level+eps);


    if level_dB > threshold_dB
        
        gain_dB = ...
            -(level_dB-threshold_dB)...
            *(1-1/compressionRatio);

    else
        
        gain_dB = 0;

    end


    targetGain = 10^(gain_dB/20);



    if targetGain < currentGain
        
        coeff = attackCoeff;

    else
        
        coeff = releaseCoeff;

    end



    currentGain = coeff*currentGain + ...
        (1-coeff)*targetGain;



    gain(n)=currentGain;


end



compressed = output .* gain;



%% Output Protection


output = tanh(compressed);


output = output/max(abs(output));



%% Listen

disp("Original Speech")
sound(x,Fs)

pause(5)


disp("Hearing Loss Simulation")
sound(impaired,Fs)

pause(5)


disp("Hearing Aid Output")
sound(output,Fs)



%% =========================
% Spectrograms
% ==========================


figure


subplot(3,1,1)

spectrogram(x,512,400,512,Fs,'yaxis')

title("Original Speech")



subplot(3,1,2)

spectrogram(impaired,512,400,512,Fs,'yaxis')

title("Hearing Loss Simulation")



subplot(3,1,3)

spectrogram(output,512,400,512,Fs,'yaxis')

title("Hearing Aid Output")