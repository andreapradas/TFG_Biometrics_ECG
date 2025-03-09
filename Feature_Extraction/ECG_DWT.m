% Extracts DWT approximation and detail coefficients from an ECG signal.
%
% Parameters:
%   ecg_signal - Vector containing the ECG signal.
%   wavelet_name - Name of the wavelet (e.g., 'db3').
%   decomposition_level - Number of decomposition levels (e.g., 5).
%   gr - Boolean flag to generate plots (1 = plot, 0 = no plot).
%
% Returns:
%   wavelet_features - Matrix containing the mean and standard deviation 
%                     of the approximation and detail coefficients.
%
function [wavelet_features] = ECG_DWT(ecg_signal, wavelet_name, decomposition_level, gr)
    % Perform the Discrete Wavelet Transform (DWT) decomposition
    [C, L] = wavedec(ecg_signal, decomposition_level, wavelet_name);

    % Extract approximation coefficients (A)
    approx_coeffs = appcoef(C, L, wavelet_name, decomposition_level);

    % Initialize the wavelet features vector
    wavelet_features = [];
    
    % Add the mean and standard deviation of approximation coefficients
    wavelet_features = [wavelet_features; mean(approx_coeffs), std(approx_coeffs)];

    % Extract detail coefficients (D1 to Dn)
    detail_coeffs = cell(1, decomposition_level);
    for i = 1:decomposition_level
        detail_coeffs{i} = detcoef(C, L, i);
        
        % Add the mean and standard deviation of detail coefficients at level i
        wavelet_features = [wavelet_features; mean(detail_coeffs{i}), std(detail_coeffs{i})];
    end
    if gr
        figure;
        subplot(decomposition_level+1, 1, 1);
        plot(approx_coeffs, 'b'); 
        title('Approximation Coefficients (A)', 'FontSize', 12, 'FontWeight', 'bold');
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
    end
end