%==========================================================================
%                     ECG Biometry - Main Processing Script
%
%   This script loads and processes ECG signals for biometric identification.
%   It supports both PTB and MIT-BIH databases and includes:
%     - Preprocessing (normalization and filtering)
%     - Feature extraction (per recording or segment)
%     - SNR improvement analysis
%     - Storage of structured data for further identification
%     - Identification using machine learning classifier (kNN)
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
mit = 0; % Database MIT-BIH is used
ptb = 1; % Database PTB is used
numBeats_win = 10;
save_flag = 0; % Flag to save storage structures 
gr = 0; % Flag to generate figures or not
snr_imp = [];
ecg_segmented_features_storage = [];
if mit
    load("ecg_filtered_storage_MIT.mat", 'ecg_filtered_storage');
    mit_path = 'Database/physionet.org/files/mitdb/1.0.0/';
    fileList = dir(fullfile(mit_path, '*.hea')); 
    numSubjects = length(fileList);
    fs = 360;
elseif ptb
    load("ecg_filtered_storage_PTB.mat", 'ecg_filtered_storage');
    ptb_path  = 'Database/physionet.org/files/ptb-diagnostic-ecg-database-1.0.0/';
    subjectFolders = dir(fullfile(ptb_path, 'patient*'));
    %numSubjects = length(patientFolders);
    % Eliminate recordings appearing just 1 time
    ids = string(arrayfun(@(x) x.subjectID, ecg_filtered_storage, 'UniformOutput', false));
    [uid, ~, idx] = unique(ids);
    ecg_filtered_storage = ecg_filtered_storage(ismember(ids, uid(histcounts(idx, 1:numel(uid)+1) > 1)));
    numSubjects = length(ecg_filtered_storage);
    index = 1; 
    fs = 1000;
end

%% Feature Extraction 

for i=1:numSubjects
    subjectID = ecg_filtered_storage(i).subjectID;
    ecg_filtered_subject = ecg_filtered_storage(i).filtered_ecg;
    [interval_features_struct] = Beats_Feature_Extraction(ecg_filtered_subject, numBeats_win, subjectID, fs, gr);
    if isempty(fieldnames(interval_features_struct))
        disp(['Skipping subject ', num2str(subjectID), ' due to empty features.']);
        continue;
    end
    interval_features_struct = interval_features_struct(:);
    ecg_segmented_features_storage = [ecg_segmented_features_storage; interval_features_struct];
    fprintf("Individual %s processed successfully.\n", subjectID);
end

%% Save structure
if save_flag
    save("ecg_segmented_storage_MIT_1beatNOoverlapp.mat", "ecg_segmented_features_storage");
end 

%% Identification (kNN)
predictedLabel = ECG_Identification(ecg_segmented_features_storage, gr);
