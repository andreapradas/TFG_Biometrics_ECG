% ECG_LowPass_Filter Applies a low-pass Butterworth filter to an ECG signal.
%
% This function removes high-frequency noise from an ECG signal by applying a 
% low-pass Butterworth filter of order 3. The filter is implemented using zero-phase 
% filtering to avoid phase distortion. The signal is symmetrically extended before 
% filtering to reduce border effects and trimmed afterward. The function also applies 
% isoline correction after filtering.
%
% Parameters:
%   ecg_signal          - The input ECG signal (1D vector).
%   fs                  - Sampling frequency of the ECG signal (Hz).
%   lowpass_frequency   - Cutoff frequency of the low-pass filter (Hz).
%   gr                  - Boolean flag to generate plots (1 = plot, 0 = no plot).
%
% Returns:
%   filtered_signal     - The ECG signal after low-pass filtering and isoline correction.
%
    
function [filtered_signal]=ECG_LowPass_Filter(ecg_signal,fs,lowpass_frequency, gr)
    
    % Ensure the signal is a column vector (1D)
    if isrow(ecg_signal)
        ecg_signal = ecg_signal';
    end

    % Ensure the signal is of type double for accurate calculations
    flagsingle = 0;
    if ~isa(ecg_signal,'double')
        ecg_signal = double(ecg_signal);
        flagsingle = 1;
    end

    % Extend the signal by 10 seconds to avoid border artifacts during filtering
    l = round(fs * 10);  % 10 seconds of padding
    filtered_signal = [zeros(l, 1); ecg_signal; zeros(l, 1)];
    
    % Extend the signal using zero-padding (symmetrical padding)
    filtered_signal = wextend(1, 'sp0', ecg_signal, l, 'r');
    filtered_signal = wextend(1, 'sp0', filtered_signal, l, 'l');
    
    % Apply Nyquist check: ensure lowpass frequency does not exceed Nyquist frequency
    if lowpass_frequency > fs / 2
        disp('Warning: Lowpass frequency above Nyquist frequency. Using Nyquist frequency instead.');
        lowpass_frequency = floor(fs / 2 - 1);
    end
    
    % Design the Butterworth low-pass filter
    order = 3;  % Filter order
    [z, p, k] = butter(order, 2 * lowpass_frequency / fs); 
    sos = zp2sos(z, p, k);  % Convert to second-order sections (SOS)
    
    % Extract the numerator and denominator coefficients from SOS
    Bs = sos(:, 1:3);  % Numerator coefficients (filter coefficients)
    As = sos(:, 4:6);  % Denominator coefficients (filter coefficients)
    
    % Apply the filter using zero-phase filtering
    for i = 1:size(Bs, 1)
        filtered_signal = filtfilt(Bs(i, :), As(i, :), filtered_signal);
    end
    
    % Remove the extended signal (return to the original signal length)
    filtered_signal = filtered_signal(l + 1:end - l);
    
    % Constant offset removal
    filtered_signal = ECG_Isoline_Correction(filtered_signal);
                
    if flagsingle
        filtered_signal = single(filtered_signal);
    end
    if gr
        figure;
        [H, f] = freqz(sos, 1024, fs);
        plot(f, abs(H), 'b');
        xlabel('Frequency (Hz)');
        ylabel('Magnitude');
        title('Frequency Response of the Low-Pass Butterworth Filter');
        grid on;
    end
end
