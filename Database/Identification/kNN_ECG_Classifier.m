% kNN- ECG-based biometric identification using K-Nearest Neighbours.
%
% Syntax:
%   predictedLabels = kNN_ECG_Classifier(trainFeatures, trainLabels, testFeatures, k)
%
% Inputs:
%   trainFeatures - [N x M] matrix of training samples (N subjects, M features each)
%   trainLabels   - [N x 1] vector of class labels for training samples
%   testFeatures  - [P x M] matrix of test samples
%   k             - Number of nearest neighbours to consider
%
% Output:
%   predictedLabels - [P x 1] vector of predicted labels for test samples
%
% Notes:
%   - Euclidean distance is used for neighbour comparison.
%   - If k > 1, majority voting is applied.
%   - For biometric identification tasks, literature often suggests k = 1.



function predictedLabels = kNN_ECG_Classifier(trainFeatures, trainLabels, testFeatures, k)
    if nargin < 4
        k = 1; % default to 1-NN if not specified
    end

    numTests = size(testFeatures, 1);
    predictedLabels = zeros(numTests, 1);

    for i = 1:numTests
        % Compute distances between test sample i and all training samples
        distances = sqrt(sum((trainFeatures - testFeatures(i, :)).^2, 2));

        % Find the indices of the k nearest neighbours
        [~, sortedIndices] = sort(distances);
        nearestLabels = trainLabels(sortedIndices(1:k));

        % Assign label based on majority voting
        predictedLabels(i) = mode(nearestLabels);
    end
end