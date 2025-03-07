% FIR_Remove_BLW Removes Baseline Wander (BLW) using an FIR high-pass filter.
%
% This function applies a high-pass FIR filter designed with the Kaiser 
% window method to remove baseline wander from an ECG signal.
%
% Parameters:
%   ecg - The contaminated ECG signal (input).
%   Fs   - Sampling frequency (Hz).
%   Fc   - Cut-off frequency for high-pass filtering (Hz).
%
% Returns:
%   ECG_Clean - The filtered ECG signal without baseline wander.

function [ECG_Clean] = FIR_Remove_BLW(ecg,Fs,Fc)

    % Define the transition band for the high-pass filter
    fcuts = [Fc (Fc + 0.07)]; % Transition band from 0.67 to 0.74 Hz

    % Desired filter magnitude response
    mags = [0 1]; % High-pass filter: 0 (stop) below Fc, 1 (pass) above Fc
    
    % Allowed deviations in stopband and passband
    devs = [0.005 0.001]; % Ripple of band pass - stop band
    
    % Design the FIR filter using the Kaiser window method
    [n, Wn, beta, ftype] = kaiserord(fcuts, mags, devs, Fs); % Filter order and parameters
    
    % Compute the FIR filter coefficients
    b = fir1(n, Wn, ftype, kaiser(n + 1, beta), 'noscale');
    a = 1; % FIR filter (denominator is 1)
    
%     freqz(b, a, n, Fs);
%     [H, F] = freqz(b, a, n, Fs);
% 
%     % Plot the magnitude response
%     figure;
%     plot(F, abs(H), 'b'); 
%     hold on;
%     grid on;
%     
%     % Highlight the cutoff frequency
%     Fc_index = find(F >= Fc, 1, 'first');
%     plot(Fc, abs(H(Fc_index)), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
%     
%     % Add labels and title
%     title('Frequency Response of the FIR High-Pass Filter', 'FontSize', 12, 'FontWeight', 'bold');
%     xlabel('Frequency (Hz)', 'FontSize', 12);
%     ylabel('Magnitude', 'FontSize', 12);
%     
%     % Adjust annotation position slightly above the marker
%     text(Fc, abs(H(Fc_index)) + 0.1, sprintf('  Fc = %.2f Hz', Fc), ...
%          'Color', 'k', 'FontSize', 10, 'FontWeight', 'bold', ...
%          'BackgroundColor', 'w', 'EdgeColor', 'k', 'Margin', 2);
%     hold off;

    % Apply zero-phase filtering to avoid phase distortion
    ECG_Clean = filtfilt(b, a, ecg);
end
