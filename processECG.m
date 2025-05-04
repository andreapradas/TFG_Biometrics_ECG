



function [patient_ecg_features, snr_imp] = processECG(raw_ecg, fs, patientID, gr)
    utils = ECGutils;
    %% Normalization + DC Ofssset removal
    raw_ecg_norm = (raw_ecg - min(raw_ecg)) / (max(raw_ecg) - min(raw_ecg));
    raw_ecg_norm = raw_ecg_norm - mean(raw_ecg_norm); % Centralize towards 0 and remove f=0 in FFT
    t = (0:length(raw_ecg_norm)-1) / fs;
    % utils.plotComparison(t, raw_ecg, raw_ecg_norm, 'Raw ECG', 'Normalized ECG');
    
    if gr
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
    utils.plotTimeDomain(t, ecg_filtered, "ECG Common Fiducial Features", 'b');
    xlim([0 1.5]);

    % Denoising performance metrics
    snr_imp = utils.evaluateFiltering(raw_ecg_norm, ecg_filtered, fs);
    if gr
        varNames = {'SNR_PLI_Imp', 'SNR_BLW_Imp', 'SNR_HF_Imp'};
        rowNames = {patientID};
        T = array2table(snr_imp, 'VariableNames', varNames, 'RowNames', rowNames);
        disp('SNR Improvement Table:');
        disp(T);
    end

    %utils.plotComparison(t, raw_ecg, ecg_filtered, 'Normalized ECG', 'Filtered ECG');
    % Plot comparison between raw and filtered ECG
    %     utils.plotComparison(t, raw_ecg, ecg_filtered, ...
    %                    ['Raw ECG - ' patientID], ...
    %                    ['Filtered ECG - ' patientID]);

    %% Feature Extraction (RR interval + AC/DCT + Wavelet Transform)
    patient_ecg_features = ECG_Feature_Extraction(ecg_filtered, fs, gr);
    fprintf("Individual %s processed successfully.\n", patientID);
end