% ECG_AC_DCT extracts ECG features using the Autocorrelation and DCT method (AC/DCT).
%
% This function implements the AC/DCT method for feature extraction from ECG signals 
% without relying on fiducial point detection. It segments the input ECG signal into 
% non-overlapping windows, computes the normalized autocorrelation of each window, and 
% applies the Discrete Cosine Transform (DCT) to a selected number of lags. The resulting 
% DCT coefficients are concatenated to form the final feature vector.
%
% Parameters:
%   ecg_signal - The input ECG signal (vector).
%   L - Number of autocorrelation lags to retain before applying DCT.
%   K - Number of DCT coefficients to retain from each window.
%   fs - Sampling frequency of the ECG signal in Hz.
%   gr - Boolean flag to generate plots (1 = plot, 0 = no plot).
%
% Returns:
%   AC_DCT_coef - Row vector containing the concatenated DCT coefficients for all windows.
%   rxx_norm - Normalized autocorrelation of the full ECG signal.
%   Sxx - Power Spectral Density of the signal (computed via Wiener-Khintchine theorem).
%   lags - Lag values corresponding to the autocorrelation vector.s

function [AC_DCT_coef, rxx_norm, lags] = ECG_AC_DCT(ecg_signal, qrs_i_raw, L, K, fs, gr)
    %% Autocorrelation Rxx[k]
    N = length(ecg_signal);
    rxx = xcorr(ecg_signal, 'biased');
    lags = -N+1:N-1; % Dimension of the AC is 2*N-1 (computationally high)

    % Normalize the autocorrelation
    rxx_norm = rxx / max(rxx); % Normalize by maximum amplitude usually Rxx[0]

    %% Windowing 5 beats ECG signal
%     N = 5 * fs;
%     num_windows = floor(length(ecg_signal) / N);
    num_beats = length(qrs_i_raw);
    num_windows = floor(num_beats / 5);
    DCT_coef_matrix = zeros(num_windows, K); 

    if gr
        figure;
        subplot(4,1,1);
        hold on;
        title('(a) Windowed ECG Signal (5 heartbeats)');
        xlabel('Time (ms)');
        ylabel('Voltage (mV)');
        grid on;
    
        subplot(4,1,2);
        hold on;
        title('(b) Normalized AC');
        xlabel('Time (ms)');
        ylabel('Normalized Power');
        grid on;
    
        subplot(4,1,3);
        hold on;
        title(sprintf('(c) First %d AC Coefficients', L));
        xlabel('Time (ms)');
        ylabel('Normalized Power');
        grid on;
    
        subplot(4,1,4);
        hold on;
        title(sprintf('(d) Zoomed %d DCT Coefficients', K));
        xlabel('DCT Coefficients');
        ylabel('Normalized Power');
        grid on;
    end
    for i = 1:num_windows
        start_idx = qrs_i_raw((i-1)*5 + 1);
        end_idx = qrs_i_raw(i*5);
        if end_idx > length(ecg_signal)
            break;
        end
        ecg_win = ecg_signal(start_idx:end_idx);
        rxx_win = xcorr(ecg_win, 'biased');
        rxx_win_norm = rxx_win / max(rxx_win);  
        
        center = ceil(length(rxx_win) / 2); % m=0 (max.) is in the middle 
        rxx_firstL = rxx_win_norm(center : center + L - 1); % Only first L AC scoeff. (from m=0)
        
        DCT_coef_win = dct(rxx_firstL);
        DCT_coef_matrix(i, :) = DCT_coef_win(1:K); % Only first K DCT coeff. 

        if gr
            if i == 1
                t_ecg = (start_idx:end_idx) / fs * 1000; 
                subplot(4,1,1);
                plot(t_ecg, ecg_win, 'b');
    
                t_ac = (0:(2*length(rxx_win_norm)/2-1)) / fs * 1000;  
                subplot(4,1,2);
                plot(t_ac, rxx_win_norm, 'b');
            end
    
            subplot(4,1,3);
            plot((0:L-1) * (1000/fs), rxx_firstL, 'b');
    
            subplot(4,1,4);
            plot(0:K-1, DCT_coef_matrix(i, :), 'b');
        end
    end
    AC_DCT_coef = reshape(DCT_coef_matrix.', 1, []);
end