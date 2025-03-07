% ECG_Band_Pass_Filter applies a band-pass filter to the input ECG signal.
%
% This function first applies a high-pass filter to remove low-frequency
% noise and then applies a low-pass filter to remove high-frequency noise.
% The resulting signal is passed through both filters in sequence to
% retain frequencies within the specified band.
%
% Parameters:
%   signal - The input ECG signal (1D array of signal data).
%   fs - The sampling frequency of the ECG signal in Hz.
%   highpass_frequency - The cutoff frequency for the high-pass filter in Hz.
%   lowpass_frequency - The cutoff frequency for the low-pass filter in Hz.
%
% Returns:
%   filteredsignal - The ECG signal after applying both the high-pass and low-pass filters.
    
function [filteredsignal]=ECG_Band_Pass_Filter(signal,fs,highpass_frequency,lowpass_frequency)
   
    % Apply high-pass filter to remove low-frequency noise
    filteredsignal = ECG_High_Filter(signal,fs,highpass_frequency);
    
    % Apply low-pass filter to remove high-frequency noise
    filteredsignal = ECG_Low_Filter(filteredsignal,fs,lowpass_frequency);
end