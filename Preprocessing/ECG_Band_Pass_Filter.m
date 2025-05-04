% ECG_Band_Pass_Filter applies a band-pass filter to the input ECG signal.
%
% This function first applies a high-pass filter to remove low-frequency
% noise and then applies a low-pass filter to remove high-frequency noise.
% The resulting signal is passed through both filters in sequence to
% retain frequencies within the specified band.
%
% Parameters:
%   ecg_signal - The input ECG signal (1D array of signal data).
%   fs - The sampling frequency of the ECG signal in Hz.
%   highpass_frequency - The cutoff frequency for the high-pass filter in Hz.
%   lowpass_frequency - The cutoff frequency for the low-pass filter in Hz.
%
% Returns:
%   filtered_signal - The ECG signal after applying both the high-pass and low-pass filters.
    
function [filtered_signal]=ECG_Band_Pass_Filter(ecg_signal,fs,highpass_freq,lowpass_freq, gr)
    % Apply low-pass filter to remove high-frequency noise
    filtered_signal = ECG_LowPass_Filter(ecg_signal,fs,lowpass_freq, gr);

    % Apply high-pass filter to remove low-frequency noise
    filtered_signal = ECG_HighPass_Filter(filtered_signal,fs,highpass_freq, gr);
end