% ECG_HighPass_Filter Applies a high-pass Butterworth filter to an ECG signal.
%
% This function removes low-frequency noise (e.g., baseline wander) from an ECG signal
% by applying a high-pass Butterworth filter of order 3. The filter is implemented using 
% zero-phase filtering to avoid phase distortion. The signal is symmetrically extended 
% to reduce border artifacts and trimmed after filtering. Isoline correction is applied 
% at the end to remove any DC offset.
%
% Parameters:
%   ecg_signal          - The input ECG signal (1D vector).
%   fs                  - Sampling frequency of the ECG signal (Hz).
%   highpass_frequency  - Cutoff frequency of the high-pass filter (Hz).
%   gr                  - Boolean flag to generate plots (1 = plot, 0 = no plot).
%
% Returns:
%   filtered_signal     - The ECG signal after high-pass filtering and isoline correction.
%

function [filtered_signal]=ECG_HighPass_Filter(ecg_signal,fs,highpass_frequency, gr)
    % Ensure the signal is a column vector
    if isrow(ecg_signal)
        ecg_signal = ecg_signal';
    end

    % Ensure the signal is of type double for accurate calculations
    flagsingle = 0;
    if ~isa(ecg_signal, 'double')
        ecg_signal = double(ecg_signal);
        flagsingle = 1;  % Mark that the input was converted to double
    end

    % Extend the signal by 10 seconds to avoid border artifacts during filtering
    l = round(fs * 10);  % 10 seconds of padding
    filtered_signal = [zeros(l, 1); ecg_signal; zeros(l, 1)];
    
    % Extend the signal using zero-padding (symmetrical padding)
    filtered_signal = wextend(1, 'sp0', ecg_signal, l, 'r');
    filtered_signal = wextend(1, 'sp0', filtered_signal, l, 'l');
    
    % Apply Nyquist check: ensure highpass frequency does not exceed Nyquist frequency
    if highpass_frequency > fs / 2
        disp('Warning: Highpass frequency above Nyquist frequency. Using Nyquist frequency instead.');
        highpass_frequency = floor(fs / 2 - 1);
    end
    
    % Design the Butterworth high-pass filter
    order = 3;  % Filter order
    [z, p, k] = butter(order, (2 * highpass_frequency / fs), 'high');
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
        [H, f] = freqz(sos, 1024, fs);  % Compute frequency response
        plot(f, abs(H), 'b');
        xlabel('Frequency (Hz)');
        ylabel('Magnitude');
        title('Frequency Response of the High-Pass Butterworth Filter');
        grid on;
    end
end