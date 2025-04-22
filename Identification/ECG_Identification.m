






function [predictedLabel] = ECG_Identification(patients_struct, gr)
    utils = ECGutils;
    targetLength = 2000;
    testFraction = 0.2;

    %% Prepare the dataset
    [trainFeatures, trainLabels, testFeatures, testLabels] = prepare_ECG_dataset(patients_struct, targetLength, testFraction);

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
    
    if 1
        figure;
        confusionchart(testLabels, predictedLabels, 'RowSummary', 'row-normalized', 'ColumnSummary', 'column-normalized');
        title('Confusion Matrix for k-NN');
    end
    
end