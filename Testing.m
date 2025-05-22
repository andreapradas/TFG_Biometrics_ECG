%% Testing script

clc; clear all;
addpath(genpath('..'));% Aggregate the main folder + directories

if ~exist('Database','dir') 
    error("Database folder not found.");
end
utils = ECGutils;
global mit ptb;
%% Select the DB to work with
numSubjects = 1;
mit = 0; % Database MIT-BIH is used
ptb = 1; % Database PTB is used
gr = 0; % Flag to generate figures or not
min_duration = 90; % In seconds
snr_imp = [];
ecg_segmented_storage = [];
if mit
    mit_path = 'Database/physionet.org/files/mitdb/1.0.0/';
    fileList = dir(fullfile(mit_path, '*.hea')); 
    numSubjects = length(fileList);
end
if ptb
    ptb_path  = 'Database/physionet.org/files/ptb-diagnostic-ecg-database-1.0.0/';
    subjectFolders = dir(fullfile(ptb_path, 'patient*'));
    %numSubjects = length(subjectFolders);
end
%% Process patients 
for i = 1:numSubjects
    if mit
        subjectID = erase(fileList(i).name, ".hea");
        subjectPath = fullfile(mit_path, fileList(i).name);
        recordingPath = char(strrep(fullfile('./', mit_path, subjectID),'\', '/')); % As wfdb is in /Utilities/mcode
        try
            [raw_ecg, fs] = rdsamp(recordingPath, [1]); 
%             if length(raw_ecg) < min_duration * fs
%                 warning("Recording %s is too short, it will be discarded.", subjectID);
%                 continue;
%             end
            raw_ecg = raw_ecg(1: min_duration * fs); % To achieve a consistent dimension of arrays being concatenated
        catch ME
            warning("Error reading the file %s.", subjectID);
        end
        try
            [pqrst_features_struct, snr_imp_i] = process_ECG(raw_ecg, subjectID, fs, gr);
            pqrst_features_struct = pqrst_features_struct(:);
            ecg_segmented_storage = [ecg_segmented_storage; pqrst_features_struct];
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
         %for j = 1:2
            recordName = recordings(j).name(1:end-4); 
            recordName = string(recordName);
            subjectID = string(subjectID);
            try
                recordingPath = char(strrep(fullfile('./', subjectPath, recordName),'\', '/')); % As wfdb is in /Utilities/mcode
                [raw_ecg, fs, ~] = rdsamp(recordingPath, [1]); 
                if length(raw_ecg) < min_duration * fs
                    warning("Recording %s is too short, it will be discarded.", subjectID);
                    continue;
                end
                raw_ecg = raw_ecg(1: min_duration* fs); % To achieve a consistent dimension of arrays being concatenated
            catch ME
                warning("Error reading %s: %s", recordName, ME.message);
            end
            try 
                [pqrst_features_struct, snr_imp_i] = process_ECG(raw_ecg, subjectID, fs, gr);
                pqrst_features_struct = pqrst_features_struct(:);
                ecg_segmented_storage = [ecg_segmented_storage; pqrst_features_struct];
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
%save("ecg_segmented_storage_MIT_5ss_15min.mat", "ecg_segmented_storage");

%% Identification (kNN + RF)
%performance_struct = ECG_Identification(ecg_segmented_storage, gr);

