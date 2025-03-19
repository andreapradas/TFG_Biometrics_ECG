%       Feature Extraction
% 
%       Features: RR intervals + Autocorrelation + Wavelet Transform
% 
%           
%       Input:
%       Output:
% %   gr - Boolean flag to generate plots (1 = plot, 0 = no plot).

% 
%
function [patient_ecg_features] = ECG_Feature_Extraction(ecg_filtered, fs, gr)
    utils = ECGutils;
    %% RR interval --> Pan-tompkins
    [~, qrs_i_raw, ~] = Pan_Tompkins(ecg_filtered, fs, gr);
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
    
    %% Autocorrelation + Dimension Reduction (DCT)
    [dct_coef, K, rxx_norm, Sxx, lags] = ECG_AC_DCT(ecg_filtered, 0.95, gr); 
    
    
    %% Discrete Wavelet Transform
    [wavelet_features] = ECG_DWT(ecg_filtered, 'db3', 5, gr);
  
    %% Add patient's features to its structure
    patient_ecg_features = struct();

    patient_ecg_features.RR_intervals = RR_intervals; 

    patient_ecg_features.dct_coef = dct_coef;

    patient_ecg_features.wavelet_features = wavelet_features;

end
