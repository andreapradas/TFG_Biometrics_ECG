%% Testing script

clc; clear all;
addpath(genpath('..'));% Aggregate the main folder + directories

if ~exist('Database','dir') 
    error("Database folder not found.");
end
utils = ECGutils;

%% Select the DB to work with
numPatients = 1;
mit = 1;
ptb = 0; 
gr = 0;
snr_imp = [];
if mit
    cd("Database\physionet.org\files\mitdb\1.0.0\");
    fileList = dir("*.hea");  
    %numPatients = length(fileList);
    patients_struct_train(numPatients) = struct('patientID', '', 'features', []);
end
if ptb
    cd("Database\physionet.org\files\ptb-diagnostic-ecg-database-1.0.0\");
    patientFolders = dir; 
    patientFolders = patientFolders([patientFolders.isdir]); 
    patientFolders = patientFolders(~ismember({patientFolders.name}, {'.', '..'}));
    % numPatients = length(patientFolders);
    patients_struct_train(numPatients) = struct('patientID', '', 'features', []);
end
%% Process patients
for i = 1:numPatients
    if mit
        patientID = erase(fileList(i).name, ".hea");
        try
            [raw_ecg, fs] = rdsamp(patientID, [1]); 
            split_point = fs * 900;
            raw_ecg = raw_ecg(1:split_point, :);% First 15 minutes
        catch ME
            warning("Error reading the file %s.", patientID);
        end
        try
            [patient_ecg_features, snr_imp_i] = processECG(raw_ecg, fs, patientID, gr);
            patients_struct_train(i).patientID = patientID;
            patients_struct_train(i).features = patient_ecg_features;
            snr_imp = [snr_imp; snr_imp_i];
        catch ME
            warning("Error processing the ECG of %s: %s", patientID, ME.message);
        end
    end
    if ptb
        patientID = patientFolders(i).name;
        cd(patientID);
        patientID = erase(patientID, "patient"); % Mantain only the nº of the folderName
        recordings = dir('*.hea');
        numRecordings = length(recordings);
        for j = 1:numRecordings
            recordName = recordings(j).name(1:end-4); % Eliminate .hea extension
            try
                 [raw_ecg, fs, ~] = rdsamp(recordName, [1]); 
                 [patients_struct_train, snr_imp_i] = processECG(raw_ecg, fs, [patientID '_' recordName], patients_struct_train, i, gr); % To avoid overwriting
            catch ME
                warning("Error reading %s: %s", recordName, ME.message);
            end
        end
        cd ..;
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

%% Identification (kNN + SVM)
patients_struct_test(numPatients) = struct('patientID', '', 'features', []);
for i = 1:numPatients
    patientID = erase(fileList(i).name, ".hea");
    try
        [raw_ecg_test, fs] = rdsamp(patientID, [1]); 
        split_point = fs * 900;
        raw_ecg_test = raw_ecg_test(split_point+1:split_point+split_point, :);% Last 15 minutes (till the middle+1 up to 15 minutes)
    catch ME
        warning("Error reading the file %s", patientID);
    end
    try
        [patient_ecg_features, ~] = processECG(raw_ecg_test, fs, patientID, gr);
        patients_struct_test(i).patientID = patientID;
        patients_struct_test(i).features = patient_ecg_features;
    catch ME
        warning("Error processing the ECG of %s: %s", patientID, ME.message);
    end
end
cd("..\..\..\..\..\");
save("patients_features_train.mat", "patients_struct_train");
save("patients_features_test.mat", "patients_struct_test");
%% 
predictedLabel = ECG_Identification(patients_struct_train, patients_struct_test, 1);

