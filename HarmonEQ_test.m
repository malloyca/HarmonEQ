classdef HarmonEQ_test < matlab.System & audioPlugin
% HarmonEQ_test.m
%
% This is a new test version for HarmonEQ to rebuild it froms scratch. I'm
% finding using the Matlab example plugin as a base overwhelming due to
% there being so much stuff that I don't understand. I want to start with
% something very basic that hopefully I can understand.
%
% TODO:
%
%

    %----------------------------------------------------------------------
    % TUNABLE PROPERTIES
    %----------------------------------------------------------------------
    properties
        rootNote = 'A';
                
    end
    
    
    properties
        % Center frequencies for root bands
        rootFrequency1 = 55;
        
        % Q factors for root bands
        rootQFactor1 = 20;
        
        % Gain for root bands (dB)
        rootGain1 = 3;
        
        % Update status variables for root filters
        updateRoot1 = false;
        
    end
    
    %----------------------------------------------------------------------
    % CONSTANT PROPERTIES (INTERFACE)
    %----------------------------------------------------------------------
    properties (Constant, Hidden)
        PluginInterface = audioPluginInterface(...
            'InputChannels',2,...
            'OutputChannels',2,...
            'PluginName','HarmonEQ',...
            audioPluginParameter('rootNote','DisplayName','Root Note',...
            'Mapping',{'enum','A','A# / Bb','B','C','C# / Db','D','D# / Eb',...
            'E','F','F# / Gb','G','G# / Ab'},'Layout',[2 4]));
    end
    
    
    %----------------------------------------------------------------------
    % PROTECTED PROPERTIES
    %----------------------------------------------------------------------
    properties (Access = protected)
        B; % Store b filter coefficients
        A; % Store a filter coefficients
    end
    
    %----------------------------------------------------------------------
    % PRIVATE PROPERTIES
    %----------------------------------------------------------------------
    properties (Access = private, Hidden)
        % Root band coefficients
        rootCoeffb1;
        rootCoeffa1;
        rootPrevState1 = zeros(2);
        
    end
    
    
    %----------------------------------------------------------------------
    % PUBLIC METHODS
    %----------------------------------------------------------------------
    methods (Access = protected)
        function out = stepImpl(plugin,in)
            %-------------------Get necessary parameters-------------------
            fs = getSampleRate(plugin);
            
            %-------------------Update filter parameters-------------------
            if plugin.updateRoot1
                [plugin.rootCoeffb1, plugin.rootCoeffa1] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency1,...
                    plugin.rootQFactor1,...
                    plugin.rootGain1);
                plugin.updateRoot1 = false;
            end
            
            %------------------------Process audio-------------------------
            %TODO: Implement universal gain
            %TODO: Do I want pre-filter gain or just post-filter gain?
            %in = 10.^(plugin.inputGain/20) * in;
            
            % Root note filters
            [in, plugin.rootPrevState1] = filter(plugin.rootCoeffb1,...
                plugin.rootCoeffa1, in, plugin.rootPrevState1);
            
            %TODO: output gain?
            %out = 10.^(plugin.outputGain/20) * in);
            out = in;
        end
        
        function setupImpl(plugin,~)
            fs = getSampleRate(plugin);
            
            % Initialize filters
            [plugin.rootCoeffb1, plugin.rootCoeffa1] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.rootFrequency1,...
                plugin.rootQFactor1,...
                plugin.rootGain1);
            
        end
        
        function resetImpl(plugin)
            %TODO: resetFilters / resetAllFilters / resetRootFilters /
            %resetThirdFilters / resetFifthFilters / resetSeventhFilters
            
        end
        
    end
    
    methods
        
        
        
        
        %------------------------------------------------------------------
        % SETTERS
        %------------------------------------------------------------------
        function set.rootNote(plugin,val)
            validatestring(val, {'A','A# / Bb','B','C','C# / Db','D',...
                'D# / Eb','E','F','F# / Gb','G','G# / Ab'},...
                'set.rootNote', 'RootName');
            plugin.rootNote = val;
            plugin.updateRoot1 = true; %TODO: create a function to update the root frequency
            %plugin.updateThird1 = true;
            updateRootFrequencies(plugin,val);
            display(val);
        end
        
        
    end
    
    
    %----------------------------------------------------------------------
    % PRIVATE METHODS
    %----------------------------------------------------------------------
    methods (Access = private)
        
        %--------------------Design Filter Coefficients--------------------
        function [b, a] = peakNotchFilterCoeffs(~, fs, frequency, Q, gain)
            % prep
            A = 10.^(gain/40);
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
        
        function updateRootFrequencies(plugin, val)
            switch val %TODO: Eventually create a getBaseFreq function for this...
                case 'A'
                    plugin.rootFrequency1 = 55;
                case 'A# / Bb'
                    plugin.rootFrequency1 = 58.27047;
                case 'B'
                    plugin.rootFrequency1 = 61.73541;
                case 'C'
                    plugin.rootFrequency1 = 32.70320;
                case 'C# / Db'
                    plugin.rootFrequency1 = 34.64783;
                case 'D'
                    plugin.rootFrequency1 = 36.70810;
                case 'D# / Eb'
                    plugin.rootFrequency1 = 38.89087;
                case 'E'
                    plugin.rootFrequency1 = 41.20344;
                case 'F'
                    plugin.rootFrequency1 = 43.65353;
                case 'F# / Gb'
                    plugin.rootFrequency1 = 46.24930;
                case 'G'
                    plugin.rootFrequency1 = 48.99943;
                case 'G# / Ab'
                    plugin.rootFrequency1 = 51.91309;
            end
            
            %TEST
            display(plugin.rootFrequency1);
        end
        
    end
    
    
end















