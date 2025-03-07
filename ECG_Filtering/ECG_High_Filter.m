% ECG_High_Filter - Applies a high-pass Butterworth filter to an ECG signal.
%
% Syntax: 
%   [filteredsignal] = ECG_High_Filter(signal, samplerate, highpass_frequency)
%
% Inputs:
%   signal - The input ECG signal (1D vector).
%   fs - The sampling rate of the ECG signal (Hz).
%   highpass_frequency - The cutoff frequency for the high-pass filter (Hz).
%
% Outputs:
%   filteredsignal - The filtered ECG signal after applying the high-pass filter.
%
% Description:
%   This function applies a high-pass Butterworth filter of order 3 to the
%   input ECG signal to remove low-frequency noise (such as baseline wander).
%   The signal is extended to avoid border artifacts during filtering.
%   The extension is removed after filtering. The filter is applied in a
%   zero-phase forward and reverse filtering using 'filtfilt' to avoid phase
%   distortion.
%
% Notes:
%   - The function assumes the input signal is one-dimensional (a single channel).
%   - The signal is extended by 10 seconds at both ends before filtering.
%   - The function checks if the high-pass frequency is above the Nyquist frequency
%     and adjusts it if necessary.

function [filteredsignal]=ECG_High_Filter(signal,fs,highpass_frequency)
    
    % Ensure the signal is a column vector
    if isrow(signal)
        signal = signal';
    end

    % Ensure the signal is of type double for accurate calculations
    flagsingle = 0;
    if ~isa(signal, 'double')
        signal = double(signal);
        flagsingle = 1;  % Mark that the input was converted to double
    end

    % Extend the signal by 10 seconds to avoid border artifacts during filtering
    l = round(fs * 10);  % 10 seconds of padding
    filteredsignal = [zeros(l, 1); signal; zeros(l, 1)];
    
    % Extend the signal using zero-padding (symmetrical padding)
    filteredsignal = wextend(1, 'sp0', signal, l, 'r');
    filteredsignal = wextend(1, 'sp0', filteredsignal, l, 'l');
    
    % Apply Nyquist check: ensure highpass frequency does not exceed Nyquist frequency
    if highpass_frequency > fs / 2
        disp('Warning: Highpass frequency above Nyquist frequency. Using Nyquist frequency instead.');
        highpass_frequency = floor(fs / 2 - 1);
    end
    
    % Design the Butterworth high-pass filter
    order = 3;  % Filter order
    [z, p, k] = butter(order, 2 * highpass_frequency / fs, 'high');
    sos = zp2sos(z, p, k);  % Convert to second-order sections (SOS)
    
    % Extract the numerator and denominator coefficients from SOS
    Bs = sos(:, 1:3);  % Numerator coefficients (filter coefficients)
    As = sos(:, 4:6);  % Denominator coefficients (filter coefficients)
    
    % Apply the filter using zero-phase filtering
    for i = 1:size(Bs, 1)
        filteredsignal = filtfilt(Bs(i, :), As(i, :), filteredsignal);
    end
    
    % Remove the extended signal (return to the original signal length)
    filteredsignal = filteredsignal(l + 1:end - l);
    
    % Constant offset removal
    filteredsignal = ECG_Isoline_Correction(filteredsignal);
                
    if flagsingle
        filteredsignal = single(filteredsignal);
    end
end