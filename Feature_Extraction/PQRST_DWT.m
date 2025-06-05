% PQRST_DWT performs Discrete Wavelet Transform (DWT) on a single PQRST ECG segment.
%
% This function decomposes an individual ECG beat (PQRST complex) using the Discrete 
% Wavelet Transform (DWT) up to a specified level, extracting the approximation coefficients 
% at the final level as a compact feature vector. Optionally, it can plot the approximation 
% and detail coefficients along with the original segment.
%
% Parameters:
%   ecg_segment         - Vector containing a single PQRST segment of the ECG signal.
%   wavelet_name        - Name of the wavelet used for decomposition (e.g., 'db3').
%   decomposition_level - Number of levels to decompose the signal.
%   fs                  - Sampling frequency of the ECG signal in Hz.
%   gr                  - Boolean flag to generate plots (1 = plot, 0 = no plot).
%
% Returns:
%   DWT_feature         - Feature vector containing approximation coefficients 
%                         at the final decomposition level of the PQRST segment.

function [DWT_feature] = PQRST_DWT(ecg_segment, wavelet_name, decomposition_level, fs, gr)
    global mit ptb;
    %% Perform the Discrete Wavelet Transform (DWT) decomposition
    [C, L] = wavedec(ecg_segment, decomposition_level, wavelet_name);

    % Extract approximation coefficients (A)
    approx_coeffs = appcoef(C, L, wavelet_name, decomposition_level);
    approx_coeffs = approx_coeffs(:);
    % Extract detail coefficients (D1 to Dn)
    detail_coeffs = cell(1, decomposition_level);
    for i = 1:decomposition_level
        detail_coeffs{i} = detcoef(C, L, i);
        detail_coeffs{i} = detail_coeffs{i}(:);
    end
    if mit
        if decomposition_level == 5
            a5 = reshape(approx_coeffs(1:9), 1, []);
            d5 = reshape(detail_coeffs{5}(1:9), 1, []);
            d4 = reshape(detail_coeffs{4}(1:18), 1, []);
            DWT_feature = [a5, d5, d4];
        else
            DWT_feature = approx_coeffs;
        end
    elseif ptb
        if decomposition_level == 5
            DWT_feature = [approx_coeffs(1:9), detail_coeffs{5}(1:9)];
        elseif decomposition_level == 1
            DWT_feature = approx_coeffs;
        end
    end
    if gr
        figure;
        subplot(decomposition_level+1, 1, 1);
        plot(approx_coeffs, 'b'); 
        title('Approximation Coefficients A5', 'FontSize', 12, 'FontWeight', 'bold');
        xlabel('Samples', 'FontSize', 12);
        ylabel('Amplitude', 'FontSize', 12);
        grid on;
        for i = 1:decomposition_level
            subplot(decomposition_level+1, 1, i+1);
            plot(detail_coeffs{i}, 'b'); 
            title(['Detail Coefficients D' num2str(i)], 'FontSize', 12, 'FontWeight', 'bold');
            xlabel('Samples', 'FontSize', 12);
            ylabel('Amplitude', 'FontSize', 12);
            grid on;
        end
        %% Detect PQRST complex
%         FPT = [];
%         beat_index = 1;
%         FPT = QRS_Detection(ecg_segment, fs); 
%         FPT = P_Detection(ecg_segment, fs, FPT); 
%         FPT = T_Detection(ecg_segment, fs, FPT);
%         startP = FPT(beat_index,1); 
%         endT = FPT(beat_index,12);
% 
%         pqrst_segment = ecg_segment(startP:endT);
%         [C, L] = wavedec(pqrst_segment, decomposition_level, wavelet_name);
%         approx_coeffs = appcoef(C, L, wavelet_name, decomposition_level);
%         approx_coeffs = approx_coeffs(:);
%     
%        % Feature vector
%         wavelet_features = [mean(approx_coeffs), std(approx_coeffs)];
%         
%         % Detail coefficients (D1 to Dn)
%         detail_coeffs = cell(1, decomposition_level);
%         for i = 1:decomposition_level
%             detail_coeffs{i} = detcoef(C, L, i);
%             detail_coeffs{i} = detail_coeffs{i}(:);
%             wavelet_features = [wavelet_features; mean(detail_coeffs{i}), std(detail_coeffs{i})];
%         end
%         figure;
%         subplot(2, 1, 1);
%         plot(pqrst_segment, 'b', 'LineWidth', 1);
%         title('P-QRS-T Complex', 'FontSize', 12, 'FontWeight', 'bold');
%         xlabel('Time (samples)', 'FontSize', 12);
%         ylabel('Amplitude', 'FontSize', 12);
%         grid on;
%         
%         % ---- DECOMPOSED WAVELET COEFFICIENTS ----
%         subplot(2, 1, 2);
%         hold on;
%         
%         % Initialize X-axis for the first signal (A5)
%         x_values = 1:length(approx_coeffs);
%         y_values = {approx_coeffs(:)'}; 
%         labels = {'A5'};
%         
%         % Collect all detail coefficients (D5 to D1)
%         for i = 1:decomposition_level
%             detail = detail_coeffs{decomposition_level - i + 1}(:)';  
%             y_values{end + 1} = detail;
%             labels{end + 1} = ['D' num2str(decomposition_level - i + 1)];
%         end
%         
%         % Adjust X-axis to ensure continuous signal (NO GAPS)
%         x_offset = 1; % Start from 1
%         for i = 1:length(y_values)
%             x_range = x_offset:x_offset + length(y_values{i}) - 1;
%             
%             % Plot wavelet coefficients
%             plot(x_range, y_values{i}, 'LineWidth', 1.2);
%             
%             % Update X-offset to ensure continuity
%             x_offset = x_range(end);  
%         end
%         
%         % Add labels aligned below the X-axis
%         y_min = min(cellfun(@min, y_values)) - 0.1 * abs(min(cellfun(@min, y_values)));
%         title('Decomposed Wavelet Coefficients of PQRST Complex', 'FontSize', 12, 'FontWeight', 'bold');
%         xlabel('Samples', 'FontSize', 12);
%         ylabel('Amplitude', 'FontSize', 12);
%         grid on;
%         hold off;
    end
end