






function [performance_struct] = ECG_Identification(ecg_segmented_storage, gr)
    utils = ECGutils;
    global ptb mit;
    %% Prepare the dataset
    [allFeatures, allLabels] = prepare_matrix_kNN(ecg_segmented_storage);
    allLabels = categorical(allLabels);
%     [trainFeatures, trainLabels] = prepare_ECG_kNN(patients_struct_train_kNN);
%     [testFeatures, testLabels] = prepare_ECG_kNN(patients_struct_test_kNN);
% 
%     trainLabels = categorical(trainLabels);
%     testLabels = categorical(testLabels);
    %% k-NN classifier model
    k = 1;
    numFolds = 10; % 10-Fold cross-validation
    accuracies = zeros(numFolds, 1);

    %% Cross-validation
    cv = cvpartition(allLabels, 'KFold', numFolds);
    for fold = 1:numFolds
        trainIdx = cv.training(fold); 
        testIdx = cv.test(fold);      
        
        trainFeatures = allFeatures(trainIdx, :);
        trainLabels = allLabels(trainIdx);  
        testFeatures = allFeatures(testIdx, :);  
        testLabels = allLabels(testIdx);      
        
        knnModel = fitcknn(trainFeatures, trainLabels, 'NumNeighbors', k);
        predictedLabels = predict(knnModel, testFeatures);
        predictedLabels = categorical(predictedLabels);
        
        accuracies(fold) = sum(predictedLabels == testLabels) / length(testLabels);
    end
    
    mean_accuracy = mean(accuracies);
    std_accuracy = std(accuracies);
    fprintf('Average accuracy of KNN with k=%d: %.4f\n', k, mean_accuracy);
    fprintf('Global accuracy of KNN with k=%d: %.2f%%\n', k, mean_accuracy*100);
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
    
    if 1
        figure;
        confusionchart(testLabels, predictedLabels);
        title('Confusion Matrix for kNN');
        xlabel('Predicted');ylabel('True');
    end
end