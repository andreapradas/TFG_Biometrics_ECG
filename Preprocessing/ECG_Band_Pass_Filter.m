% ECG_Band_Pass_Filter Applies a band-pass filter to the input ECG signal.
%
% This function applies a band-pass Butterworth filter by sequentially applying 
% a low-pass and then a high-pass filter to the ECG signal. This process removes 
% both low-frequency baseline wander and high-frequency noise, retaining only 
% the frequencies within the desired passband.
%
% Parameters:
%   ecg_signal         - The input ECG signal (1D vector).
%   fs                 - Sampling frequency of the ECG signal in Hz.
%   highpass_freq      - Cutoff frequency for the high-pass filter (Hz).
%   lowpass_freq       - Cutoff frequency for the low-pass filter (Hz).
%   gr                 - Boolean flag to generate plots (1 = plot, 0 = no plot).
%
% Returns:
%   filtered_signal    - The ECG signal after band-pass filtering.
%
    
function [filtered_signal]=ECG_Band_Pass_Filter(ecg_signal,fs,highpass_freq,lowpass_freq, gr)
    % Apply low-pass filter to remove high-frequency noise
    filtered_signal = ECG_LowPass_Filter(ecg_signal,fs,lowpass_freq, gr);

    % Apply high-pass filter to remove low-frequency noise
    filtered_signal = ECG_HighPass_Filter(filtered_signal,fs,highpass_freq, gr);
end