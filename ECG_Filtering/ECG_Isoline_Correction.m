% ECG_Isoline_Correction removes the baseline offset from an ECG signal.
%
% This function estimates and removes the baseline offset using the 
% median of the signal, which provides a more robust baseline correction 
% than using the mode of the histogram.
%
% Parameters:
%   signal - Input ECG signal (column vector).
%   varargin - (Optional) Number of bins for the histogram.
%
% Returns:
%   filtered_signal - The ECG signal after baseline correction.
%   offset - The estimated baseline offset.
%   frequency_matrix - The frequency counts of the histogram.
%   bins_matrix - The bin centers of the histogram.

function [filtered_signal,offset,frequency_matrix,bins_matrix]=ECG_Isoline_Correction(signal,varargin)
    
    % Check if the input signal is a column vector
    if size(signal, 2) > 1
        error('The input signal must be a column vector');
    end
    
    % Assign number of bins for the histogram
    if isempty(varargin)
        number_bins = min(2^10, length(signal)); % Default number of bins
    else
        number_bins = varargin{1}; % Provided number of bins
    end
    
    % Compute histogram of the signal
    [frequency_matrix, bin_edges] = histcounts(signal, number_bins);
    
    % Determine the offset using the median instead of the histogram mode
    offset = median(signal); % More robust baseline estimation
    
    % Remove the offset from the signal
    filtered_signal = signal - offset;
    
    % Return histogram bins
    bins_matrix = (bin_edges(1:end-1) + bin_edges(2:end)) / 2;
end