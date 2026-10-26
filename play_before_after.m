%% Simulink Hearing Aid - Audio Comparison Utility
% Use this script to play the ORIGINAL (Before) audio vs PROCESSED (After)

clc;
root = fileparts(mfilename('fullpath'));
audioFile = fullfile(root, 'Data', 'datasets', 'TIMIT', ...
    'TRAIN', 'DR1', 'FCJF0', 'SA1.WAV');

fprintf('====================================================\n');
fprintf('  HEARING AID AUDIO DEMO: BEFORE vs AFTER\n');
fprintf('====================================================\n');
fprintf('Sentence: "She had your dark suit in greasy wash water all year."\n\n');

% 1. Read Original Audio
[y, Fs] = audioread(audioFile);

fprintf('--> [1/2] Playing ORIGINAL (Before) speech...\n');
sound(y, Fs);

% Wait for playback to finish
pause(length(y)/Fs + 1.5);

fprintf('\n--> [2/2] Now starting SIMULINK simulation for PROCESSED (After) speech...\n');
run_hearingaid;
