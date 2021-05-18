function transformMatrix = buildChromaTransform(n_fft, samplerate)
% BUILDCHROMATRANSFORM Build a trasformation matrix for converting from
% STFT spectrum to Chroma vector for harmonic analysis.
% 
% n_fft (required) - FFT window size for the spectrum to be converted
% samplerate (required) - samplerate of the audio being analyzed
% 
% If the samplerate is 44.1k or 48k, n_fft = 2048 is recommended. If
% samplerate is 88.2k (who even uses that?) or 96k, n_fft = 4096 is
% recommended. If samplerate is 192k, n_fft = 8192 is recommended.
% 
% This function is set up with the assumption that we are working in the
% western 12-tone system. It currently does not support tuning adjustment,
% but that is a planned feature.

% This function is based on the chroma filter from the Librosa audio
% analysis library. Code and information is available at www.librosa.org.

    NUM_CHROMA = 12;
    NUM_CHROMA_HALF = 6;
    
    % Get the frequency bins for the FFT, skipping the DC component (the 0
    % bin)
    frequencies = linspace(0, samplerate, n_fft+1);
    frequencies = frequencies(2:end-1);
    
    % Convert bin frequencies to midi note values
    %todo: the log2() portion will need to be adjusted to allow for
    %variable tuning (i.e., A442, A432, etc)
    midiBins = 12 * log2(frequencies / (440.0 / 16));
    
    % Add DC bin back in 1.5 oct below bin 1
    midiBins = [(midiBins(1) - 1.5 * 12) midiBins];
    
    % Get bin widths
    binWidths = [(max((midiBins(2:end) - midiBins(1:end-1)), 1.0)) 1.0];
    
    D = zeros(n_fft,12);
    for i = 1:n_fft
        row = zeros(1,12);
        for j = 0:11
            row(j+1) = midiBins(i) - j;
        end
        D(i,:) = row;
    end
    D = D.';
    
    %todo: replace NUM_CHROMA and NUM_CHROMA_HALF with 12 and 6.
    % Project into range -6 to 6
    D = mod(D + NUM_CHROMA_HALF + 12*NUM_CHROMA, NUM_CHROMA) - NUM_CHROMA_HALF;
    
    % Make Gaussian bumps
    binWidthsTile = zeros(12,n_fft);
    for i = 1:12
        binWidthsTile(i,:) = binWidths;
    end
    transformMatrix = exp(-0.5 * (2 .* D ./ binWidthsTile).^2);
    
    % Normalize
    for i = 1:n_fft
        column_max = max(transformMatrix(:,i));
        for j = 1:12
            transformMatrix(j,i) = transformMatrix(j,i) / column_max;
        end
    end
    
    
    % Apply scaling for FFT bins
    scaleTile = zeros(12,n_fft);
    temp = exp(-0.5 * (((filter_freq_bins./12 - 5.0)./2.0).^2));
    for i = 1:12
        scaleTile(i,:) = temp;
    end
    
    % Prep for output
    transformMatrix = transformMatrix .* scaleTile;
    transformMatrix = transformMatrix(:, 1:1 + n_fft / 2);
    


end