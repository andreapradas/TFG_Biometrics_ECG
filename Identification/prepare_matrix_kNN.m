
function [featuresMatrix, labels] = prepare_matrix_kNN(ecg_segmented_storage)
    N = length(ecg_segmented_storage);
    rr_len = length(ecg_segmented_storage(1).RR_intervals);
    dct_len = length(ecg_segmented_storage(1).AC_DCT_coef);
    dwt_len = length(ecg_segmented_storage(1).DWT_features);
    
    featuresMatrix = zeros(N, rr_len + dct_len + dwt_len);
    labels = strings(N, 1);
    for p = 1:N
        %% Fix vectors
        rr = ecg_segmented_storage(p).RR_intervals(:)';
        dct = ecg_segmented_storage(p).AC_DCT_coef(:)';
        dwt = ecg_segmented_storage(p).DWT_features(:)';

        %% Normalization Min-Max [0, 1]
        % rr = (rr - min(rr)) / (max(rr) - min(rr) + eps); % If it is
        % scalar NOT necessary
        dct = (dct - min(dct)) / (max(dct) - min(dct) + eps);
        dwt = (dwt - min(dwt)) / (max(dwt) - min(dwt) + eps);

        %% Standardization 
        %rr = normalize(rr, 'zscore');
        dct = normalize(dct, 'zscore');
        dwt = normalize(dwt, 'zscore');
        
        %% Concatenate all features + labels
        featuresMatrix(p, :) = [rr, dct, dwt];
        labels(p) = string(ecg_segmented_storage(p).subjectID);
    end
    labels = categorical(labels);
end
