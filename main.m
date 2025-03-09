%     Main document - ECG Biometry
% 
% 
% 
% 
% 
% 
% 
% 
%
%% Introduction

clc; clear all;
utils = ECGutils;
if ~exist('Database','dir') 
    
end
addpath(genpath('..'));% To aggregate the main folder + directories
cd("Database\physionet.org\files\mitdb\1.0.0\");

[raw_ecg, fs, ~] = rdsamp('100',[1]); % Just 1 deviation is studied
cd("..\..\..\..\..\"); % Return to the main directory

gr = 1; % Flag tox generate plots (1 = plot, 0 = no plot)
t = (0:length(raw_ecg)-1) / fs; % Time in seconds

% Plot the raw ecg signal in TIME domain
if gr
    utils.plotTimeDomain(t, raw_ecg, 'Raw ECG Signal', 'b');
end
%% Normalization of the signal

raw_ecg = raw_ecg - mean(raw_ecg);  % Centralize the signal in 0
raw_ecg = raw_ecg / max(abs(raw_ecg));

if gr
    utils.plotTimeDomain(t, raw_ecg,'Raw ECG Signal (Normalized)', 'b');
    xlim([0 0.7]);
end
%% FFT (Freq. domain)

[f, module, phase] = utils.computeFFT(raw_ecg, fs);

if gr
    % Subplot with Magnitude and Phase of the FFT
    figure;
    subplot(2,1,1);
    utils.plotFrequencyDomain(f, module, 'Magnitude of the FFT', 'b');
    subplot(2,1,2);
    utils.plotFrequencyDomain(f, phase, 'Phase of the FFT', 'b');
    
    % Zoomed-in region around 60 Hz
    figure;
    utils.plotFrequencyDomain(f, module, 'Zoomed-in FFT (Before filtering, 60 Hz)', 'b');
    xlim([50 70]);
end
% SNR
SNR = utils.computeSNR(raw_ecg, fs, [0.5 40], [59 61]);

%% Filtering Process (Denoising ECG: Powerline Interference + Baseline Wander + Other artifacts)

ecg_filtered = ECG_Complete_Filtering(raw_ecg, fs, gr);

%% Feature Extraction (RR interval + Autocorrelation + Wavelet Transform)

patient_ecg_features = ECG_Feature_Extraction(ecg_filtered, fs, gr);


%% Identification (k-NN + SVM)


