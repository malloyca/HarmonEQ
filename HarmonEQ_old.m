% HarmonEQ.m
% Harmonic equalizer plugin
% Updated: 17 March 2021
% 
% This plugin presents a new control scheme for the traditional equalizer.
% Most people are familiar with the various types of EQs out there
% (graphics EQs, parametric and semi-parametric EQs, etc). These tools work
% well for many jobs, but sometimes certain situations would benefit from
% an EQ that is defined in a more musically-informed way. HarmonEQ is a
% plugin designed to showcase a new control paradigm for the standard
% parametric EQ that is based on harmony instead of direct control by the
% user. This allows the user to target the EQ more finely based on the
% current harmony of a track. 

% TODO:
% - Get visualizer working...
% - - Track how MathWorks was using visualObject to store and organize the
% visualization data.
% - Filter initialization in setupImpl
% - Design prototype UI - Including UDP-based visualizer
% - Implement LP filter
% - Implement help text
% 

classdef HarmonEQ < matlab.System & audioPlugin
% HARMONEQ
    %----------------------------------------------------------------------
    % TUNABLE PROPERTIES
    %----------------------------------------------------------------------
    properties
        % Initial testing of peak filters        
        CenterFrequency1 = 110
        CenterFrequency2 = 220
        CenterFrequency3 = 440
        
        % Q factors for each band
        QualityFactor1 = 2
        QualityFactor2 = 2
        QualityFactor3 = 2
        
        % dB gain for each band
        PeakGain1 = 3
        PeakGain2 = 3
        PeakGain3 = 3
        
    end
    
    %----------------------------------------------------------------------
    % INTERFACE
    %----------------------------------------------------------------------
    properties (Constant)
        
    end
    
    %----------------------------------------------------------------------
    % PRIVATE PROPERTIES
    %----------------------------------------------------------------------
    properties (Access=private)
        % Property to store UDP sender System object
        UDPsend
        visualObj
        AreFiltersDesigned = false;
        
        low_state = zeros(2);
        mid_state = zeros(2);
        hi_state = zeros(2);
    end
    
    properties (Access = protected)
        % Properties to store numerator and denominator coefficient
        % matrices. One column for each band. Leading 1 in denominator
        % coefficients is omitted.
        b_coeff = zeros(3,3);
        a_coeff = zeros(3,3);
    end
    
    methods
        %------------------------------------------------------------------
        % INITIALIZATION
        %------------------------------------------------------------------
        function plugin = HarmonEQ()
            
            % Construct UDP sender
            plugin.UDPsend = dsp.UDPSender('RemoteIPPort', 20000);
        end
        
        %------------------------------------------------------------------
        % MAIN PROCESSING BLOCK
        %------------------------------------------------------------------
%         function out = process(plugin,in)
%             out = in;
%         end
        
        %------------------------------------------------------------------
        % SETTERS
        %------------------------------------------------------------------
        % TODO - after I setup UI
        
        
        %------------------------------------------------------------------
        % RESET
        %------------------------------------------------------------------
%         function reset(plugin)
%             
%         end
        
        %------------------------------------------------------------------
        % VISUALIZER
        %------------------------------------------------------------------
