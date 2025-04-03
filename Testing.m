%% Testing script

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


%% Process patients + plot comparative between RAW vs FILTERED ECG

for i = 1:5
    % Extract patient ID from filename
    patientID = erase(fileList(i).name, ".hea");
    
    % Read raw ECG signal
    [raw_ecg, fs, ~] = rdsamp(patientID, [1]);
    t = (0:length(raw_ecg)-1) / fs;
    
    raw_ecg = raw_ecg - mean(raw_ecg); 
%     raw_ecg = raw_ecg / var(raw_ecg);
    raw_ecg = raw_ecg / max(abs(raw_ecg));

    ecg_filtered = ECG_Complete_Filtering(raw_ecg, fs, 0);

    % Plot comparison between raw and filtered ECG
%     utils.plotComparison(t, raw_ecg, ecg_filtered, ...
%                    ['Raw ECG - ' patientID], ...
%                    ['Filtered ECG - ' patientID]);

    patient_ecg_features = ECG_Feature_Extraction(ecg_filtered, fs, 0);
    patients_features(i).patientID = patientID;
    patients_features(i).features = patient_ecg_features;
    

    fprintf("Patient %s processed successfully.\n", patientID);
end

cd("..\..\..\..\..\");
save("patients_features.mat", "patients_features");
