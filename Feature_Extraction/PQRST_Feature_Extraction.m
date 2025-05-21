% PQRST_Feature_Extraction extracts features from each PQRST complex in a filtered ECG signal.
%
% This function detects fiducial points (P, QRS, T) in the ECG signal, segments each heartbeat,
% and computes various features for each PQRST complex. These include the RR interval,
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
%   pqrst_features_struct - A structure array where each element corresponds to one heartbeat and contains:
%       - subjectID        : ID of the subject
%       - RR_intervals     : RR interval preceding the beat (in seconds)
%       - AC_DCT_coef      : Feature vector from autocorrelation followed by DCT
%       - DWT_features     : Feature vector from Discrete Wavelet Transform (DWT)

function [pqrst_features_struct] = PQRST_Feature_Extraction(ecg_filtered, subjectID, fs, gr)
    utils = ECGutils;
    global mit ptb;
    %% RR interval --> Pan-tompkins
    [~, qrs_i_raw, ~] = ECG_RR_interval(ecg_filtered, fs, gr);
    t = (0:length(ecg_filtered)-1) / fs;
    RR_intervals = diff(t(qrs_i_raw));

    %% ECG segmentation into PQRST segments
    FPT = []; % Table with Fiducial points
    %numBeats = length(qrs_i_raw)-1; % As the last beat NOT have RR_interval feature

    FPT = QRS_Detection(ecg_filtered, fs); 
    FPT = P_Detection(ecg_filtered, fs, FPT); 
    FPT = T_Detection(ecg_filtered, fs, FPT);
    % Prove that NO indexes exceed the signal legth


    numBeats = min(length(FPT),length(RR_intervals)); % As there are differently calculated, could be unmatched nº of beats detected
    ecg_segments = cell(numBeats, 1);
    pqrst_features_struct = struct();

    for i = 1:numBeats
        startP = FPT(i,1); 
        endT = FPT(i,12);
        if startP == 0
            startP =1; % To handle properly array indices problems
        end
        ecg_segments{i} = ecg_filtered(startP:endT); % Window selected --> PQRST complex

        %% Autocorrelation + Dimension Reduction (AC/DCT)
        if mit            
            L = 60; % Number of AC coeficientes ideal for MIT-BIH dataset
            K = 38; % Upper fc bandpass filter
        elseif ptb
            L = 240; % Number of AC coeficientes ideal for PTB dataset
            K = 20; % Yielded the best results
        end
        [AC_DCT_coef] = PQRST_AC_DCT(ecg_segments{i}, L, K, fs, gr); 
        
        AC_DCT_coef = AC_DCT_coef(:); 
        if length(AC_DCT_coef) > 20
            AC_DCT_coef = AC_DCT_coef(1:20); 
        elseif length(AC_DCT_coef) < 20
            AC_DCT_coef = [AC_DCT_coef; zeros(20 - length(AC_DCT_coef), 1)]; 
        end
            
        %% Discrete Wavelet Transform (DWT)
        wavelet_name = 'db3';
        decomposition_level = 5; 
        [DWT_feature] = PQRST_DWT(ecg_segments{i}, wavelet_name, decomposition_level, fs, gr);
      
        DWT_feature = DWT_feature(:);
        if length(DWT_feature) > 22
            DWT_feature = DWT_feature(1:22);
        elseif length(DWT_feature) < 22
            DWT_feature = [DWT_feature; zeros(22 - length(DWT_feature), 1)];
        end
        %% Add segment's features to its structure
        pqrst_features_struct(i).subjectID = subjectID;
        pqrst_features_struct(i).RR_intervals = RR_intervals(i);
        pqrst_features_struct(i).AC_DCT_coef = AC_DCT_coef;
        pqrst_features_struct(i).DWT_features = DWT_feature;
    end

    %%
        if gr
            f = figure; 
            f.Position = [100, 200, 650,210]; % To capture same length for visual consistency among figures
            utils.plotTimeDomain(t, ecg_filtered, 'R Peak Detection', 'b');
            hold on;
            plot(t(qrs_i_raw), ecg_filtered(qrs_i_raw), 'ro', 'MarkerFaceColor', 'r');
            grid on;
            figure;
            plot(t, ecg_filtered, 'b'); 
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
            title('ECG Signal with R-Peak Detection and RR Intervals', 'FontWeight','bold');
            xlabel('Time (s)');
            ylabel('Amplitude (mV)');
            grid on;
            hold off;
    end
end