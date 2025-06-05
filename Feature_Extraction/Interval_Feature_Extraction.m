% PQRST_Feature_Extraction extracts features from each PQRST complex in a filtered ECG signal.
%
% This function segments the ECG signal into 5-seconds windows and computes various features for each 
% window. These include the RR interval,
% autocorrelation-DCT coefficients, and discrete wavelet transform (DWT) features.
% The features for each beat are stored in a structure array for further analysis or classification.
%
% Parameters:
%   ecg_filtered - The filtered ECG signal (vector).
%   subjectID    - String or character array identifying the subject or recording.
%   fs           - Sampling frequency of the ECG signal in Hz.
%   gr           - Boolean flag to enable plotting (1 = plot, 0 = no plot).
%
% Returns:
%   interval_features_struct - A structure array where each element corresponds to one heartbeat and contains:
%       - subjectID        : ID of the subject
%       - RR_intervals     : RR interval preceding the beat (in seconds)
%       - AC_DCT_coef      : Feature vector from autocorrelation followed by DCT
%       - DWT_features     : Feature vector from Discrete Wavelet Transform (DWT)

function [interval_features_struct] = Interval_Feature_Extraction(ecg_filtered, subjectID, fs, gr)
    utils = ECGutils;
    global mit ptb;
    %% RR interval --> Pan-tompkins
    [~, qrs_i_raw, ~] = ECG_RR_interval(ecg_filtered, fs, gr);
    t = (0:length(ecg_filtered)-1) / fs;
    RR_intervals = diff(t(qrs_i_raw));
    RR_times = t(qrs_i_raw(1:end-1));

    %% ECG segmentation into windows
    window_duration = 10; % In seconds
    window_samples = fs * window_duration;
    num_windows = floor(length(ecg_filtered) / window_samples);

    interval_features_struct = struct();
    for i = 1:num_windows
        % Extract current window
        start_idx = (i-1)*window_samples + 1;
        end_idx = i * window_samples;
        window_signal = ecg_filtered(start_idx:end_idx);
        window_time = t(start_idx:end_idx);
        
        rr_in_window = RR_intervals(RR_times >= window_time(1) & RR_times < window_time(end));
        if ~isempty(rr_in_window)
            rr_avg = mean(rr_in_window);
        else
            rr_avg = 0;  % If no RR found in the window
        end

        %% Autocorrelation + Dimension Reduction (AC/DCT)
        if mit            
            L = 60; % Number of AC coeficientes ideal for MIT-BIH dataset
            K = 38; % Upper fc bandpass filter
        elseif ptb
            L = 240; % Number of AC coeficientes ideal for PTB dataset
            K = 20; % Yielded the best results
        end
        [AC_DCT_coef] = PQRST_AC_DCT(window_signal, L, K, fs, gr); 
        AC_DCT_coef = AC_DCT_coef(:); 

        %% Discrete Wavelet Transform (DWT)
        wavelet_name = 'db3';
        decomposition_level = 5; 
        [DWT_feature] = PQRST_DWT(window_signal, wavelet_name, decomposition_level, fs, gr);
      
        DWT_feature = DWT_feature(:);

        %% Add segment's features to its structure
        interval_features_struct(i).subjectID = subjectID;
        interval_features_struct(i).RR_intervals = RR_intervals(i);
        interval_features_struct(i).AC_DCT_coef = AC_DCT_coef;
        interval_features_struct(i).DWT_features = DWT_feature;

        %utils.plotTimeDomain(window_time, window_signal, 'Window 5 seconds', 'b');
    end

    %%
        if gr
            utils.plotTimeDomain(t, ecg_filtered, 'R Peak Detection', 'b');
            hold on;
            plot(t(qrs_i_raw), ecg_filtered(qrs_i_raw), 'ro', 'MarkerFaceColor', 'r');
            grid on;
            f = figure; 
            f.Position = [100, 200, 650,210];
            plot(t, ecg_filtered, 'b'); 
            hold on;
            plot(t(qrs_i_raw), ecg_filtered(qrs_i_raw), 'ro', 'MarkerSize', 2, 'MarkerFaceColor', 'r');
                    
            % Loop through consecutive R-peaks to draw connecting lines and annotate RR intervals
            for i = 1:length(RR_intervals)
                % Coordinates of current and next R-peak
                x1 = t(qrs_i_raw(i));
                y1 = ecg_filtered(qrs_i_raw(i));
                x2 = t(qrs_i_raw(i+1));
                y2 = ecg_filtered(qrs_i_raw(i+1));
                
                % Draw a line connecting the two R-peaks
                plot([x1, x2], [y1, y2], 'k-', 'LineWidth', 0.5);
                
                % Compute the midpoint for annotation
                mid_x = (x1 + x2) / 2;
                mid_y = (y1 + y2) / 2;
                
                % Display the RR interval at the midpoint (formatted to 3 decimals)
                text(mid_x, mid_y, sprintf('RR: %.3f s', RR_intervals(i)), ...
                     'Color', 'k', 'FontSize', 10, 'FontWeight', 'bold', ...
                     'BackgroundColor', 'w', 'EdgeColor', 'k', 'Margin', 2);
            end
            %title('ECG Signal with R-Peak Detection and RR Intervals', 'FontWeight','bold');
            xlabel('Time (s)');
            ylabel('Amplitude (mV)');
            xlim([0 2.5]);
            grid on;
            hold off;
    end
end