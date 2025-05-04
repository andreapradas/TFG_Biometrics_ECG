% FIR_Remove_BLW Removes Baseline Wander (BLW) using an FIR high-pass filter.
%
% This function applies a high-pass FIR filter designed with the Kaiser 
% window method to remove baseline wander from an ECG signal.
%
% Parameters:
%   ecg_signal - The contaminated ECG signal (input).
%   fs   - Sampling frequency (Hz).
%   fc   - Cut-off frequency for high-pass filtering (Hz).
%   gr - Boolean flag to generate plots (1 = plot, 0 = no plot).
%
% Returns:
%   filtered_signal - The filtered ECG signal without baseline wander.

function [filtered_signal] = ECG_FIR_Remove_BLW(ecg_signal, fs, fc, gr)

    % Define the transition band for the high-pass filter
    fcuts = [fc (fc + 0.07)]; % Transition band from 0.67 to 0.74 Hz

    % Desired filter magnitude response
    mags = [0 1]; % High-pass filter: 0 (stop) below Fc, 1 (pass) above Fc
    
    % Allowed deviations in stopband and passband
    devs = [0.005 0.001]; % Ripple of band pass - stop band
    
    % Design the FIR filter using the Kaiser window method
    [n, Wn, beta, ftype] = kaiserord(fcuts, mags, devs, fs); % Filter order and parameters
    
    % Compute the FIR filter coefficients
    b = fir1(n, Wn, ftype, kaiser(n + 1, beta), 'noscale');
    a = 1; % FIR filter (denominator is 1)
    
    [H, F] = freqz(b, a, n, fs);

    % Apply zero-phase filtering to avoid phase distortion
    filtered_signal = filtfilt(b, a, ecg_signal);

    if gr
        % Plot the magnitude response
        figure;
        plot(F, abs(H), 'b'); 
        hold on;
        grid on;
        
        % Highlight the cutoff frequency
        fc_index = find(F >= fc, 1, 'first');
        plot(fc, abs(H(fc_index)), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
        title('Frequency Response of the FIR High-Pass Filter', 'FontWeight', 'bold');
        xlabel('Frequency (Hz)');ylabel('Magnitude');
        text(fc, abs(H(fc_index)) + 0.1, sprintf('  Fc = %.2f Hz', fc), ...
             'Color', 'k', 'FontSize', 10, 'FontWeight', 'bold', ...
             'BackgroundColor', 'w', 'EdgeColor', 'k', 'Margin', 2);
        hold off;
    end
end
