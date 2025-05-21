function ECGutils = ECGutils
    % Utility functions for ECG signal processing and visualization
    ECGutils.plotTimeDomain = @plotTimeDomain;
    ECGutils.plotComparison = @plotComparison;
    ECGutils.computeFFT = @computeFFT;
    ECGutils.plotFrequencyDomain = @plotFrequencyDomain;
    ECGutils.computeSNR = @computeSNR;
    ECGutils.evaluateFiltering = @evaluateFiltering;
end
%% Function to plot ECG in the time domain
function plotTimeDomain(t, signal, titleStr, color)
    % Function to plot ECG in the time domain.
    % This function generates a plot of the ECG signal in the time domain.
    %
    % Inputs:
    %   t          - Time vector corresponding to the ECG signal (in seconds)
    %   signal     - The ECG signal (1D array)
    %   titleStr   - The title of the plot
    %   color      - The color to plot the ECG signal
    %
    % Output:
    %   A figure showing the ECG signal in the time domain.

    f = figure; 
    f.Position = [100, 200, 650,210];
    plot(t, signal, color);
    xlim([0 2.5]);
    xlabel('Time (s)');
    ylabel('Amplitude (mV)');
    title(titleStr,'FontWeight', 'bold');
    grid on;
end

%% Function to plot a comparison in time domain between 2 signals
function plotComparison(t, signal1, signal2, title1, title2)
    % This function plots two ECG signals on the same figure for comparison.
    %
    % Inputs:
    %   t        - Time vector corresponding to the ECG signals (in seconds)
    %   signal1  - First ECG signal to be plotted
    %   signal2  - Second ECG signal to be plotted
    %   title1   - Title for the first signal
    %   title2   - Title for the second signal
    %

    f = figure; 
    f.Position = [100, 200, 650,210];
    plot(t, signal1, 'b', 'DisplayName', title1);
    xlim([0 2.5]);
    hold on;
    plot(t, signal2, 'r', 'DisplayName', title2);
    title([title1 ' vs ' title2]); 
    xlabel('Time (s)'); ylabel('Amplitude (mV)');
    legend;
    grid on;
end
%% Function to compute FFT
function [f, module, phase] = computeFFT(ecg_signal, fs)
    % This function computes the FFT of a given ECG signal and returns
    % the frequency vector, magnitude, and phase spectrum.
    %
    % Inputs:
    %   ecg_signal - The ECG signal (1D array)
    %   fs         - Sampling frequency (Hz)
    %
    % Outputs:
    %   f          - Frequency vector (Hz)
    %   module     - Magnitude spectrum
    %   phase      - Phase spectrum

    N = length(ecg_signal);  % Length of the ECG signal
    f = (-N/2:N/2-1)*(fs/N);  % Frequency vector
    
    % Perform FFT and shift the zero frequency component to the center
    ecg_freq = fft(ecg_signal);  
    ecg_freq_shifted = fftshift(ecg_freq);
    
    % Compute magnitude and phase
    module = abs(ecg_freq_shifted);  % Magnitude spectrum
    phase = angle(ecg_freq_shifted);  % Phase spectrum
end

%% Function to plot ECG in the frequency domain (FFT)
function plotFrequencyDomain(f, FFT_signal, titleStr, color)
    % This function plots the frequency domain (FFT) of a signal.
    %
    % Inputs:
    %   f           - Frequency vector (Hz)
    %   FFT_signal  - The FFT signal (magnitude or phase)
    %   titleStr    - The title for the plot
    %   color       - Color for the plot (e.g., 'b' for blue, 'r' for red)
    
    plot(f, FFT_signal, color); 
    xlabel('Frequency (Hz)'); ylabel('Magnitude'); 
    title(titleStr, 'FontWeight', 'bold');  
    grid on; 
end

%% Function to compute SNR
function snrValue = computeSNR(signal, fs, signal_band, noise_band)
    % Function to compute Signal-to-Noise Ratio (SNR) of an ECG signal.
    % This function computes the SNR by calculating the power in the signal band
    % and dividing it by the power in the noise band.
    %
    % Inputs:
    %   signal      - ECG signal (1D array)
    %   fs          - Sampling frequency (Hz)
    %   signal_band - Frequency band for the signal 
    %   noise_band  - Frequency band for the noise 
    %
    % Outputs:
    %   snrValue    - Signal-to-Noise Ratio (SNR) in dB

    signal_power = bandpower(signal, fs, signal_band);
    noise_power = bandpower(signal, fs, noise_band);
    snrValue = 10 * log10(signal_power / (noise_power + eps)); % To avoid divisions by 0
end

%% Fucntion to compute Filtering metrics
function metrics_filtering = evaluateFiltering(raw_ecg, filtered_ecg, fs) 
    % Function to evaluate the performance of filtering.
    % This function computes the improvement in Signal-to-Noise Ratio (SNR) 
    % before and after filtering for different frequency bands.
    %
    % Inputs:
    %   raw_ecg    - The raw ECG signal (1D array)
    %   filtered_ecg - The filtered ECG signal (1D array)
    %   fs          - Sampling frequency (Hz)
    %
    % Outputs:
    %   metrics_filtering - A vector containing the improvement in SNR for each band:
    %                       - SNR improvement for PLI band (59-61 Hz)
    %                       - SNR improvement for BLW band (0.05-0.5 Hz)
    %                       - SNR improvement for High Frequency band (40-100 Hz)

    band_useful = [0.5 40];
    band_PLI = [59 61];
    band_BLW = [0.05 0.5];
    band_high_noise = [40 100];

    SNR_PLI_before = computeSNR(raw_ecg, fs, band_useful, band_PLI);
    SNR_PLI_after = computeSNR(filtered_ecg, fs, band_useful, band_PLI);
    SNR_PLI_imp = SNR_PLI_after - SNR_PLI_before;

    SNR_BLW_before = computeSNR(raw_ecg, fs, band_useful, band_BLW);
    SNR_BLW_after = computeSNR(filtered_ecg, fs, band_useful, band_BLW);
    SNR_BLW_imp = SNR_BLW_after - SNR_BLW_before;

    SNR_HF_before = computeSNR(raw_ecg, fs, band_useful, band_high_noise);
    SNR_HF_after  = computeSNR(filtered_ecg, fs, band_useful, band_high_noise);
    SNR_HF_imp = SNR_HF_after - SNR_HF_before;

    metrics_filtering = [SNR_PLI_imp, SNR_BLW_imp, SNR_HF_imp];
end
