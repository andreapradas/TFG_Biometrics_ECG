





function [trainFeatures, trainLabels, testFeatures, testLabels] = prepare_ECG_dataset(patients_struct, targetLength, testFraction)
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
        dwt = patients_struct(p).features.DWT_features(:)';

        %% Standardization 
        fixedRR = normalize(fixedRR, 'zscore');
        dct = normalize(dct, 'zscore');
        dwt = normalize(dwt, 'zscore');

        
        %% Normalization Min-Max [0, 1]
        fixedRR = (fixedRR - min(fixedRR)) / (max(fixedRR) - min(fixedRR) + eps);
        dct = (dct - min(dct)) / (max(dct) - min(dct) + eps);
        dwt = (dwt - min(dwt)) / (max(dwt) - min(dwt) + eps);
        
        %% Concatenate all features
        featureVector = [fixedRR, dct, dwt];
        
        allFeatures = [allFeatures; featureVector];
        allLabels = [allLabels; string(patients_struct(p).patientID)];
    end

    %% Split into training and test sets (100/20)
    numPatients = size(allFeatures, 1);  
    rng(1);  % For reproducibility
    idx = randperm(numPatients); 
    
    numTest = round(numPatients * testFraction); 
    testIdx = idx(1:numTest);  
    trainIdx = idx(numTest+1:end); 
    
    % Get all features from the 48 patients for training
    trainFeatures = allFeatures;
    trainLabels = allLabels;
    
    % Get only a subset for testing 
    testFeatures = allFeatures(testIdx, :);
    testLabels = allLabels(testIdx);
end
