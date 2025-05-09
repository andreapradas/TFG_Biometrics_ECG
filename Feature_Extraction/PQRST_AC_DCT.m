% PQRST_AC_DCT extracts features from a single PQRST ECG segment using Autocorrelation and DCT.
%
% This function implements the Autocorrelation + DCT (AC/DCT) feature extraction 
% method for a single ECG beat (PQRST complex). It computes the normalized 
% autocorrelation of the input segment and applies the Discrete Cosine Transform (DCT) 
% to a selected number of autocorrelation lags. This method is fiducial-free and 
% suitable for beat-level ECG analysis.
%
% Parameters:
%   ecg_segment - Vector containing a single PQRST segment of the ECG signal.
%   L           - Number of autocorrelation lags to retain (starting at lag 0).
%   K           - Number of DCT coefficients to retain from the autocorrelation.
%   fs          - Sampling frequency of the ECG signal in Hz.
%   gr          - Boolean flag to enable plotting (1 = plot, 0 = no plot).
%
% Returns:
%   AC_DCT_coef - Row vector containing the first K DCT coefficients of the AC.
%

function [AC_DCT_coef] = PQRST_AC_DCT(ecg_segment, L, K, fs, gr)
    %% Autocorrelation Rxx[k]
    N = length(ecg_segment);
    rxx = xcorr(ecg_segment, 'biased');
    % lags = -N+1:N-1; % Dimension of the AC is 2*N-1 (computationally high)

    % Normalize the autocorrelation
    rxx_norm = rxx / max(rxx); % Normalize by maximum amplitude usually Rxx[0]
    
    center = ceil(length(rxx) / 2); % m=0 (max.) is in the middle 
    rxx_firstL = rxx_norm(center : center + L - 1); % Only first L AC scoeff. (from m=0)
    
    DCT_coef = dct(rxx_firstL);
    AC_DCT_coef = DCT_coef(1:K); % Only first K DCT coeff. 

    if gr
        t_ecg = (0:length(ecg_segment)-1) / fs * 1000; 
        figure;
        subplot(3,1,1);
        plot(t_ecg, ecg_segment, 'b');
        title('PQRST complex');
        xlabel('Time (ms)');
        ylabel('Amplitude');
        grid on;

        subplot(3,1,2);
        plot((0:L-1) * (1000/fs), rxx_firstL, 'r');
        title(['First ' num2str(L) ' AC Coefficients']);
        xlabel('Lag (ms)');
        ylabel('Amplitude');
        grid on;

        subplot(3,1,3);
        plot(0:K-1, AC_DCT_coef, 'k');
        title(['First ' num2str(K) ' DCT Coefficients']);
        xlabel('DCT Index');
        ylabel('Magnitude');
        grid on;
    end
end