% process_ECG processes a raw ECG signal by normalizing, filtering, and extracting features.
%
% This function first normalizes the raw ECG signal depending on the dataset type (MIT-BIH or PTB),
% then applies a complete filtering pipeline to remove artifacts such as baseline wander, 
% powerline interference, and high-frequency noise. After filtering, it evaluates the improvement 
% in signal quality and extracts features from each heartbeat using the PQRST complex.
%
% Parameters:
%   raw_ecg   - Raw ECG signal (vector).
%   subjectID - String identifying the subject or recording.
%   fs        - Sampling frequency of the ECG signal in Hz.
%   gr        - Boolean flag to enable plotting (1 = plot, 0 = no plot).
%
% Returns:
%   pqrst_features_struct - A structure array of features for each heartbeat, with fields:
%       - subjectID        : ID of the subject
%       - RR_intervals     : RR interval (in seconds)
%       - AC_DCT_coef      : Autocorrelation-DCT features
%       - DWT_features     : Discrete Wavelet Transform features
%
%   snr_imp               - A vector with SNR improvement metrics after filtering, in the order:
%       [SNR_PLI_Imp, SNR_BLW_Imp, SNR_HF_Imp]

function [pqrst_features_struct, snr_imp] = process_ECG(raw_ecg, subjectID, fs, gr)
    utils = ECGutils;
    global mit ptb;
    %% Normalization + DC Ofssset removal
    if mit
        mu = mean(raw_ecg);
        sigma = std(raw_ecg);
        raw_ecg_norm = (raw_ecg - mu)/sigma;
    end
    if ptb % Better results are yield
        raw_ecg_norm = (raw_ecg - min(raw_ecg)) / (max(raw_ecg) - min(raw_ecg)); % Amplitude within [0,1]
        raw_ecg_norm = raw_ecg_norm - mean(raw_ecg_norm); % Centralize towards 0 and remove f=0 in FFT
    end
    if gr
        t = (0:length(raw_ecg_norm)-1) / fs;    
        utils.plotComparison(t, raw_ecg, raw_ecg_norm, 'Raw ECG', 'Normalized ECG');
        % FFT
        [f, module_noPLI, phase_noPLI] = utils.computeFFT(raw_ecg_norm, fs);
        figure;
        subplot(2,1,1);
        utils.plotFrequencyDomain(f, module_noPLI, 'Magnitude of the FFT (Before filtering)', 'b');
        subplot(2,1,2);
        utils.plotFrequencyDomain(f, phase_noPLI, 'Phase of the FFT (Before filtering)', 'b');
    end  
    %% Filtering Process (Denoising ECG: Powerline Interference + Baseline Wander + Other artifacts)
    ecg_filtered = ECG_Complete_Filtering(raw_ecg_norm, fs, gr);

    % Denoising performance metrics
    snr_imp = utils.evaluateFiltering(raw_ecg_norm, ecg_filtered, fs);
    if gr
        t = (0:length(ecg_filtered)-1) / fs;    
        utils.plotTimeDomain(t, ecg_filtered, "ECG Common Fiducial Features", 'b');
        xlim([0 1.5]);
        varNames = {'SNR_PLI_Imp', 'SNR_BLW_Imp', 'SNR_HF_Imp'};
        rowNames = {subjectID};
        T = array2table(snr_imp, 'VariableNames', varNames, 'RowNames', rowNames);
        disp('SNR Improvement Table:');
        disp(T);
    
        utils.plotComparison(t, raw_ecg, ecg_filtered, 'Normalized ECG', 'Filtered ECG');
        Plot comparison between raw and filtered ECG
            utils.plotComparison(t, raw_ecg, ecg_filtered, ...
                           ['Raw ECG - ' subjectID], ...
                           ['Filtered ECG - ' subjectID]);
    end

    %% Feature Extraction (RR interval + AC/DCT + Wavelet Transform)
    pqrst_features_struct = PQRST_Feature_Extraction(ecg_filtered, subjectID, fs, gr);

    fprintf("Individual %s processed successfully.\n", subjectID);
end