% ECG_Feature_Extraction extracts time-domain and frequency-domain features from an ECG signal.
%
% This function combines multiple techniques for ECG feature extraction, including 
% RR interval analysis using the Pan-Tompkins algorithm, autocorrelation with DCT-based 
% dimensionality reduction (AC/DCT), and Discrete Wavelet Transform (DWT). These features 
% are returned in a structured format for further analysis or classification.
%
% Parameters:
%   ecg_filtered - The preprocessed (filtered) ECG signal (vector).
%   fs - Sampling frequency of the ECG signal in Hz.
%   gr - Boolean flag to generate plots (1 = plot, 0 = no plot).
%
% Returns:
%   patient_ecg_features - A structure containing extracted ECG features with the fields:
%       .RR_intervals - Vector of RR intervals (in seconds) computed from R-peaks.
%       .AC_DCT_coef - Feature vector from autocorrelation and DCT method.
%       .DWT_features - Feature vector from the Discrete Wavelet Transform.
%
function [patient_ecg_features] = ECG_Feature_Extraction(ecg_filtered, fs, gr)
    utils = ECGutils;
    %% RR interval --> Pan-tompkins
    [~, qrs_i_raw, ~] = ECG_Pan_Tompkins(ecg_filtered, fs, gr);
    t = (0:length(ecg_filtered)-1) / fs;
    RR_intervals = diff(t(qrs_i_raw));
   
    if gr
        utils.plotTimeDomain(t, ecg_filtered, 'R Peak Detection', 'b');
        xlim([0 2]);
        hold on;
        plot(t(qrs_i_raw), ecg_filtered(qrs_i_raw), 'ro', 'MarkerFaceColor', 'r');
        grid on;

        figure;
        plot(t, ecg_filtered, 'b', 'LineWidth', 1.2); 
        hold on;
        plot(t(qrs_i_raw), ecg_filtered(qrs_i_raw), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
                
        % Loop through consecutive R-peaks to draw connecting lines and annotate RR intervals
        for i = 1:length(RR_intervals)
            % Coordinates of current and next R-peak
            x1 = t(qrs_i_raw(i));
            y1 = ecg_filtered(qrs_i_raw(i));
            x2 = t(qrs_i_raw(i+1));
            y2 = ecg_filtered(qrs_i_raw(i+1));
            
            % Draw a line connecting the two R-peaks
            plot([x1, x2], [y1, y2], 'k-', 'LineWidth', 1.5);
            
            % Compute the midpoint for annotation
            mid_x = (x1 + x2) / 2;
            mid_y = (y1 + y2) / 2;
            
            % Display the RR interval at the midpoint (formatted to 3 decimals)
            text(mid_x, mid_y, sprintf('RR: %.3f s', RR_intervals(i)), ...
                 'Color', 'k', 'FontSize', 10, 'FontWeight', 'bold', ...
                 'BackgroundColor', 'w', 'EdgeColor', 'k', 'Margin', 2);
        end
        title('ECG Signal with R-Peak Detection and RR Intervals','FontSize',12,'FontWeight','bold');
        xlabel('Time (s)','FontSize',12);
        ylabel('Amplitude (mV)','FontSize',12);
        xlim([0 2]);
        grid on;
        hold off;
    end
    
    %% Autocorrelation + Dimension Reduction (AC/DCT)
    L = 60; % Number of AC coeficientes ideal for MIT-BIH dataset
    K = 38; % Upper fc bandpass filter
    [AC_DCT_coef, ~, ~] = ECG_AC_DCT(ecg_filtered, L, K, fs, gr); 
    
    %% Discrete Wavelet Transform (DWT)
    wavelet_name = 'db3';
    decomposition_level = 5; 
    [DWT_feature] = ECG_DWT(ecg_filtered, wavelet_name, decomposition_level, gr);
  
    %% Add patient's features to its structure
    patient_ecg_features = struct();

    patient_ecg_features.RR_intervals = RR_intervals; 

    patient_ecg_features.AC_DCT_coef = AC_DCT_coef;

    patient_ecg_features.DWT_feature = DWT_feature;

end
