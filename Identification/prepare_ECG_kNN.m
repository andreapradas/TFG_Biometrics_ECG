% prepare_ECG_kNN processes a structure of ECG patient data to extract,
% normalize, and split feature vectors for machine learning classification tasks.
%
% This function takes a structure array of patients, extracts and processes
% features (RR intervals, DCT and DWT coefficients), and splits the resulting
% dataset into training and test sets based on a specified fraction.
%
% Parameters:
%   patients_struct - Structure array where each element contains:
%                     - patientID: Identifier string for each patient.
%                     - features: Struct with fields:
%                       * RR_intervals: Vector of RR intervals.
%                       * AC_DCT_coef: DCT-transformed autocorrelation coefficients.
%                       * DWT_feature: Discrete Wavelet Transform approximation coefficients.
%   targetLength    - Desired fixed length for RR interval vectors. If needed,
%                     the vectors are padded or truncated.
%   testFraction    - Fraction of patients to allocate to the test set (e.g., 0.2 for 20%).
%
% Returns:
%   trainFeatures   - Matrix of normalized feature vectors for training (patients x features).
%   trainLabels     - Cell array of labels (patient IDs) for the training set.
%   testFeatures    - Matrix of normalized feature vectors for testing.
%   testLabels      - Cell array of labels for the test set.
%

function [featuresVector, labels] = prepare_ECG_kNN(patients_struct, targetLength)
    allFeatures = [];
    allLabels = [];
    
    for p = 1:length(patients_struct)
        %% Fix RR interval length
        rawRR = patients_struct(p).features.RR_intervals(:)';
        L = length(rawRR);
        if L > targetLength
            fixedRR = rawRR(1:targetLength);
        elseif L < targetLength
            padding = repmat(rawRR(end), 1, targetLength - L);
            fixedRR = [rawRR, padding];
        else
            fixedRR = rawRR;
        end

        dct = patients_struct(p).features.AC_DCT_coef(:)';
        dwt = patients_struct(p).features.DWT_feature(:)';

        %% Normalization Min-Max [0, 1]
        fixedRR = (fixedRR - min(fixedRR)) / (max(fixedRR) - min(fixedRR) + eps);
        dct = (dct - min(dct)) / (max(dct) - min(dct) + eps);
        dwt = (dwt - min(dwt)) / (max(dwt) - min(dwt) + eps);

        %% Standardization 
        fixedRR = normalize(fixedRR, 'zscore');
        dct = normalize(dct, 'zscore');
        dwt = normalize(dwt, 'zscore');
        
        %% Concatenate all features
        featureVector = [fixedRR, dct, dwt];
        
        allFeatures = [allFeatures; featureVector];
        allLabels = [allLabels; string(patients_struct(p).patientID)];
    end
    %% Split into training and test sets (100/20)
%     numPatients = size(allFeatures, 1);  
%     rng('shuffle');  % For reproducibility
%     idx = randperm(numPatients); 
%     
%     numTest = round(numPatients * testFraction); 
%     testIdx = idx(1:numTest);  
%     trainIdx = idx(numTest+1:end); 
%     
%     % Get all features from the 48 patients for training
        featuresVector = allFeatures;
        labels = allLabels;
        
%     % Get only a subset for testing 
%     testFeatures = allFeatures(testIdx, :);
%     testLabels = allLabels(testIdx);
end
