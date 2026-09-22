%% Simulink Hearing Aid - Main Entry Point

clc;
clear;
close all;

root = fileparts(mfilename('fullpath'));

modelFile = fullfile(root, ...
    'Models', 'Simulink', 'hearingAid_System_v1.slx');

filterFile = fullfile(root, ...
    'Models', 'MATLAB', 'Final', 'hearingAidFIRFilters_v1.mat');

modelName = 'hearingAid_System_v1';

% Close model if already loaded (avoids "changed on disk" warning)
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end

% Load hearing-aid filter coefficients
load(filterFile, 'bLow', 'bMid', 'bHigh');

% Open the model freshly from disk
open_system(modelFile);

% Fix audio input path to use this machine's actual repo location
audioFile = fullfile(root, 'Data', 'datasets', 'TIMIT', ...
    'TRAIN', 'DR1', 'FCJF0', 'SA1.WAV');
audioBlock = [modelName '/Audio Input/From Multimedia File'];
set_param(audioBlock, 'inputFilename', audioFile);

% Run the Simulink model
sim(modelFile);