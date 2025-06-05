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
%   selected_features - Cell or string array of features to include, e.g., ["RR", "AC/DCT", "DWT"].
%   train_fraction    - Fraction of data to use for training (0 to 1).
%
% Returns:
%   trainFeatures   - Matrix of normalized feature vectors for training (patients x features).
%   trainLabels     - Categorical array of labels (patient IDs) for the training set.
%   testFeatures    - Matrix of normalized feature vectors for testing.
%   testLabels      - Categorical array of labels for the test set.
%

function [featuresMatrix, labels] = prepare_matrix_kNN(ecg_segmented_storage, selected_features)
    N = length(ecg_segmented_storage);
    rr_len = length(ecg_segmented_storage(1).RR_intervals);
    dct_len = length(ecg_segmented_storage(1).AC_DCT_coef);
    dwt_len = length(ecg_segmented_storage(1).DWT_features);

    total_len = 0;
    if ismember("RR", selected_features)
        total_len = total_len + rr_len;
    end
    if ismember("AC/DCT", selected_features)
        total_len = total_len + dct_len;
    end
    if ismember("DWT", selected_features)
        total_len = total_len + dwt_len;
    end
    
    featuresMatrix = zeros(N, total_len);
    labels = strings(N, 1);
    for p = 1:N
        feature_vec = [];
        % RR
        if ismember("RR", selected_features)
            rr = ecg_segmented_storage(p).RR_intervals(:)';
            feature_vec = [feature_vec, rr];  % no normalizing a scalar
        end

        % DCT
        if ismember("AC/DCT", selected_features)
            dct = ecg_segmented_storage(p).AC_DCT_coef(:)';
            dct = (dct - min(dct)) / (max(dct) - min(dct) + eps);
            dct = normalize(dct, 'zscore');
            feature_vec = [feature_vec, dct];
        end

        % DWT
        if ismember("DWT", selected_features)
            dwt = ecg_segmented_storage(p).DWT_features(:)';
            dwt = (dwt - min(dwt)) / (max(dwt) - min(dwt) + eps);
            dwt = normalize(dwt, 'zscore');
            feature_vec = [feature_vec, dwt];
        end
        %% Fix vectors
%         rr = ecg_segmented_storage(p).RR_intervals(:)';
%         dct = ecg_segmented_storage(p).AC_DCT_coef(:)';
%         dwt = ecg_segmented_storage(p).DWT_features(:)';
% 
%         %% Normalization Min-Max [0, 1]
%         %rr = (rr - min(rr)) / (max(rr) - min(rr) + eps); % If it is scalar NOT necessary
%         dct = (dct - min(dct)) / (max(dct) - min(dct) + eps);
%         dwt = (dwt - min(dwt)) / (max(dwt) - min(dwt) + eps);
% 
%         %% Standardization 
%         %rr = normalize(rr, 'zscore'); % If it consists of a scalar
%         dct = normalize(dct, 'zscore');
%         dwt = normalize(dwt, 'zscore');
        
        %% Concatenate all features + labels
        featuresMatrix(p, :) = feature_vec;
        labels(p) = string(ecg_segmented_storage(p).subjectID);
    end
    labels = categorical(labels);
end
