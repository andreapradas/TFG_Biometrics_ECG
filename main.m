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
    error("Database folder not found.");
end
addpath(genpath('..'));% To aggregate the main folder + directories
cd("Database\physionet.org\files\mitdb\1.0.0\");
fileList = dir("*.hea");  
numPatients = length(fileList);
patients_features(numPatients) = struct('patientID', '', 'features', []);


for i = 1:1
    patientID = erase(fileList(i).name, ".hea");
    
    try
        [raw_ecg, fs, ~] = rdsamp(patientID, [1]); % Just 1 deviation is studied
    catch
        warning("Error reading the file %s.", patientID);
        continue;
    end

    gr = 1; % Flag to generate plots (1 = plot, 0 = no plot)
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

    %% Filtering Process (Denoising ECG: Powerline Interference + Baseline Wander + Other artifacts)
    
    ecg_filtered = ECG_Complete_Filtering(raw_ecg, fs, gr);

    % SNR
    SNR_before = utils.computeSNR(raw_ecg, fs, [0.5 40], [59 61]);
    SNR_after = utils.computeSNR(ecg_filtered, fs, [0.5 40], [59 61]);
    fprintf("Patient %s - SNR Before: %.2f dB | SNR After: %.2f dB\n", patientID, SNR_before, SNR_after);
    
    %% Feature Extraction (RR interval + AC/DCT + Wavelet Transform)
    
    patient_ecg_features = ECG_Feature_Extraction(ecg_filtered, fs, gr);
    patients_features(i).patientID = patientID;
    patients_features(i).features = patient_ecg_features;
    

    fprintf("Patient %s processed successfully.\n", patientID);

end

cd("..\..\..\..\..\"); % Return to the main directory
save("patients_features.mat", "patients_features");

%% Identification (k-NN + SVM)


