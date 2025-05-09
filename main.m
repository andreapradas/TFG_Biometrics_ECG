%==========================================================================
%                     ECG Biometry - Main Processing Script
%
%   This script loads and processes ECG signals for biometric identification.
%   It supports both PTB and MIT-BIH databases and includes:
%     - Preprocessing (normalization and filtering)
%     - Feature extraction (per recording or segment)
%     - SNR improvement analysis
%     - Storage of structured data for further identification
%     - Identification using machine learning classifiers (kNN, RF)
%
%   Author: Andrea Pradas
%   Date: 05-06-25
%==========================================================================
%% Introduction

clc; clear all;
addpath(genpath('..'));% Aggregate the main folder + directories

if ~exist('Database','dir') 
    error("Database folder not found.");
end
utils = ECGutils;
global mit ptb;
%% Select the DB to work with
mit = 1; % Database MIT-BIH is used
ptb = 0; % Database PTB is used
gr = 0; % Flag to generate figures or not
snr_imp = [];
ecg_segmented_storage = [];
if mit
    mit_path = 'Database/physionet.org/files/mitdb/1.0.0/';
    fileList = dir("*.hea"); 
    numSubjects = length(fileList);
end
if ptb
    ptb_path  = 'Database/physionet.org/files/ptb-diagnostic-ecg-database-1.0.0/';
    subjectFolders = dir(fullfile(ptb_path, 'patient*'));
    numSubjects = length(patientFolders);
    index = 1; 
end
%% Process patients 
for i = 1:numSubjects
    if mit
        subjectID = erase(fileList(i).name, ".hea");
        subjectPath = fullfile(mit_path, fileList(i).name);
        recordingPath = char(strrep(fullfile('./', subjectPath, subjectID),'\', '/')); % As wfdb is in /Utilities/mcode
        try
            [raw_ecg, fs] = rdsamp(recordingPath, [1]); 
        catch ME
            warning("Error reading the file %s.", subjectID);
        end
        try
            [subject_ecg_features, snr_imp_i] = processECG(raw_ecg, subjectID, fs, gr);
            ecg_segmented_storage(i).subjectID = subjectID;
            ecg_segmented_storage(i).features = subject_ecg_features;
            snr_imp = [snr_imp; snr_imp_i];
        catch ME
            warning("Error processing the ECG of %s: %s", subjectID, ME.message);
        end
    end
    if ptb
        subjectID = erase(subjectFolders(i).name, "patient");
        subjectPath = fullfile(ptb_path, subjectFolders(i).name);
        recordings = dir(fullfile(subjectPath, '*.hea'));
        for j = 1:length(recordings)
            recordName = recordings(j).name(1:end-4); 
            recordName = string(recordName);
            subjectID = string(subjectID);
            try
                recordingPath = char(strrep(fullfile('./', subjectPath, recordName),'\', '/')); % As wfdb is in /Utilities/mcode
                [raw_ecg, fs, ~] = rdsamp(recordingPath, [1]); 
                % uniqueID = patientID + '_' + recordName; % To differ
                % between recordings of the same subject
            catch ME
                warning("Error reading %s: %s", recordName, ME.message);
            end
            try 
                [subject_ecg_features, snr_imp_i] = processECG(raw_ecg, subjectID, fs, gr);
                ecg_segmented_storage(index).subjectID = subjectID;
                ecg_segmented_storage(index).features = subject_ecg_features;
                index = index + 1; % To avoid overwriting
                snr_imp = [snr_imp; snr_imp_i];
            catch ME
                warning("Error processing the ECG of %s: %s", recordName, ME.message);
            end
        end    
    end
end

%% Denoising performance metrics
avg_SNR = mean(snr_imp, 1);
if gr
    fprintf('\n--- Mean SNR Improvement across all patients ---\n');
    fprintf('Mean SNR_PLI_Imp: %.2f dB\n', avg_SNR(1));
    fprintf('Mean SNR_BLW_Imp: %.2f dB\n', avg_SNR(2));
    fprintf('Mean SNR_HF_Imp : %.2f dB\n', avg_SNR(3));
end

%% Data storage
save("patients_features.mat", "ecg_segmented_storage");

%% Prepare data for Identification





%% Identification (kNN + RF)
%predictedLabel = ECG_Identification(ecg_segmented_storage, gr);

