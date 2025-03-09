% Gaussian_Notch_Filter applies a Gaussian notch filter to remove periodic noise.
%
% This function removes harmonic noise at multiples of a given fundamental 
% frequency (f0) by applying Gaussian notch filters in the frequency domain.
% It extends the input signal to reduce boundary effects, constructs a Gaussian 
% filter centered at each harmonic, and applies the filter using the Fourier Transform.
%
% Parameters:
%   signal - The input ECG signal (matrix with dimensions: samples x channels).
%   samplerate - The sampling frequency of the ECG signal in Hz.
%   f0 - The fundamental frequency of the noise to be removed in Hz.
%   width - The width of the Gaussian filter around each harmonic in Hz.
%
% Returns:
%   Filtered_Signal - The ECG signal after applying the Gaussian notch filter.
%
function Filtered_Signal=Gaussian_Notch_Filter(signal, samplerate, f0, width)
    utils = ECGutils;
    
    % The spectrum will have peaks at k*f0Hz. K gives the greatets number n 
    % that can be chosen for a harmonic oscillation without going beyond the 
    % nyquist frequency 
    K = floor(samplerate/2*1/f0);
    
    % Extend signal to avoid boundary effects
    extpoints = round(0.5*ceil(samplerate/width));
    signal_extended = zeros(size(signal,1)+2*extpoints,size(signal,2));
    for i = 1:size(signal,2)
        signal_extended(:,i) = wextend('1D','sp0',signal(:,i),extpoints);
    end
    
    L = size(signal_extended,1);
    f = (0:1:L-1)/L*samplerate; % Frequency vector
    
    sigmaf = width; % Standard deviation of gaussian bell used to select frequency
    sigma = ceil(L*sigmaf/samplerate); % Sigma discrete
    lg = 2*round(4*sigma)+1; % Size of gaussian bell
    lb = (lg-1)/2; % Position of center of guassian bell
    g = fspecial('gaussian',[1,lg],sigma)'; % Gaussian bell
    g = 1/(max(g)-min(g))*(max(g)-g); % Scale gaussian bell to be in interval [0;1]
    
    H = ones(size(signal_extended,1),1); % Filter
    
    % Implementation of periodical gaussian bells at k*f0Hz
    for k = 1:K
            [~,b] = min(abs(f-k*f0)); % Discrete position at which f=k*f0Hz
            H(b-lb:b+lb) = g; % Gaussian bell placed around k*f0Hz
            H(L+2-b-lb:L+2-b+lb) = g; % Gaussian bell placed symmetriclly around samplerate-k*f0Hz   
    end
    
    H = repmat(H,1,size(signal_extended,2)); % Reproduce the filter for all channels
    X = fft(signal_extended); % FFT of signal
    Y = H.*X; % Filtering process in the Fourier Domain
        
    Filtered_Signal = real(ifft(Y)); % Reconstruction of filtered signal
    Filtered_Signal = Filtered_Signal(extpoints+1:end-extpoints,:);
end