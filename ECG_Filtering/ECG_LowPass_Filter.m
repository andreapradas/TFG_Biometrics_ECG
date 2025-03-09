% ECG_Low_Filter - Applies a low-pass Butterworth filter to an ECG signal.
%
% Syntax:
%   [filteredsignal] = ECG_Low_Filter(signal, samplerate, lowpass_frequency)
%
% Inputs:
%   signal - The input ECG signal (1D vector).
%   fs - The sampling rate of the ECG signal (Hz).
%   lowpass_frequency - The cutoff frequency for the low-pass filter (Hz).
%   gr - Boolean flag to generate plots (1 = plot, 0 = no plot).
%
% Outputs:
%   filteredsignal - The filtered ECG signal after applying the low-pass filter.
%
% Description:
%   This function applies a low-pass Butterworth filter of order 3 to the
%   input ECG signal to remove high-frequency noise. The signal is extended 
%   to avoid border artifacts during filtering. The extension is removed 
%   after filtering. The filter is applied in a zero-phase forward and 
%   reverse filtering using 'filtfilt' to avoid phase distortion.
%
% Notes:
%   - The function assumes the input signal is one-dimensional (a single channel).
%   - The signal is extended by 10 seconds at both ends before filtering.
%   - The function checks if the low-pass frequency is above the Nyquist frequency
%     and adjusts it if necessary.
    
function [filtered_signal]=ECG_LowPass_Filter(signal,fs,lowpass_frequency, gr)
    
    % Ensure the signal is a column vector (1D)
    if isrow(signal)
        signal = signal';
    end

    % Ensure the signal is of type double for accurate calculations
    flagsingle = 0;
    if ~isa(signal,'double')
        signal = double(signal);
        flagsingle = 1;
    end

    % Extend the signal by 10 seconds to avoid border artifacts during filtering
    l = round(fs * 10);  % 10 seconds of padding
    filtered_signal = [zeros(l, 1); signal; zeros(l, 1)];
    
    % Extend the signal using zero-padding (symmetrical padding)
    filtered_signal = wextend(1, 'sp0', signal, l, 'r');
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
        plot(f, abs(H), 'b', 'LineWidth', 2);
        xlabel('Frequency (Hz)');
        ylabel('Magnitude');
        title('Frequency Response of the Low-Pass Butterworth Filter');
        grid on;
    end
end
