% ECG_Complete_Filtering applies a complete filtering pipeline to an ECG signal.
%
% This function removes powerline interference, baseline wander, and other 
% artifacts from the raw ECG signal. The filtering process consists of:
%   1. A notch filter at 60 Hz to remove powerline interference.
%   2. A high-pass FIR filter to remove baseline wander.
%   3. A band-pass filter to retain the relevant ECG frequency components.
%   4. Isoline correction to adjust the signal offset.
%
% Parameters:
%   raw_ecg - The raw input ECG signal (1D array).
%   fs - The sampling frequency of the ECG signal in Hz.
%   gr - Boolean flag to generate plots (1 = plot, 0 = no plot).
%
% Returns:
%   ecg_filtered - The fully processed ECG signal after filtering.
%

function [ecg_filtered] = ECG_Complete_Filtering(raw_ecg,fs, gr)
    utils = ECGutils;
    %% Powerline interference removal --> Notch Filter 60 Hz
    f0 = 60; % In USA 
    width = 1; % Bandwidth of the notch filter
    ecg_noPowerline = ECG_Gaussian_Notch_Remove_PLI(raw_ecg, fs, f0, width, gr);
    % ecg_noPowerline = ECG_IIR_Remove_PLI(raw_ecg, fs, f0, gr);
    t = (0:length(raw_ecg)-1) / fs; % Time in seconds

    if gr
        utils.plotComparison(t,raw_ecg,ecg_noPowerline,'Raw ECG', 'No PI ECG');
    
        % SNR after powerline interference removal
        SNR_noPI = utils.computeSNR(ecg_noPowerline, fs, [0.5 40], [59 61]);
    
        % FFT
        [f, module_noPowerline, phase_noPowerline] = utils.computeFFT(ecg_noPowerline, fs);
        figure;
        subplot(2,1,1);
        utils.plotFrequencyDomain(f, module_noPowerline, 'Magnitude of the FFT (After PI removal)', 'b');
        subplot(2,1,2);
        utils.plotFrequencyDomain(f, phase_noPowerline, 'Phase of the FFT (After PI removal)', 'b');
        
        % Zoomed-in region around 60 Hz (After Filtering)
        figure;
        utils.plotFrequencyDomain(f, module_noPowerline, 'Zoomed-in FFT (After PI removal, 60 Hz)', 'b');
        xlim([50 70]);
    end 
    %% Baseline Wander removal --> FIR high-pass filter
    fc = 0.67; % Cut-off frequency 
    ecg_noBLW = ECG_FIR_Remove_BLW(ecg_noPowerline,fs,fc,gr);
    
    if gr
        utils.plotComparison(t,ecg_noPowerline,ecg_noBLW,'No PI ECG', 'No BW ECG');
        
        % FFT
        [f, module_noBW, phase_noBW] = utils.computeFFT(ecg_noBLW, fs);
        figure;
        subplot(2,1,1);
        utils.plotFrequencyDomain(f, module_noBW, 'Magnitude of the FFT (After BW removal)', 'b');
        subplot(2,1,2);
        utils.plotFrequencyDomain(f, phase_noBW, 'Phase of the FFT (After BW removal)', 'b');
    end
    %% Other artifacts --> Band-pass filter
    highpass_freq = 0.5;
    lowpass_freq = 40;
    ecg_noArtifacts = ECG_Band_Pass_Filter(ecg_noBLW, fs, highpass_freq, lowpass_freq, gr);
    [ecg_filtered, offset,~,~] = ECG_Isoline_Correction(ecg_noArtifacts, 500);
    
    if gr
        utils.plotComparison(t,ecg_noBLW, ecg_filtered, 'No BW ECG', 'Filtered ECG');
        utils.plotTimeDomain(t,ecg_filtered,'Filtered ECG', 'b' );
        % FFT
        [f, module_filtered, phase_filtered] = utils.computeFFT(ecg_filtered, fs);
        figure;
        subplot(2,1,1);
        utils.plotFrequencyDomain(f, module_filtered, 'Magnitude of the FFT (After filtering)', 'b');
        subplot(2,1,2);
        utils.plotFrequencyDomain(f, phase_filtered, 'Phase of the FFT (After filtering)', 'b');
    end
end