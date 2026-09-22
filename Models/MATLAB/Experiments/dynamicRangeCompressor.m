%% Project 241 - Digital Hearing Aid
% Milestone 4
% Dynamic Range Compression


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



%% Compressor Parameters


threshold_dB = -35;


ratio = 3;


makeupGain = 10;



%% Frame Processing


frameLength = 320;

hop = 160;


window=hann(frameLength);



numFrames=floor((length(x)-frameLength)/hop)+1;


output=zeros(size(x));


gainHistory=zeros(numFrames,1);



%% Compression


for i=1:numFrames


    index=(i-1)*hop+1;


    frame=x(index:index+frameLength-1);


    frameWindowed=frame.*window;



    % RMS Level

    rmsLevel=sqrt(mean(frameWindowed.^2)+eps);



    level_dB=20*log10(rmsLevel);



    % Calculate gain


    if level_dB > threshold_dB


        compressed_dB = ...
            threshold_dB + ...
            (level_dB-threshold_dB)/ratio;


        gain_dB = compressed_dB-level_dB;


    else


        gain_dB = makeupGain;


    end



    gain = 10^(gain_dB/20);



    gainHistory(i)=gain;



    enhancedFrame=frame*gain;



    output(index:index+frameLength-1)=...
        output(index:index+frameLength-1)+...
        enhancedFrame.*window;


end



%% Normalize


output=output/max(abs(output));



%% Compare


figure


subplot(2,1,1)

plot(x)

title("Original Speech")



subplot(2,1,2)

plot(output)

title("Compressed Output")



%% Gain Plot


figure

plot(gainHistory)

title("Compressor Gain")

xlabel("Frame")

ylabel("Gain")

grid on



%% Listen


sound(output,Fs)