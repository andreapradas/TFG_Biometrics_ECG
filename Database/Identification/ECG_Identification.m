






function [performance_struct] = ECG_Identification(patients_struct_train, patients_struct_test, gr)
    utils = ECGutils;
    targetLength = 1000; % RR interval restricted length
    % testFraction = 0.8; % Test proportion

    %% Prepare the dataset
    [trainFeatures, trainLabels] = prepare_ECG_kNN(patients_struct_train, targetLength);
    [testFeatures, testLabels] = prepare_ECG_kNN(patients_struct_test, targetLength);

    trainLabels = categorical(trainLabels);
    testLabels = categorical(testLabels);
    %% k-NN classifier model
    k = 1;
    knnModel = fitcknn(trainFeatures, trainLabels, 'NumNeighbors', k);

    %% Predict
    predictedLabels = predict(knnModel, testFeatures);
    predictedLabels = categorical(predictedLabels);

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