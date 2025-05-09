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
%
% Returns:
%   trainFeatures   - Matrix of normalized feature vectors for training (patients x features).
%   trainLabels     - Cell array of labels (patient IDs) for the training set.
%   testFeatures    - Matrix of normalized feature vectors for testing.
%   testLabels      - Cell array of labels for the test set.
%

function [featuresVector, labels] = prepare_data_kNN(patients_struct)
    allFeatures = [];
    allLabels = [];
    RR_all = [];
    DCT_all = [];
    DWT_all = [];
    for p = 1:length(patients_struct)
        %% Fix vectors
        dct = patients_struct(p).features.AC_DCT_coef(:)';
        dwt = patients_struct(p).features.DWT_features(:)';

        %dct = dct(1:684);
%         dct = dct(1:120);
%         dwt = dwt(1:1004);
        %% Normalization Min-Max [0, 1]
        %fixedRR = (fixedRR - min(fixedRR)) / (max(fixedRR) - min(fixedRR) + eps);
        dct = (dct - min(dct)) / (max(dct) - min(dct) + eps);
        dwt = (dwt - min(dwt)) / (max(dwt) - min(dwt) + eps);

         %% Standardization 
        %fixedRR = normalize(fixedRR, 'zscore');
        dct = normalize(dct, 'zscore');
        dwt = normalize(dwt, 'zscore');
        
        %% Concatenate all features
        %featureVector = [fixedRR, dct, dwt];
        
%         allFeatures = [allFeatures; featureVector];
%         allFeatures = [allFeatures; dct]; 
%         Colors = [Colors, repmat(p, 1, 50)];
%         dct = dct(1:50);
%         fixedRR = fixedRR(1:50);
%         dwt = dwt(1:50);
%         RR_all = [RR_all, fixedRR];
%         DCT_all = [DCT_all, dct];
%         DWT_all = [DWT_all, dwt];
%         featureVector1 = [fixedRR, dct];
%         featureVector2 = [dwt, dct];
%         featureVector3 = [dwt, fixedRR];
        allFeatures = [allFeatures; dct]; 
        allLabels = [allLabels; string(patients_struct(p).subjectID)];
    end
    featuresVector = allFeatures;
    labels = allLabels;
end
