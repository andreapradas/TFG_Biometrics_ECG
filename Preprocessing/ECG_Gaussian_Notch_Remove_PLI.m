% ECG_Gaussian_Notch_Remove_PLI removes periodic interference using Gaussian notch filters.
%
% This function attenuates harmonic noise at integer multiples of a fundamental 
% frequency (f0) by applying Gaussian-shaped notch filters in the frequency domain.
% The input signal is extended to reduce edge effects, and a composite filter is 
% created by centering Gaussian notches at each harmonic of f0. Filtering is 
% performed in the Fourier domain, and the result is transformed back to the time domain.
%
% Parameters:
%   ecg_signal - Input ECG signal (matrix: samples x channels).
%   fs         - Sampling frequency in Hz.
%   f0         - Fundamental frequency to suppress (e.g., 60 Hz or 50 Hz).
%   width      - Bandwidth of each notch filter in Hz (controls Gaussian spread).
%   gr         - Boolean flag to enable diagnostic plots (1 = plot, 0 = no plot).
%
% Returns:
%   filtered_signal - ECG signal after notch filtering.
%
function filtered_signal=ECG_Gaussian_Notch_Remove_PLI(ecg_signal, fs, f0, width, gr)
    utils = ECGutils;
    
    % The spectrum will have peaks at k*f0Hz. K gives the greatets number n 
    % that can be chosen for a harmonic oscillation without going beyond the 
    % nyquist frequency 
    K = floor(fs/2*1/f0);
    
    % Extend signal to avoid boundary effects
    extpoints = round(0.5*ceil(fs/width));
    signal_extended = zeros(size(ecg_signal,1)+2*extpoints,size(ecg_signal,2));
    for i = 1:size(ecg_signal,2)
        signal_extended(:,i) = wextend('1D','sp0',ecg_signal(:,i),extpoints);
    end
    
    L = size(signal_extended,1);
    f = (0:1:L-1)/L*fs; % Frequency vector
    
    sigmaf = width; % Standard deviation of gaussian window used to select frequency
    sigma = ceil(L*sigmaf/fs); % Sigma discrete
    lg = 2*round(4*sigma)+1; % Size of gaussian window
    lb = (lg-1)/2; % Position of center of guassian window
    g = fspecial('gaussian',[1,lg],sigma)'; % Gaussian window
    g = 1/(max(g)-min(g))*(max(g)-g); % Scale gaussian window to be in interval [0;1]
    
    H = ones(size(signal_extended,1),1); % Filter
    
    % Implementation of periodical gaussian window at k*f0Hz
    for k = 1:K
            [~,b] = min(abs(f-k*f0)); % Discrete position at which f=k*f0Hz
            H(b-lb:b+lb) = g; % Gaussian bell placed around k*f0Hz
            H(L+2-b-lb:L+2-b+lb) = g; % Gaussian bell placed symmetriclly around samplerate-k*f0Hz   
    end
    
    H = repmat(H,1,size(signal_extended,2)); % Reproduce the filter for all channels
    X = fft(signal_extended); % FFT of signal
    Y = H.*X; % Filtering process in the Fourier Domain
        
    filtered_signal = real(ifft(Y)); % Reconstruction of filtered signal
    filtered_signal = filtered_signal(extpoints+1:end-extpoints,:);
    
    if gr
         % Compute and plot frequency response of the filter
        figure;
        plot(f, H(:,1), 'b');
        xlabel('Frequency (Hz)'); ylabel('Gain');
        title('Gaussian Notch Filter Frequency Response');
        xlim([0 360]);
        ylim([-0.05 1.05]);
        grid on;
    end
end