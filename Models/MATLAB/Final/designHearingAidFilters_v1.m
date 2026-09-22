%% designHearingAidFilters_v1
% Final 3-band FIR hearing-loss compensation filter bank
% Designed for Simulink Hearing Aid System
%
% Sampling frequency: 16 kHz
% Common filter order: 376
% Common filter length: 377 taps
% Common linear-phase group delay: 188 samples = 11.75 ms

clear;
clc;

Fs = 16000;
FilterOrder = 376;

%% ================================================================
%  1. LOW-BAND FIR
%  Passband: 0 - 300 Hz
%  Transition: 300 - 400 Hz
% ================================================================

bLow = fir1( ...
    FilterOrder, ...
    350/(Fs/2), ...
    'low', ...
    kaiser(FilterOrder + 1, 5.65));

%% ================================================================
%  2. MID-BAND FIR
%  Passband: 400 - 3000 Hz
%  Transition bands around the passband
% ================================================================

bMid = fir1( ...
    FilterOrder, ...
    [350 3500]/(Fs/2), ...
    'bandpass', ...
    kaiser(FilterOrder + 1, 5.65));

%% ================================================================
%  3. HIGH-BAND FIR
%  Passband: 3500 - 8000 Hz
% ================================================================

bHigh = fir1( ...
    FilterOrder, ...
    3500/(Fs/2), ...
    'high', ...
    kaiser(FilterOrder + 1, 5.65));

%% ================================================================
%  PRESCRIPTION GAINS
% ================================================================

gainLow  = 10^(2.50/20);
gainMid  = 10^(7.50/20);
gainHigh = 10^(18.75/20);

%% ================================================================
%  VALIDATION
% ================================================================

assert(length(bLow)  == FilterOrder + 1, ...
    'Low-band filter has incorrect length.');

assert(length(bMid)  == FilterOrder + 1, ...
    'Mid-band filter has incorrect length.');

assert(length(bHigh) == FilterOrder + 1, ...
    'High-band filter has incorrect length.');

assert(all(isfinite(bLow)), ...
    'Low-band coefficients contain non-finite values.');

assert(all(isfinite(bMid)), ...
    'Mid-band coefficients contain non-finite values.');

assert(all(isfinite(bHigh)), ...
    'High-band coefficients contain non-finite values.');

%% ================================================================
%  FILTER INFORMATION
% ================================================================

GroupDelaySamples = FilterOrder/2;
GroupDelaySeconds = GroupDelaySamples/Fs;

fprintf('\n');
fprintf('==============================================\n');
fprintf(' FINAL HEARING AID FIR FILTER BANK\n');
fprintf('==============================================\n');
fprintf('Sampling rate       : %d Hz\n', Fs);
fprintf('Common filter order : %d\n', FilterOrder);
fprintf('Filter length       : %d taps\n', FilterOrder + 1);
fprintf('Group delay         : %d samples\n', GroupDelaySamples);
fprintf('Group delay         : %.2f ms\n', GroupDelaySeconds*1000);

fprintf('\nPrescription gains:\n');
fprintf('Low-band gain       : %.4f (+2.50 dB)\n', gainLow);
fprintf('Mid-band gain       : %.4f (+7.50 dB)\n', gainMid);
fprintf('High-band gain      : %.4f (+18.75 dB)\n', gainHigh);

fprintf('\nFilter lengths:\n');
fprintf('Low                 : %d taps\n', length(bLow));
fprintf('Mid                 : %d taps\n', length(bMid));
fprintf('High                : %d taps\n', length(bHigh));

fprintf('\nCoefficient validation:\n');
fprintf('Low                 : %d finite / %d total\n', ...
    sum(isfinite(bLow)), length(bLow));
fprintf('Mid                 : %d finite / %d total\n', ...
    sum(isfinite(bMid)), length(bMid));
fprintf('High                : %d finite / %d total\n', ...
    sum(isfinite(bHigh)), length(bHigh));

fprintf('\nFilter bank design completed successfully.\n');
fprintf('==============================================\n\n');

%% ================================================================
%  SAVE FINAL FILTER BANK
% ================================================================

save('hearingAidFIRFilters_v1.mat', ...
    'Fs', ...
    'FilterOrder', ...
    'GroupDelaySamples', ...
    'GroupDelaySeconds', ...
    'bLow', ...
    'bMid', ...
    'bHigh', ...
    'gainLow', ...
    'gainMid', ...
    'gainHigh');