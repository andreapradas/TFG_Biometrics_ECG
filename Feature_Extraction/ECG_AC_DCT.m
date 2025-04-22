% ECG_Autocorrelation computes the autocorrelation, power spectral density, 
% and visualizes the results for a given ECG signal.
%
% This function calculates the energy of the ECG signal, its autocorrelation, 
% and the power spectral density using the Wiener-Khintchine theorem. 
% Additionally, it computes the cross-correlation with a random signal and 
% the convolution of two signals for analysis.







function [AC_DCT_coef, rxx_norm, Sxx, lags] = ECG_AC_DCT(ecg_signal, L, fs, gr)
    %% Autocorrelation Rxx[k]
    N = length(ecg_signal);
    rxx = xcorr(ecg_signal, 'biased'); % Compute biased autocorrelation
    lags = -N+1:N-1; % Dimension of the AC is 2*N-1 (computationally high)

    % Normalize the autocorrelation
    rxx_norm = rxx / max(rxx); % Normalize by maximum amplitude usually Rxx[0]
%     
%     %% Apply Discrete Cosine Transform (DCT)
%     Y = dct(rxx_norm); 
%     % Compute cumulative energy
%     Y_energy = cumsum(Y.^2) / sum(Y.^2);
% 
%     % Select K to reach the defined energy threshold
%     K = find(Y_energy >= energy_threshold, 1);
% 
%     % Select only the first K coefficients
%     DCT_coef = Y(1:K);
% 
%     % JUST TO PROVE THE RECONSTRUCTION
%     Y_reduced = zeros(N, 1);
%     Y_reduced(1:K) = Y(1:K);
%     rxx_reconstructed = idct(Y_reduced);

    %% Windowing 5 seconds ECG signal

    N = 5 * fs;
    K = 40;
    num_windows = floor(length(ecg_signal) / N);

    DCT_coef_matrix = zeros(num_windows, K); 
    lags = -length(ecg_signal) + 1:length(ecg_signal) - 1;

    if gr
        figure;
        subplot(4,1,1);
        hold on;
        title('ECG Signal (5 seconds)');
        xlabel('Time (ms)');
        ylabel('Amplitude');
        grid on;
    
        subplot(4,1,2);
        hold on;
        title('AC (Normalized)');
        xlabel('Time (ms)');
        ylabel('Amplitude');
        grid on;
    
        subplot(4,1,3);
        hold on;
        title('300 AC');
        xlabel('Time (ms)');
        ylabel('Normalized Power');
        grid on;
    
        subplot(4,1,4);
        hold on;
        title('Zoomed DCT (40 Coefficients)');
        xlabel('DCT Coefficients');
        ylabel('Magnitude');
        grid on;
    end
    for i = 1:num_windows
        start_idx = (i - 1) * N + 1;
        end_idx = start_idx + N - 1;
        ecg_win = ecg_signal(start_idx:end_idx);
        
        rxx_win = xcorr(ecg_win, 'biased');
        rxx_win = rxx_win / max(rxx_win);  
        
        ac_start = ceil(length(rxx_win) / 2);
        rxx_firstL = rxx_win(ac_start : ac_start + L - 1);
        
        DCT_coef_win = dct(rxx_firstL);
        
        DCT_coef_matrix(i, :) = DCT_coef_win(1:K);

        if gr
            t_ecg = (start_idx:end_idx) / fs * 1000; 
            t_ac = (0:(2*N-2)) / fs * 1000;  
    
            if i == 1
                subplot(4,1,1);
                plot(t_ecg, ecg_win, 'b');
    
                subplot(4,1,2);
                plot(t_ac, rxx_win, 'r');
            end
    
            subplot(4,1,3);
            plot((0:L-1) * (1000/fs), rxx_firstL, 'r');
    
            subplot(4,1,4);
            plot(0:K-1, DCT_coef_matrix(i, :), 'k');
        end
    end
    %% Power Spectral Density (Wiener-Khintchine Theorem)
    Sxx = fftshift(fft(rxx)); % FFT of the autocorrelation function
    Sxx = abs(Sxx).^2; % Compute power spectral density
    f = linspace(-0.5, 0.5, length(Sxx)); % Normalized frequency axis

    %% Visualization (if enabled)
    if gr        
        figure;
        subplot(2,2,1);
        plot(ecg_signal, 'b'); title('ECG Signal x[n]'); xlabel('n'); ylabel('Amplitude');
        xlim([0 300]);
        subplot(2,2,2);
        plot(lags, rxx, 'b'); title('Autocorrelation rxx[k]'); xlabel('k'); ylabel('rxx[k]');
        subplot(2,2,3);
        plot(lags, rxx_norm, 'b'); title('Normalized Autocorrelation'); xlabel('k'); ylabel('rxx[k] / max(rxx)');
        subplot(2,2,4);
        plot(f, Sxx, 'b'); title('Power Spectral Density Sxx(ω)'); xlabel('Frequency'); ylabel('|X(ω)|^2');
%         figure;
%         plot(1:K, DCT_coef, 'r*-'); title(['Top ', num2str(K), ' DCT Coefficients']); xlabel('Index'); ylabel('Magnitude');
%         figure;
%         plot(Y_energy, 'b', 'LineWidth', 2); 
%         hold on;
%         yline(energy_threshold, 'r--', 'LineWidth', 2);
%         xline(K, 'g--', 'LineWidth', 2); 
%         xlabel('Number of DCT Coefficients');ylabel('Cumulative Energy');
%         title('Cumulative Energy of DCT Coefficients');
%         legend('Cumulative Energy', 'Energy Threshold', 'Selected K');
%         grid on;
    end

    % Output DCT coefficients
    AC_DCT_coef = reshape(DCT_coef_matrix.', 1, []);
end