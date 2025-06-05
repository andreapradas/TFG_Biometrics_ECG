% ECG_DWT performs Discrete Wavelet Transform (DWT) on an ECG signal to extract 
% approximation and detail coefficients as features.
%
% This function decomposes the input ECG signal into a specified number of levels 
% using a chosen wavelet. The approximation coefficients at the final level 
% are returned as the feature vector. Optionally, it can also plot the coefficients.
%
% Parameters:
%   ecg_signal - The input ECG signal (vector).
%   wavelet_name - Name of the wavelet (e.g., 'db3', 'sym4', etc.).
%   decomposition_level- Number of decomposition levels for the wavelet transform.
%   gr - Boolean flag to generate plots (1 = plot, 0 = no plot).
%
% Returns:
%   DWT_feature - Feature vector composed of the approximation coefficients 
%                 at the last decomposition level.

function [DWT_feature] = ECG_DWT(ecg_signal, wavelet_name, decomposition_level, fs, gr)
    %% Perform the Discrete Wavelet Transform (DWT) decomposition
    [C, L] = wavedec(ecg_filtered_subject, decomposition_level, wavelet_name);

    % Extract approximation coefficients (A)
    approx_coeffs = appcoef(C, L, wavelet_name, decomposition_level);
    approx_coeffs = approx_coeffs(:);

    DWT_feature = approx_coeffs;
    
    % Extract detail coefficients (D1 to Dn)
    detail_coeffs = cell(1, decomposition_level);
    for i = 1:decomposition_level
        detail_coeffs{i} = detcoef(C, L, i);
        detail_coeffs{i} = detail_coeffs{i}(:);
    end
    if gr
        f = figure;
        f.Position = [100, 100, 700, 800];
        subplot(decomposition_level+1, 1, 1);
        plot(approx_coeffs, 'b'); 
        title('Approximation Coefficients (A)', 'FontSize', 12, 'FontWeight', 'bold');
        xlabel('Samples');
        ylabel('Amplitude');
        grid on;
        for i = 1:decomposition_level
            subplot(decomposition_level+1, 1, i+1);
            plot(detail_coeffs{i}, 'b'); 
            title(['Detail Coefficients D' num2str(i)], 'FontSize', 12, 'FontWeight', 'bold');
            xlabel('Samples');
            ylabel('Amplitude');
            grid on;
        end
        %% Detect PQRST complex
        FPT = [];
        beat_index = 1;
        FPT = QRS_Detection(ecg_filtered_subject, fs); 
        FPT = P_Detection(ecg_filtered_subject, fs, FPT); 
        FPT = T_Detection(ecg_filtered_subject, fs, FPT);
        startP = FPT(beat_index,1); 
        endT = FPT(beat_index,12);

        pqrst_segment = ecg_filtered_subject(startP:endT);
        [C, L] = wavedec(pqrst_segment, decomposition_level, wavelet_name);
        approx_coeffs = appcoef(C, L, wavelet_name, decomposition_level);
        approx_coeffs = approx_coeffs(:);
    
        f = figure;
        f.Position = [100, 100, 500, 400];
        subplot(2, 1, 1);
        plot(pqrst_segment, 'b', 'LineWidth', 1);
        title('P-QRS-T Complex', 'FontSize', 12, 'FontWeight', 'bold');
        xlabel('Time (samples)', 'FontSize', 12);
        ylabel('Amplitude', 'FontSize', 12);
        grid on;
        box off;
        
        % ---- DECOMPOSED WAVELET COEFFICIENTS ----
        subplot(2, 1, 2);
        hold on;
        
        % Initialize X-axis for the first signal (A5)
        x_values = 1:length(approx_coeffs);
        y_values = {approx_coeffs(:)'}; 
        labels = {'A5'};
        
        % Collect all detail coefficients (D5 to D1)
        for i = 1:decomposition_level
            detail = detail_coeffs{decomposition_level - i + 1}(:)';  
            y_values{end + 1} = detail;
            labels{end + 1} = ['D' num2str(decomposition_level - i + 1)];
        end
        
        % Adjust X-axis to ensure continuous signal (NO GAPS)
        x_offset = 1; % Start from 1
        for i = 1:length(y_values)
            x_range = x_offset:x_offset + length(y_values{i}) - 1;
            
            % Plot wavelet coefficients
            plot(x_range, y_values{i}, 'LineWidth', 1.2);
            
            % Update X-offset to ensure continuity
            x_offset = x_range(end);  
        end
        
        % Add labels aligned below the X-axis
        y_min = min(cellfun(@min, y_values)) - 0.1 * abs(min(cellfun(@min, y_values)));
        title('Decomposed Wavelet Coefficients of PQRST Complex', 'FontSize', 12, 'FontWeight', 'bold');
        xlabel('Time (samples)', 'FontSize', 12);
        ylabel('Amplitude', 'FontSize', 12);
        grid on;
        hold off;
    end
end