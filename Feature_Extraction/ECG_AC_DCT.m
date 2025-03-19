% ECG_Autocorrelation computes the autocorrelation, power spectral density, 
% and visualizes the results for a given ECG signal.
%
% This function calculates the energy of the ECG signal, its autocorrelation, 
% and the power spectral density using the Wiener-Khintchine theorem. 
% Additionally, it computes the cross-correlation with a random signal and 
% the convolution of two signals for analysis.
%
% Parameters:
%   ecg_signal - Input ECG signal (row vector).
%   gr - flag to plot or not plot (set it 1 to have a plot or set it 0 not
%        to see any plots
%
% Returns:
%   rxx_norm - Normalized autocorrelation of the ECG signal.
%   Sxx - Power spectral density of the signal.
%   k - Lag indices for the autocorrelation function.
%
function [dct_coef, K, rxx_norm, Sxx, lags] = ECG_AC_DCT(ecg_signal, energy_threshold, gr)
    %% Signal Energy
    N = length(ecg_signal);
    Ex = sum(abs(ecg_signal).^2);

    %% Autocorrelation Rxx[k]
    rxx = xcorr(ecg_signal, 'biased'); % Compute biased autocorrelation
    lags = -N+1:N-1; % Dimension of the AC is 1.3M (computationally high)

    % Normalize the autocorrelation
    rxx_norm = rxx / max(rxx); % Normalize by maximum amplitude usually Rxx[0]

    %% Apply Discrete Cosine Transform (DCT)
    Y = dct(rxx_norm); 

     % Compute cumulative energy
    Y_energy = cumsum(Y.^2) / sum(Y.^2);

    % Select K to reach the defined energy threshold
    K = find(Y_energy >= energy_threshold, 1);

    % Select only the first K coefficients
    dct_coef = Y(1:K);
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
        figure;
        plot(1:K, dct_coef, 'r*-'); title(['Top ', num2str(K), ' DCT Coefficients']); xlabel('Index'); ylabel('Magnitude');
        figure;
        plot(Y_energy, 'b', 'LineWidth', 2); 
        hold on;
        yline(energy_threshold, 'r--', 'LineWidth', 2);
        xline(K, 'g--', 'LineWidth', 2); 
        xlabel('Number of DCT Coefficients');
        ylabel('Cumulative Energy');
        title('Cumulative Energy of DCT Coefficients');
        legend('Cumulative Energy', 'Energy Threshold', 'Selected K');
        grid on;
    end
end