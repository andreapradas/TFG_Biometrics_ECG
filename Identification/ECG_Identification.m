% ECG_Identification performs heartbeat and human identification using k-NN classification.
%
% This function prepares ECG feature data, performs 10-fold cross-validation
% with a k-nearest neighbors (k=1) classifier, and evaluates performance metrics:
% accuracy, precision, sensitivity (recall), heartbeat identification rate, and human identification rate.
% Optional plots include sample distribution per class, ROC curves, and confusion matrices.
%
% Parameters:
%   ecg_segmented_features_storage - Struct or cell array containing extracted ECG features and labels.
%   gr                             - Boolean flag to enable plots (1 = plot, 0 = no plot).
%
% Returns:
%   performance_struct - Struct containing mean and standard deviation of accuracy, precision, sensitivity,
%                        as well as heartbeat and human identification rates.
%
function [performance_struct] = ECG_Identification(ecg_segmented_features_storage, gr)
    global mit ptb;
    %% Prepare the dataset
    if mit
        selected_features = ["AC/DCT", "DWT"];
    elseif ptb
        selected_features = ["AC/DCT"];
    end
    [allFeatures, allLabels] = prepare_matrix_kNN(ecg_segmented_features_storage, selected_features);
    all_true_labels = [];
    all_predicted_labels = [];

    %% k-NN classifier model
    k = 1;
    numFolds = 10; % 10-Fold cross-validation
    accuracies = zeros(numFolds, 1);
    precisions = zeros(numFolds, 1);
    recalls = zeros(numFolds, 1);

    if gr
        classCounts = countcats(categorical(allLabels));
        classNames = categories(categorical(allLabels));
        catLabels = categorical(classNames);
        catLabels = reordercats(catLabels, classNames);
        mu = mean(classCounts);
        sigma = std(classCounts);
        cv = sigma / mu;
        figure('Color','w');
        bar(catLabels, classCounts, 'FaceColor', [0.2 0.4 0.6], 'EdgeColor', 'k');
        set(gca, 'XTickLabel', classNames, ...
                 'XTickLabelRotation', 45, ...
                 'Box', 'off');
        ylabel('Number of Samples');
        xlabel('Class Label');
        title('Sample Distribution per Class');
        grid on;
    end
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
    
    %% AUC
    if gr
        AUCs = zeros(numClasses, 1);
        for c = 1:numClasses
            [~, ~, ~, AUC] = perfcurve(true_bin_matrix(:, c), scores_matrix(:, c), 1);
            AUCs(c) = AUC;
        end
        
        figure;
        hold on;
        colors = lines(numClasses);
        legendEntries = cell(numClasses, 1);
        
        for c = 1:numClasses
            [FPR, TPR, ~, AUC] = perfcurve(true_bin_matrix(:, c), scores_matrix(:, c), 1);
            plot(FPR, TPR, 'LineWidth', 1.5, 'Color', colors(c,:));
        end
        
        xlabel('False Positive Rate');
        ylabel('True Positive Rate');
        title('ROC Curve per Class (1-vs-All)');
        grid on;
        axis square;
    end
    %% Confusion Matrix
    all_true_labels = categorical(all_true_labels);
    all_predicted_labels = categorical(all_predicted_labels);
    global_cm = confusionmat(all_true_labels, all_predicted_labels);
    classNames = categories(testLabels);
    f = figure;
    f.Position = [100, 100, 700, 600];
    confChart = confusionchart(global_cm, classNames, ...
    'Normalization', 'row-normalized', ...
    'Title', 'Normalized Confusion Matrix (10-Fold CV)', ...
    'XLabel', 'Predicted Class', ...
    'YLabel', 'True Class');
    if ptb
        cm_normalized = global_cm ./ sum(global_cm, 2);
        imagesc(cm_normalized); 
        colormap('hot');
        colorbar;
        title('Confusion Matrix');
        xlabel('Predicted Class');
        ylabel('True Class');
        set(gca, 'XTick', [], 'YTick', []);
    end  
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

    %% HEARTBEAT IDENTIFICATION RATE
    % Accuracy per heartbeat = total correct heartbeat classifications / total heartbeats
    heartbeat_identification_rate = sum(all_true_labels == all_predicted_labels) / length(all_true_labels);
    fprintf('Heartbeat Identification Rate: %.2f %%\n', heartbeat_identification_rate*100);

    %% HUMAN IDENTIFICATION RATE
    % Aggregate predictions by human ID (class label)
    humans = categories(all_true_labels);
    numHumans = length(humans);
    correct_human_identifications = 0;

    for i = 1:numHumans
        human_label = humans{i};
        % Find indices of all samples belonging to this human
        idx = (all_true_labels == human_label);

        % Get predicted labels for those samples
        predicted_for_human = all_predicted_labels(idx);

        % Majority vote predicted human
        majority_pred = mode(predicted_for_human);

        % Check if majority predicted human matches true human label
        if majority_pred == human_label
            correct_human_identifications = correct_human_identifications + 1;
        end
    end

    human_identification_rate = correct_human_identifications / numHumans;
    fprintf('Human Identification Rate: %.2f %%\n', human_identification_rate*100);

    % Save rates in output struct
    performance_struct.heartbeat_id_rate = heartbeat_identification_rate;
    performance_struct.human_id_rate = human_identification_rate;
end