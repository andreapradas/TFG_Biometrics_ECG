






function [performance_struct] = ECG_Identification(ecg_segmented_storage, gr)
    utils = ECGutils;
    global ptb mit;

    %% Prepare TRAIN and TEST structure for PTB
    if ptb
        n = length(patients_struct_train);
        base_ids = strings(n,1);    
        [unique_ids, ~, idx] = unique(base_ids);
        counts = accumarray(idx, 1);
        keep_indices = ismember(base_ids, unique_ids(counts > 1));
        filtered_data = patients_struct_train(keep_indices); % Remove those patients with only 1 recording
    end

    %% Split into training and test sets (80/20)
%     rng(1);
%     shuffled_indices = randperm(length(filtered_data));
%     filtered_data = filtered_data(shuffled_indices);
%     split_point = round(0.8 * length(filtered_data));
%     patients_struct_train_kNN = filtered_data(1:split_point);
%     patients_struct_test_kNN  = filtered_data(split_point+1:end);

    %% Prepare the dataset
    [trainFeatures, trainLabels] = prepare_ECG_kNN(patients_struct_train_kNN);
    [testFeatures, testLabels] = prepare_ECG_kNN(patients_struct_test_kNN);

    trainLabels = categorical(trainLabels);
    testLabels = categorical(testLabels);
    %% k-NN classifier model
    k = 1;
    numFolds = 10; % 10-Fold cross-validation
    accuracies = zeros(numFolds, 1);

    %% Cross-validation
    cv = cvpartition(Y, 'KFold', numFolds);
    for fold = 1:numFolds
        trainIdx = cv.training(fold); 
        testIdx = cv.test(fold);      
        
        trainFeatures = X(trainIdx, :);
        trainLabels = Y(trainIdx);  
        testFeatures = X(testIdx, :);  
        testLabels = Y(testIdx);      
        
        knnModel = fitcknn(trainFeatures, trainLabels, 'NumNeighbors', k);
        predictedLabels = predict(knnModel, testFeatures);
        predictedLabels = categorical(predictedLabels);
        
        accuracies(fold) = sum(predictedLabels == testLabels) / length(testLabels);
    end
    
    mean_accuracy = mean(accuracies);
    std_accuracy = std(accuracies);
    fprintf('Average accuracy of KNN with k=%d: %.4f\n', k, mean_accuracy);
    fprintf('Standard deviation of accuracy: %.4f\n', std_accuracy);        

    %%
    % knnModel = fitcknn(trainFeatures, trainLabels, 'NumNeighbors', k);

    %% Predict
%     predictedLabels = predict(knnModel, testFeatures);
%     predictedLabels = categorical(predictedLabels);

    %% Confusion Matrix
    cm = confusionmat(testLabels, predictedLabels);
    totalCorrect = sum(diag(cm));
    totalSamples = sum(cm(:));
    accuracy = totalCorrect / totalSamples;
    fprintf('\n--- Performance Metrics ---\n');
    fprintf('Global Accuracy: %.2f%%\n', accuracy*100);
    
    if gr
        figure;
        confusionchart(testLabels, predictedLabels);
        title('Confusion Matrix for kNN');
        xlabel('Predicted');ylabel('True');
    end
end