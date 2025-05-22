






function [performance_struct] = ECG_Identification(ecg_segmented_storage, gr)
    utils = ECGutils;
    global ptb mit;
    %% Prepare the dataset
    [allFeatures, allLabels] = prepare_matrix_kNN(ecg_segmented_storage);
    %allLabels = categorical(allLabels);
    all_true_labels = [];
    all_predicted_labels = [];

%     [trainFeatures, trainLabels] = prepare_ECG_kNN(patients_struct_train_kNN);
%     [testFeatures, testLabels] = prepare_ECG_kNN(patients_struct_test_kNN);
% 
%     trainLabels = categorical(trainLabels);
%     testLabels = categorical(testLabels);
    %% k-NN classifier model
    k = 1;
    numFolds = 10; % 10-Fold cross-validation
    accuracies = zeros(numFolds, 1);
    precisions = zeros(numFolds, 1);
    recalls = zeros(numFolds, 1);

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

        % Confusion Matrix
        cm = confusionmat(testLabels, predictedLabels);
        TP = diag(cm);
        FP = sum(cm,1)' - TP;
        FN = sum(cm,2) - TP;

        % Precision and Recall (Macro average across classes)
        precision = mean(TP ./ (TP + FP + eps));
        recall = mean(TP ./ (TP + FN + eps));  

        precisions(fold) = precision;
        recalls(fold) = recall;

        all_true_labels = [all_true_labels; testLabels];
        all_predicted_labels = [all_predicted_labels; predictedLabels];
    end
    
            
    %% Random Forest TARDA MUCHO PARA PTB SOS

%     numTrees = 100; 
%     template = templateTree('MaxNumSplits', 20);
%     rfModel = fitcensemble(allFeatures, allLabels, ...
%         'Method', 'Bag', ...
%         'NumLearningCycles', numTrees, ...
%         'Learners', template);
%     
%     % Cross-validation
%     cvModel = crossval(rfModel, 'KFold', 10);
%     accuracy = 1 - kfoldLoss(cvModel);
    %fprintf('Precisión promedio con Random Forest: %.2f%%\n', accuracy * 100);
        
    
    
    %%
    % knnModel = fitcknn(trainFeatures, trainLabels, 'NumNeighbors', k);

    %% Predict
%     predictedLabels = predict(knnModel, testFeatures);
%     predictedLabels = categorical(predictedLabels);

    %% Confusion Matrix
    testLabels = categorical(testLabels);
    predictedLabels = categorical(predictedLabels);
    global_cm = confusionmat(testLabels, predictedLabels);
    figure;
    confusionchart(global_cm);
    title('Global Confusion Matrix (10-Fold CV)');
    xlabel('Predicted Class');
    ylabel('True Class');
    
    performance_struct.mean_accuracy = mean(accuracies);
    performance_struct.std_accuracy = std(accuracies);
    
    performance_struct.mean_precision = mean(precisions);
    performance_struct.std_precision = std(precisions);

    performance_struct.mean_sensitivity = mean(recalls);
    performance_struct.std_sensitivity = std(recalls);

    fprintf('\n--- 10-Fold Cross-Validation Performance ---\n');
    fprintf('Accuracy: %.2f ± %.2f %%\n', performance_struct.mean_accuracy*100, performance_struct.std_accuracy*100);
    fprintf('Precision: %.2f ± %.2f %%\n', performance_struct.mean_precision*100, performance_struct.std_precision*100);
    fprintf('Sensitivity: %.2f ± %.2f %%\n', performance_struct.mean_sensitivity*100, performance_struct.std_sensitivity*100);
end