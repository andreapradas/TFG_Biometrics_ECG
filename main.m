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
if ~exist('Database','dir') 
    error("Database folder not found.");
end
addpath(genpath('..'));% Aggregate the main folder + directories
utils = ECGutils;

%% Select the DB to work with
mit = 0;
ptb = 1; % Is studied one DB at a time (no mixed)
gr = 0; % Flag to generate plots (1 = plot, 0 = no plot)
snr_imp = [];
if mit
    cd("Database\physionet.org\files\mitdb\1.0.0\");
    fileList = dir("*.hea");  
    numPatients = length(fileList);
    patients_struct(numPatients) = struct('patientID', '', 'features', []);
end
if ptb
    cd("Database\physionet.org\files\ptb-diagnostic-ecg-database-1.0.0\");
    patientFolders = dir; 
    patientFolders = patientFolders([patientFolders.isdir]); 
    patientFolders = patientFolders(~ismember({patientFolders.name}, {'.', '..'}));
    numPatients = length(patientFolders);
    patients_struct(numPatients) = struct('patientID', '', 'features', []);
end
%% Process all the ECG recordings at a time
for i = 1:numPatients
    if mit
        patientID = erase(fileList(i).name, ".hea");
        try
            [raw_ecg, fs, ~] = rdsamp(patientID, [1]); % Just 1 deviation is studied
            split_point = fs * 900; % 900 seconds = 15 minutes
            raw_ecg = raw_ecg(1:split_point, :);
        catch ME
            warning("Error reading the file %s.", patientID);
        end
    end
    if ptb
        patientID = patientFolders(i).name;
        cd(patientID);
        patientID = erase(patientID, "patient"); % Mantain only the nº
        recordings = dir('*.hea');
        numRecordings = length(recordings);
        recordings_struct(numRecordings) = struct('patientID', '', 'raw_ecg', []);

        for j = 1:numRecordings
            recordName = recordings(j).name(1:end-4);
            try
                [raw_ecg, fs, ~] = rdsamp(recordName, [1]); % Just 1 deviation is studied
                recordings_struct(j).patientID = recordName;
                recordings_struct(j).raw_ecg = raw_ecg;
            catch ME
                warning("Error reading %s: %s", recordName, ME.message);
            end
        end
        cd ..; 
    end

    % Plot the raw ecg signal in TIME domain
    if gr
        t = (0:length(raw_ecg)-1) / fs; % Time in seconds
        utils.plotTimeDomain(t, raw_ecg, 'Raw ECG Signal', 'b');
    end
    %% Normalization (Min-Max) of the signal

    raw_ecg_norm = (raw_ecg - min(raw_ecg))/(max(raw_ecg)-min(raw_ecg));
    if gr
        utils.plotTimeDomain(t, raw_ecg_norm,'Normalized ECG Signal', 'b');
        xlim([0 0.7]);
    end
    %% FFT (Freq. domain)
        
    if gr
        [f, module, phase] = utils.computeFFT(raw_ecg_norm, fs);
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
    
    ecg_filtered = ECG_Complete_Filtering(raw_ecg_norm, fs, gr);

    % Denoising performance metrics
    metrics_filtering = utils.evaluateFiltering(raw_ecg_norm, ecg_filtered, fs);
    snr_imp = [snr_imp; metrics_filtering];
    if gr
        T = array2table(metrics_filtering, 'VariableNames', varNames, 'RowNames', rowNames);
        disp('SNR Improvement Table:');
        disp(T);
    end

    %% Feature Extraction (RR interval + AC/DCT + Wavelet Transform)
    
    patient_ecg_features = ECG_Feature_Extraction(ecg_filtered, fs, gr);
    patients_struct(i).patientID = patientID;
    patients_struct(i).features = patient_ecg_features;
    
    fprintf("Patient %s processed successfully.\n", patientID);

end

if gr
    avg_SNR = mean(snr_imp, 1);
    fprintf('\n--- Mean SNR Improvement across all patients ---\n');
    fprintf('Mean SNR_PLI_Imp: %.2f dB\n', avg_SNR(1));
    fprintf('Mean SNR_BLW_Imp: %.2f dB\n', avg_SNR(2));
    fprintf('Mean SNR_HF_Imp : %.2f dB\n', avg_SNR(3));
end

cd("..\..\..\..\..\"); % Return to the main directory
save("patients_features_ptb.mat", "patients_struct");

%% Identification (k-NN + SVM)

% predictedLabel = ECG_Identification(patients_struct, gr);
