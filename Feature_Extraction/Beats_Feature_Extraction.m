% Beats_Feature_Extraction extracts features from ECG beats within specified windows.
%
% This function detects QRS complexes, P and T waves in a filtered ECG signal,
% segments the signal into beat windows, and extracts features including RR intervals,
% autocorrelation + dimension reduction coefficients (AC/DCT), and discrete wavelet transform (DWT) features.
% It supports data from MIT-BIH (mit) and PTB databases with configurable parameters,
% and optionally plots the detected R peaks.
%
% Parameters:
%   ecg_filtered_subject - Filtered ECG signal for one subject (vector).
%   numBeats_win         - Number of beats to include per window for feature extraction (scalar).
%   subjectID            - Identifier for the subject (scalar or string).
%   fs                   - Sampling frequency in Hz (scalar).
%   gr                   - Boolean flag to enable plots (1 = plot, 0 = no plot).
%
% Returns:
%   interval_features_struct - Struct array with fields:
%                             .subjectID      - Subject identifier.
%                             .RR_intervals   - Mean RR interval for the window.
%                             .AC_DCT_coef    - Autocorrelation + DCT coefficients vector.
%                             .DWT_features   - Discrete Wavelet Transform features vector.
%

function [interval_features_struct] = Beats_Feature_Extraction(ecg_filtered_subject, numBeats_win, subjectID, fs, gr)
    utils = ECGutils;
    global mit ptb;
    %% RR interval --> Pan-tompkins
    [~, qrs_i_raw, ~] = ECG_RR_interval(ecg_filtered_subject, fs, gr);
    if isempty(qrs_i_raw)
        warning(['No QRS peaks detected for subject ', num2str(subjectID), '. Skipping...']);
        interval_features_struct = struct();
        return;
    end
    t = (0:length(ecg_filtered_subject)-1) / fs;
    RR_intervals = diff(t(qrs_i_raw));

    FPT = QRS_Detection(ecg_filtered_subject, fs); 
    FPT = P_Detection(ecg_filtered_subject, fs, FPT); 
    FPT = T_Detection(ecg_filtered_subject, fs, FPT);

    numBeats = min(length(FPT), length(RR_intervals)); % Make sure RR and FPT match
    ecg_segments = cell(numBeats, 1);
    interval_features_struct = struct();
    segment_count = 0;
    %[~, ~, ~] = ECG_AC_DCT(ecg_filtered, qrs_i_raw, 60, 38, 360, 1);
    %[DWT_feature] = ECG_DWT(ecg_filtered_subject, 'db3', 5, 1000, 1);

    %% Windowing feature extraction
    for i = 1:numBeats_win:(numBeats - numBeats_win + 1)
        startP = FPT(i,1); 
        endT = FPT(i + numBeats_win - 1, 12);
        if startP == 0
            startP = 1; % To handle properly array indices problems
        end
        if endT > length(ecg_filtered_subject)
            endT = length(ecg_filtered_subject);
        end
        ecg_segments{i} = ecg_filtered_subject(startP:endT);
        if ptb && length(ecg_segments{i}) < 240
            warning(['No well detected QRS, too short for computing AC/DCT ', num2str(subjectID), '. Skipping ECG segment...']);
            continue;
        end
        if numBeats_win == 1
            rr_feature = RR_intervals(i);
        else
            rr_intervals_segment = RR_intervals(i:i+numBeats_win-2);
            rr_feature = mean(rr_intervals_segment);
        end
        %% Autocorrelation + Dimension Reduction (AC/DCT)
        if mit            
            L = 60; 
            K = 38;
        elseif ptb
            L = 240; 
            K = 20;
        end
        [AC_DCT_coef] = PQRST_AC_DCT(ecg_segments{i}, L, K, fs, gr); 
        AC_DCT_coef = AC_DCT_coef(:);

        %% Discrete Wavelet Transform (DWT)
        wavelet_name = 'db3';
        decomposition_level = 1; 
        [DWT_feature] = PQRST_DWT(ecg_segments{i}, wavelet_name, decomposition_level, fs, gr);
        DWT_feature = DWT_feature(:);
        if length(DWT_feature) > 90 && mit
            DWT_feature = DWT_feature(1:90);
        elseif length(DWT_feature) < 90 && mit
            DWT_feature = [DWT_feature; zeros(90 - length(DWT_feature), 1)];
        end

        segment_count = segment_count + 1;
        interval_features_struct(segment_count).subjectID = subjectID;
        interval_features_struct(segment_count).RR_intervals = rr_feature;  
        interval_features_struct(segment_count).AC_DCT_coef = AC_DCT_coef;
        interval_features_struct(segment_count).DWT_features = DWT_feature;
    end

    if gr
        utils.plotTimeDomain(t, ecg_filtered_subject, 'R Peak Detection', 'b');
        hold on;
        plot(t(qrs_i_raw), ecg_filtered_subject(qrs_i_raw), 'ro', 'MarkerFaceColor', 'r');
        grid on;
        xlabel('Time (s)');
        ylabel('Amplitude (mV)');
        hold off;
    end
end