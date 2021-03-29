classdef (StrictDefaults)HarmonEQ_old2 < matlab.System & audioPlugin
% HarmonEQ_old2.m
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
% - Determine frequency range. Should I just default to 20-20kHz?
% - Include instructions for running the plugin (eq = HarmonEQ;
% visualize(eq); audioTestBench(eq);
% - Intonation knob / Reference pitch
% - Add rootFreq0 = 22.5?
    

% This is a test program for understanding how creating a visualization
% with UDP works in Matlab.
% 
% ParametricEqualizerWithUDP Tune the frequency response of an audio signal.
%   This example shows a 3-band parametric equalizer audio plugin. Each
%   band provides a center frequency in Hertz, a Q factor, and a gain in
%   decibels.
%
%   This plugin also uses dsp.UDPSender to send the equalizer 
%   coefficients over UDP every time step is called. This allows the
%   deployed VST plugin to communicate from a digital audio workstation
%   (DAW) it runs in to MATLAB in real time. It allows, as an example,
%   visualizing the magnitude response of the equalizer in real time as the
%   equalizer processes audio in a DAW. For more details, consult
%   'Communicate Between a DAW and MATLAB Using UDP' in the documentation.
%
%   Note that in this example, the filter is redesigned even if data
%   processing has not yet begun, i.e., the object is unlocked. The code
%   can be simplified if it is only desired to redesign the filter once
%   data processing has begun. For an example of such a scenario, see
%   audiopluginexample.HighpassIIRFilter.
%
%   This is an example of an audio plugin that is also a System object.
%
%   % Example: Visualize equalizer response while executing.
%   equalizer = audiopluginexample.ParametricEqualizerWithUDP;
%   visualize(equalizer);
%   audioTestBench(equalizer);
%
% See also: audiopluginexample.UDPSender, designParamEQ,
% multibandParametricEQ
    
    %   Copyright 2015-2020 The MathWorks, Inc.
    %#codegen
    
    %----------------------------------------------------------------------
    % Public properties
    %----------------------------------------------------------------------
    %-----TUNABLE PROPERTIES-----
    properties
        RootNote = 'A';
    end
    
    properties
        % Center frequencies for each band
        CenterFrequency1 = 110
        CenterFrequency2 = 220
        CenterFrequency3 = 440
        
        % Q factors for each band
        QualityFactor1 = 20
        QualityFactor2 = 20
        QualityFactor3 = 20
        
        % dB gain for each band % Set to non-zerof or testing
        PeakGain1 = -3
        PeakGain2 = -3
        PeakGain3 = -3
        
        %---
        ReferencePitch = 440;
        
        %---
        % center frequencies for root bands
        rootFreq1 = 55;
        rootFreq2 = 110;
        rootFreq3 = 220;
        rootFreq4 = 440;
        rootFreq5 = 880;
        rootFreq6 = 1760;
        rootFreq7 = 3520;
        rootFreq8 = 7040;
        rootFreq9 = 14080; %TODO: How hi/low should these go?
        
        % Q factors for root bands
        rootQFactor1 = 20;
        rootQFactor2 = 20;
        rootQFactor3 = 20;
        rootQFactor4 = 20;
        rootQFactor5 = 20;
        rootQFactor6 = 20;
        rootQFactor7 = 20;
        rootQFactor8 = 20;
        rootQFactor9 = 20;
        
        % dB gain for root bands %TODO: set to 3 for testing, reset to 0
        % when done
        rootGain1 = 3;
        rootGain2 = 3;
        rootGain3 = 3;
        rootGain4 = 3;
        rootGain5 = 3;
        rootGain6 = 3;
        rootGain7 = 3;
        rootGain8 = 3;
        rootGain9 = 3;
        
        % Previous state of filters
        rootPrevState1 = zeros(2);
        rootPrevState2 = zeros(2);
        rootPrevState3 = zeros(2);
        rootPrevState4 = zeros(2);
        rootPrevState5 = zeros(2);
        rootPrevState6 = zeros(2);
        rootPrevState7 = zeros(2);
        rootPrevState8 = zeros(2);
        rootPrevState9 = zeros(2);
        
        % Update status variables for filters
        updateRoot1 = false;
        updateRoot2 = false;
        updateRoot3 = false;
        updateRoot4 = false;
        updateRoot5 = false;
        updateRoot6 = false;
        updateRoot7 = false;
        updateRoot8 = false;
        updateRoot9 = false;
        
    end
    
    %----------------------------------------------------------------------
    % Constant properties
    %----------------------------------------------------------------------
    properties (Constant, Hidden)
        % audioPluginInterface manages the number of input/output channels
        % and also instantiates the value class, audioPluginParameter to
        % generate plugin UI parameters.
        PluginInterface = audioPluginInterface(...
            'InputChannels',2,...
            'OutputChannels',2,...
            'PluginName','HarmonEQ',...
            audioPluginParameter('PeakGain1','DisplayName','Low Gain','Label','dB',...
            'Mapping',{'lin',-20,20},'Style','vslider','Layout',[1 1]),...
            audioPluginParameter('CenterFrequency1','DisplayName','Low Frequency','Label','Hz',...
            'Mapping',{'log',20,20e3},'Style','rotaryknob','Layout',[3 1]),...
            audioPluginParameter('QualityFactor1','DisplayName','Low Q',...
            'Mapping',{'log',0.2,700},'Style','rotaryknob','Layout',[5 1]),...
            audioPluginParameter('PeakGain2','DisplayName','Mid Gain','Label','dB',...
            'Mapping',{'lin',-20,20},'Style','vslider','Layout',[1 2]),...
            audioPluginParameter('CenterFrequency2','DisplayName','Mid Frequency','Label','Hz',...
            'Mapping',{'log',20,20e3},'Style','rotaryknob','Layout',[3 2]),...
            audioPluginParameter('QualityFactor2','DisplayName','Mid Q',...
            'Mapping',{'log',0.2,700},'Style','rotaryknob','Layout',[5 2]),...
            audioPluginParameter('PeakGain3','DisplayName','High Gain','Label','dB',...
            'Mapping',{'lin',-20,20},'Style','vslider','Layout',[1 3]),...
            audioPluginParameter('CenterFrequency3','DisplayName','High Frequency','Label','Hz',...
            'Mapping',{'log',20,20e3},'Style','rotaryknob','Layout',[3 3]),...
            audioPluginParameter('QualityFactor3','DisplayName','High Q',...
            'Mapping',{'log',0.2,700},'Style','rotaryknob','Layout',[5 3]), ...
            ...
            audioPluginParameter('RootNote','DisplayName','Root Note',...
            'Mapping',{'enum','A','A# / Bb','B','C','C# / Db','D','D# / Eb',...
            'E','F','F# / Gb','G','G# / Ab'},'Layout',[2 4]),...
            ...
            audioPluginGridLayout('RowHeight', [200 20 100 20 100 20], ...
            'ColumnWidth', [100 100 100 200], 'Padding', [10 10 10 30]));
    end
    
    %----------------------------------------------------------------------
    % Private properties
    %----------------------------------------------------------------------
    properties (Access = protected)
         % Properties to store numerator and denominator coefficient
        % matrices. One column for each band. Leading 1 in denominator
        % coefficients is omitted
        Num 
        Den
        B; % for storing the numerator coefficients
        A; % for storing the denominator coefficients
    end
    
    %----------------------------------------------------------------------
    % Private properties
    %----------------------------------------------------------------------
    properties (Access = private, Hidden)
       
        % Property to store Biquad filter
        % Stores Nx6 second-order sections (SOS). Each row of the SOS
        % matrix contains the numerator and denominator coefficients of the
        % corresponding section of the filter.
        sos        
               
        % Flag to indicate whether filter re-design is needed
        AreFiltersDesigned = false;
        
        % Handle to objects used for visualization
        visualObj
                
        % Property to store UDP sender System object
        udpsend
        
        OrderForViz
    end
    
    properties (Access = private, Nontunable)
        % 
        FilterOrder
    end
    
    %----------------------------------------------------------------------
    % public methods
    %----------------------------------------------------------------------
    methods
        
        function plugin = HarmonEQ_old2(N)
            % Construct biquad filter
            plugin.sos =  dsp.BiquadFilter('SOSMatrixSource','Input port',...
                'ScaleValuesInputPort',false);
            
            if nargin < 1
                N = 2;
            end
            plugin.FilterOrder = N;
            plugin.OrderForViz = N;
            
            plugin.Num = [ones(1,3*ceil(N/2));zeros(2,3*ceil(N/2))];
            plugin.Den = zeros(2,3*ceil(N/2));
            
            % Construct UDP sender
            plugin.udpsend = dsp.UDPSender('RemoteIPPort', 20000);
        end
        
        %------------------------------------------------------------------
        % SETTERS & GETTERS
        %------------------------------------------------------------------
        
        function set.CenterFrequency1(plugin,value)                                    
            plugin.CenterFrequency1 = value;
            needToDesignFilters(plugin);
        end
        function set.CenterFrequency2(plugin,value)                                    
            plugin.CenterFrequency2 = value;
            needToDesignFilters(plugin);
        end
        function set.CenterFrequency3(plugin,value)                                    
            plugin.CenterFrequency3 = value;
            needToDesignFilters(plugin);
        end
        
        function set.QualityFactor1(plugin,value)            
            plugin.QualityFactor1 = value;
            needToDesignFilters(plugin);
        end
        function set.QualityFactor2(plugin,value)            
            plugin.QualityFactor2 = value;
            needToDesignFilters(plugin);
        end
        function set.QualityFactor3(plugin,value)            
            plugin.QualityFactor3 = value;
            needToDesignFilters(plugin);
        end
        
        function set.PeakGain1(plugin,value)            
            plugin.PeakGain1 = value;       
            needToDesignFilters(plugin);
        end
        function set.PeakGain2(plugin,value)            
            plugin.PeakGain2 = value;
            needToDesignFilters(plugin);
        end
        function set.PeakGain3(plugin,value)            
            plugin.PeakGain3 = value;
            needToDesignFilters(plugin);
        end
        
        function set.RootNote(plugin,val)
            validatestring(val, {'A','A# / Bb','B','C','C# / Db','D',...
                'D# / Eb','E','F','F# / Gb','G','G# / Ab'},...
                'set.RootNote', 'RootName');
            plugin.RootNote = val;
            plugin.updateRoot1 = true;
            plugin.updateRoot2 = true;
            plugin.updateRoot3 = true;
            plugin.updateRoot4 = true;
            plugin.updateRoot5 = true;
            plugin.updateRoot6 = true;
            plugin.updateRoot7 = true;
            plugin.updateRoot8 = true;
            plugin.updateRoot9 = true;
            needToDesignFilters(plugin); % TODO: create custom function for this
        end
        
        function visualize(plugin,NFFT)
            %VISUALIZE Visualize magnitude response of equalizer
            %   VISUALIZE(plugin) shows the magnitude response of the
            %   multiband equalizer. If shelving filters and/or
            %   lowpass/highpass filters are enabled, they will be included
            %   in the magnitude response.
            %
            %   VISUALIZE(plugin,NFFT) uses NFFT points to display the
            %   magnitude response.
            if nargin < 2
                NFFT = 2048;
            end
            
            if isempty(plugin.visualObj) || nargin > 1
                Fs = getSampleRate(plugin);                               
                designFilters(plugin);
                plugin.visualObj = dsp.DynamicFilterVisualizer(...
                    NFFT,Fs,[20 20e3], ...
                    'XScale','Log', ...
                    'YLimits', [-25 25], ...
                    'Title', 'HarmonEQ');%,...
%                     'ShowLegend', true, ...
%                     'FilterNames', {'Band 1','Band 2','Band 3','Overall Equalizer'}); 
            else
                if ~isVisible(plugin.visualObj)
                    show(plugin.visualObj);
                end
            end
            % Step the visual object with the filter
            step(plugin.visualObj, plugin);
        end
        
        function [b,a] = coeffs(plugin)
            if ~plugin.AreFiltersDesigned
                % Re-design filters when necessary
                designFilters(plugin);
            end
            b = plugin.Num;
            a = plugin.Den;
        end
    end
    
    methods (Access = protected)
        function  setupImpl(plugin, ~)
            % Make sure filters are designed at setup
            if ~plugin.AreFiltersDesigned
                % Re-design filters when necessary
                designFilters(plugin);                
            end
        end
        
        function Output = stepImpl(plugin, Input)  
            % Process using biquad filter
            Output = plugin.sos(Input,plugin.Num,plugin.Den);
            
             % Send coefficients through UDP
            B = plugin.Num;
            A = plugin.Den;
            plugin.udpsend([B(:); A(:)]);
        end
        
        function processTunedPropertiesImpl(plugin)
            % Every time a tunable parameter is called after locking
            if ~plugin.AreFiltersDesigned
                % Re-design filters when necessary
                designFilters(plugin);                
            end
        end               
        
        function resetImpl(plugin)
            designFilters(plugin);
            refreshVisual(plugin);
            % Reset Biquad states
            reset(plugin.sos);
        end                
    end
    
    methods (Hidden)        
        function varargout = getFilterCoefficients(plugin)
            N = plugin.OrderForViz;
            varargout{1} = plugin.Num(:,1:ceil(N/2)).';
            varargout{2} = [1;plugin.Den(:,1:ceil(N/2))].';
            varargout{3} = plugin.Num(:,ceil(N/2)+1:2*ceil(N/2)).';
            varargout{4} = [1;plugin.Den(:,ceil(N/2)+1:2*ceil(N/2))].';
            varargout{5} = plugin.Num(:,2*ceil(N/2)+1:3*ceil(N/2)).';
            varargout{6} = [1;plugin.Den(:,2*ceil(N/2)+1:3*ceil(N/2))].';
            varargout{7} = plugin.Num.';
            varargout{8} = [ones(1,size(plugin.Den,2));plugin.Den].';
        end
    end
    
    methods (Access = private)
        function needToDesignFilters(plugin)
            plugin.AreFiltersDesigned = false;
            if plugin.updateRoot1 == true
                
            end
            
            plugin.updateRoot1 = false;
            plugin.updateRoot2 = false;
            plugin.updateRoot3 = false;
            plugin.updateRoot4 = false;
            plugin.updateRoot5 = false;
            plugin.updateRoot6 = false;
            plugin.updateRoot7 = false;
            plugin.updateRoot8 = false;
            plugin.updateRoot9 = false;
            
            %TODO: Add code to update root note filters
            
            % Update visual if visualize has been called
            if isempty(coder.target) && ~isempty(plugin.visualObj) 
                designFilters(plugin);
                refreshVisual(plugin);
            end
        end
        
        function refreshVisual(plugin)
            if isempty(coder.target) && ~isempty(plugin.visualObj)
                [num1,den1,num2,den2,num3,den3,num4,den4] = getFilterCoefficients(plugin);
                step(plugin.visualObj, ...
                     num1, den1, ... % First band coefficients
                     num2, den2, ... % second band coefficients
                     num3, den3, ... % third band coefficients
                     num4, den4); % overall filter coefficients
                plugin.visualObj.SampleRate = plugin.getSampleRate;
            end
        end
        
        function designFilters(plugin)
            
            % Calculating sample rate.
            Fs = plugin.getSampleRate;
            
            N = plugin.FilterOrder;
            G = [plugin.PeakGain1,plugin.PeakGain2,plugin.PeakGain3];
            Wo = [plugin.CenterFrequency1,plugin.CenterFrequency2,plugin.CenterFrequency3]/(Fs/2);
            Q = [plugin.QualityFactor1,plugin.QualityFactor2,plugin.QualityFactor3];
            BW = Wo./Q;
            [B,A] = designParamEQ(N,G,Wo,BW);
            plugin.Num = B;
            plugin.Den = A;              
            plugin.AreFiltersDesigned = true;
        end
        
        function [b, a] = peakNotchFilterCoeffs(~, fs, frequency, Q, gain)
            % prep
            A = sqrt(10.^(gain/20));
            omega0 = 2 * pi * frequency / fs;
            cos_omega = -2 * cos(omega0);
            alpha = sin(omega0) / (2  * Q);
            alpha_A = alpha * A;
            alpha_div_A = alpha / A;
            
            % Coefficients
            b0 = 1 + alpha_A;
            b1 = cos_omega;
            b2 = 1 - alpha_A;
            a0 = 1 + alpha_div_A;
            a1 = cos_omega;
            a2 = 1 - alpha_div_A;
            
            b = [b0, b1, b2];
            a = [a0, a1, a2];
        end
        
    end
    
    
    methods (Hidden)
        function h = freqz(plugin, f, Fs)
            % H = freqz(plugin, F, Fs) returns the frequency response, H,
            % at the physical frequencies supplied in F, given the sample
            % rate, Fs.
            [c{1}, c{2}, c{3}, c{4}, c{5}, c{6}, c{7}, c{8}] = getFilterCoefficients(plugin);
            if rem(length(c),2)
                c{end+1} = 0;
            end
            Npairs = length(c)/2;
            h = zeros(length(f),Npairs);
            
            for n = 1:Npairs
                B = c{2*n-1};
                A = c{2*n};
                h(:,n) = freqz(B(1,:), A(1,:), f, Fs);
                for k = 2:size(B,1)
                    h(:,n) = h(:,n).*freqz(B(k, :), A(k, :) , f, Fs).';
                end
            end
        end
    end 
end