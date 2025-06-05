% process_ECG processes raw ECG data to extract fiducial features after filtering and normalization.
%
% This function normalizes the input ECG signal, removes DC offset,
% applies comprehensive filtering to eliminate powerline interference, baseline wander, and other noise,
% and finally extracts heartbeat features using beat segmentation.
% It also evaluates the signal-to-noise ratio (SNR) improvement after filtering.
% Optional plots visualize the signal at different processing stages and frequency domain information.
%
% Parameters:
%   raw_ecg   - Raw ECG signal vector.
%   numBeats  - Number of beats to segment and analyze.
%   subjectID - Identifier for the subject (used in messages).
%   fs        - Sampling frequency in Hz.
%   gr        - Boolean flag to enable graphical plots (1 = plot, 0 = no plot).
%
% Returns:
%   pqrst_features_struct - Struct containing extracted ECG fiducial features per beat.
%   ecg_filtered         - Filtered ECG signal after denoising.
%   snr_imp              - Signal-to-noise ratio improvement metrics after filtering.
%

function [pqrst_features_struct, ecg_filtered, snr_imp] = process_ECG(raw_ecg, numBeats, subjectID, fs, gr)
    utils = ECGutils;
    global mit ptb;
    %% Normalization + DC Ofssset removal
    if mit
        mu = mean(raw_ecg);
        sigma = std(raw_ecg);
        raw_ecg_norm = (raw_ecg - mu)/sigma;
    end
    if ptb % Better results are yield w/ min-max norm
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
    [ecg_filtered, ecg_noPLI, ecg_noBLW] = ECG_Complete_Filtering(raw_ecg_norm, fs, 0);

    % Denoising performance metrics
    snr_imp = utils.evaluateFiltering(raw_ecg_norm, ecg_filtered, fs);
    if gr
        t = (0:length(ecg_filtered)-1) / fs;    
        utils.plotTimeDomain(t, ecg_filtered, "ECG Common Fiducial Features", 'b');
        xlim([0 1.5]);
%         varNames = {'SNR_PLI_Imp', 'SNR_BLW_Imp', 'SNR_HF_Imp'};
%         rowNames = {subjectID};
%         T = array2table(snr_imp, 'VariableNames', varNames, 'RowNames', rowNames);
%         disp('SNR Improvement Table:');
%         disp(T);
    
        utils.plotComparison(t, raw_ecg, ecg_filtered, 'Raw ECG', 'Filtered ECG');

        % Subplot filtering framework
        duration = 4; % seconds
        N = round(duration * fs); 
        t = (0:length(raw_ecg)-1)/fs;        
        raw_ecg_seg       = raw_ecg(1:N);
        raw_ecg_norm_seg  = raw_ecg_norm(1:N);
        ecg_noPLI_seg     = ecg_noPLI(1:N);
        ecg_noBLW_seg     = ecg_noBLW(1:N);
        ecg_filtered_seg  = ecg_filtered(1:N);
        t_seg             = t(1:N);
        
        figure('Name','ECG Signal Processing Pipeline','Color','w');
        
        subplot(5,1,1);
        plot(t_seg, raw_ecg_seg, 'b');
        title('(a) Raw ECG');
        ylabel('Amplitude');
        grid on;
        
        subplot(5,1,2);
        plot(t_seg, raw_ecg_norm_seg, 'b');
        title('(b) Normalized ECG');
        ylabel('Amplitude');
        grid on;
        
        subplot(5,1,3);
        plot(t_seg, ecg_noPLI_seg, 'b');
        title('(c) ECG without Power Line Interference');
        ylabel('Amplitude');
        grid on;
        
        subplot(5,1,4);
        plot(t_seg, ecg_noBLW_seg, 'b');
        title('(d) ECG without Baseline Wander');
        ylabel('Amplitude');
        grid on;
        
        subplot(5,1,5);
        plot(t_seg, ecg_filtered_seg, 'b');
        title('(e) Clean ECG ');
        xlabel('Time (s)');
        ylabel('Amplitude');
        grid on;
    end

    %% Feature Extraction (RR interval + AC/DCT + Wavelet Transform)
    %pqrst_features_struct = PQRST_Feature_Extraction(ecg_filtered, subjectID, fs, gr);
    %pqrst_features_struct = Interval_Feature_Extraction(ecg_filtered, subjectID, fs, gr);
    pqrst_features_struct = Beats_Feature_Extraction(ecg_filtered, numBeats, subjectID, fs, gr);
    fprintf("Individual %s processed successfully.\n", subjectID);
end