%         function visualizer(plugin)
%             UDPReciver = dsp.UDPReceiver('LocalIPPort', 20000, ...
%                                          'MessageDataType', 'double', ...
%                                          
%         end
        
%         function visualize(plugin,NFFT)
%             %VISUALIZE Visualize magnitude response of equalizer
%             %   VISUALIZE(plugin) shows the magnitude response of the
%             %   multiband equalizer. If shelving filters and/or
%             %   lowpass/highpass filters are enabled, they will be included
%             %   in the magnitude response.
%             %
%             %   VISUALIZE(plugin,NFFT) uses NFFT points to display the
%             %   magnitude response.
%             if nargin < 2
%                 NFFT = 2048;
%             end
%             Fs = getSampleRate(plugin);
%             
%             vis = dsp.DynamicFilterVisualizer( ...
%                 NFFT, Fs, [20, 20e3], ...
%                 'XScale', 'Log', ...
%                 'YLimits', [-10 10], ...
%                 'Title', 'HarmonEQ', ...
%                 'ShowLegend', true, ...
%                 'FilterNames', {'Low','Mid','Hi','Overall Equalizer'});
%             show(vis)
%             
%             b = plugin.b_coeff;
%             a = plugin.a_coeff;
%             vis(b, a);
%             
% %             if isempty(plugin.visualObj) || nargin > 1
% %                 Fs = getSampleRate(plugin);                               
% %                 %designFilters(plugin);
% %                 plugin.visualObj = dsp.DynamicFilterVisualizer(...
% %                     NFFT,Fs,[20 20e3], ...
% %                     'XScale','Log', ...
% %                     'YLimits', [-10 10], ...
% %                     'Title', 'HarmonEQ',...
% %                     'ShowLegend', true, ...
% %                     'FilterNames', {'Low','Mid','Hi','Overall Equalizer'});
%                 
% %             else
% %                 if ~isVisible(plugin.visualObj)
% %                     show(plugin.visualObj);
% %                 end
% %             end
% %             % Step the visual object with the filter
% %             step(plugin.visualObj, plugin);
%         end

        function visualize(plugin,NFFT)
            %VISUALIZE Visualize magnitude response of equalizer
            %   VISUALIZE(plugin) shows the magnitude response of the
            %   filter.
            %
            %   VISUALIZE(plugin,NFFT) uses NFFT points to display the
            %   magnitude response.
            if nargin < 2
                NFFT = 2048;
            end
            
            if isempty(plugin.visualObj)
                Fs = getSampleRate(plugin);                               
                calculateCoefficients(plugin);
                
                plugin.visualObj = dsp.DynamicFilterVisualizer(...
                    NFFT,Fs,[20 20e3], ...
                    'XScale', 'Log', ...
                    'YLimits', [-60 0], ...
                    'Title', 'Variable Slope IIR Bandpass Filter');
            else
                plugin.visualObj.FFTLength = NFFT;
                if ~isVisible(plugin.visualObj)
                    show(plugin.visualObj);
                end
            end
            % Step the visual object with the filter
            step(plugin.visualObj, plugin);
        end
        
    end
    
    methods(Access = protected)
        function setupImpl(plugin, ~)
            % TODO - initialize filters here
            fs = getSampleRate(plugin);
            
            [low_b, low_a] = peakNotchFilterCoeffs(plugin, fs, 110, 2, 3);
            [mid_b, mid_a] = peakNotchFilterCoeffs(plugin, fs, 220, 2, 3);
            [hi_b, hi_a] = peakNotchFilterCoeffs(plugin, fs, 440, 2, 3);
            
            b = [low_b; mid_b; hi_b];
            a = [low_a; mid_a; hi_a];
            
%             plugin.UDPsend([b, a]);
            
            plugin.b_coeff = b;
            plugin.a_coeff = a;
        end
        
        function out = stepImpl(plugin, in)
            sig = in;
            
            fs = getSampleRate(plugin);
            % Send coefficients through UDP to visualizer
%             b = plugin.Num; % TODO - redesign this
%             a = plugin.Den; % TODO - redisign this
            
            % Calculate filter coefficients
            [low_b, low_a] = peakNotchFilterCoeffs(plugin, fs, 110, 2, 3);
            [mid_b, mid_a] = peakNotchFilterCoeffs(plugin, fs, 220, 2, 3);
            [hi_b, hi_a] = peakNotchFilterCoeffs(plugin, fs, 440, 2, 3);
            
            % make filters
            [sig, plugin.low_state] = filter(low_b, low_a, sig, plugin.low_state);
            [sig, plugin.mid_state] = filter(mid_b, mid_a, sig, plugin.low_state);
            [sig, plugin.hi_state] = filter(hi_b, hi_a, sig, plugin.low_state);
            
            b = [low_b, mid_b, hi_b];
            a = [low_a, mid_a, hi_a];
            
            plugin.UDPsend([b, a]);
            
            plugin.b_coeff = b;
            plugin.a_coeff = a;
            out = sig;
        end
        
        function resetImpl(plugin)
            fs = getSampleRate(plugin);
            [low_b, low_a] = peakNotchFilterCoeffs(plugin, fs, 110, 2, 3);
            [mid_b, mid_a] = peakNotchFilterCoeffs(plugin, fs, 220, 2, 3);
            [hi_b, hi_a] = peakNotchFilterCoeffs(plugin, fs, 440, 2, 3);
            
            b = [low_b, mid_b, hi_b];
            a = [low_a, mid_a, hi_a];
            
            plugin.UDPsend([b, a]);
            
            plugin.b_coeff = b;
            plugin.a_coeff = a;
        end
        
        function processTunedPropertiesImpl(plugin)
            % Action when tunable properties change
            % Every time a tunable parameter is called after locking
            % TODO - if ~plugin.AreFiltersDesigned then
            % designFilters(plugin);
        end
        
    end
    
    %----------------------------------------------------------------------
    % PRIVATE METHODS
    %----------------------------------------------------------------------
    
    % The resource used for these calculations was the Cookbook formulae
    % for audio equalizer biquad filter coefficients by Robert
    % Bristow-Johnson. Available at:
    % https://webaudio.github.io/Audio-EQ-Cookbook/audio-eq-cookbook.html
    methods (Access = private)
        
        % This generates the filter coefficients for a peak-notch filter.
        % These coefficients can be fed into the Matlab filter() function.
        function [b, a] = peakNotchFilterCoeffs(~, fs, frequency, Q, gain)
            % prep work
            A = sqrt(10.^(gain/20)); % TODO - optimize this by moving parts of it outside this function?
            omega0 = 2 * pi * frequency / fs;
            cos_omega = cos(omega0);
            alpha = sin(omega0) / (2  * Q);
            alpha_A = alpha * A;
            alpha_div_A = alpha / A;
            
            % Coefficients
            b0 = 1 + alpha_A;
            b1 = -2 * cos_omega;
            b2 = 1 - alpha_A;
            a0 = 1 + alpha_div_A;
            a1 = -2 * cos_omega;
            a2 = 1 - alpha_div_A;
            
            b = [b0, b1, b2];
            a = [a0, a1, a2];
        end
        
        function needToDesignFilters(plugin)
            plugin.AreFiltersDesigned = false; % TODO
            % Update visual if visualize has been called
            if isempty(coder.target) && ~isempty(plugin.visualObj) 
                calculateCoefficients(plugin);
                num = plugin.Num.';
                den = plugin.Den;
                den = [ones(1,size(den,2));den].';
                step(plugin.visualObj, num, den);
                plugin.visualObj.SampleRate = plugin.getSampleRate;
            end
        end
        
    end
    
end













