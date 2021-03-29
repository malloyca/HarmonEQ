classdef HarmonEQ < matlab.System & audioPlugin
% HarmonEQ.m
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
        %TODO: these are placeholders until I implement these filters
        thirdNote = 'C';
        fifthNote = 'E';
        seventhNote = 'G';
                
    end
    
    
    properties
        % Center frequencies for root bands
        rootFrequency1 = 55;
        rootFrequency2 = 110;
        rootFrequency3 = 220;
        rootFrequency4 = 440;
        rootFrequency5 = 880;
        rootFrequency6 = 1760;
        rootFrequency7 = 3520;
        rootFrequency8 = 7040;
        rootFrequency9 = 14080;
        
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
        
        % Gain for root bands (dB)
        rootGain1 = 9;
        rootGain2 = 9;
        rootGain3 = 9;
        rootGain4 = 9;
        rootGain5 = 9;
        rootGain6 = 9;
        rootGain7 = 9;
        rootGain8 = 9;
        rootGain9 = 9;
        
        % Update status variables for root filters
        updateRootFilter1 = false;
        updateRootFilter2 = false;
        updateRootFilter3 = false;
        updateRootFilter4 = false;
        updateRootFilter5 = false;
        updateRootFilter6 = false;
        updateRootFilter7 = false;
        updateRootFilter8 = false;
        updateRootFilter9 = false;
        
        % General change of state variable to minimize visualizer updates
        stateChange = false;
        
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
            'Mapping',{'enum','off','A','A# / Bb','B','C','C# / Db','D',...
            'D# / Eb','E','F','F# / Gb','G','G# / Ab'},'Layout',[2 4]));
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
        rootCoeffb2;
        rootCoeffa2;
        rootPrevState2 = zeros(2);
        rootCoeffb3;
        rootCoeffa3;
        rootPrevState3 = zeros(2);
        rootCoeffb4;
        rootCoeffa4;
        rootPrevState4 = zeros(2);
        rootCoeffb5;
        rootCoeffa5;
        rootPrevState5 = zeros(2);
        rootCoeffb6;
        rootCoeffa6;
        rootPrevState6 = zeros(2);
        rootCoeffb7;
        rootCoeffa7;
        rootPrevState7 = zeros(2);
        rootCoeffb8;
        rootCoeffa8;
        rootPrevState8 = zeros(2);
        rootCoeffb9;
        rootCoeffa9;
        rootPrevState9 = zeros(2);
        
        % Active state variables
        rootFiltersActive = true;
        thirdFiltersActive = false;
        fifthFiltersActive = false;
        seventhFiltersActive = false
        
        % For visalization
        visualizerObject;
        
    end
    
    
    %----------------------------------------------------------------------
    % PROTECTED METHODS
    %----------------------------------------------------------------------
    methods (Access = protected)
        function out = stepImpl(plugin,in)
            %-------------------Get necessary parameters-------------------
            fs = getSampleRate(plugin);
            
            %-------------------Update filter parameters-------------------
            if plugin.updateRootFilter1
                buildRootFilter1(plugin,fs);
            end
            if plugin.updateRootFilter2
                buildRootFilter2(plugin, fs);
            end
            if plugin.updateRootFilter3
                buildRootFilter3(plugin, fs);
            end
            %TEST
            if plugin.updateRootFilter4
                buildRootFilter4(plugin, fs);
            end
            if plugin.updateRootFilter5
                buildRootFilter5(plugin, fs);
            end
            if plugin.updateRootFilter6
                buildRootFilter6(plugin, fs);
            end
            if plugin.updateRootFilter7
                buildRootFilter7(plugin, fs);
            end
            if plugin.updateRootFilter8
                buildRootFilter8(plugin, fs);
            end
            if plugin.updateRootFilter9
                buildRootFilter9(plugin, fs);
            end
            
            % update plugin.B and plugin.A coefficient matrices for
            % visualization
            updateFilterCoefficientsMatrix(plugin);
            
            %------------------------Process audio-------------------------
            %TODO: Implement universal gain
            %TODO: Do I want pre-filter gain or just post-filter gain?
            %in = 10.^(plugin.inputGain/20) * in;
            
            % Root note filters
            %TODO: convert these to functions
            if plugin.rootFiltersActive
                [in, plugin.rootPrevState1] = filter(plugin.rootCoeffb1,...
                    plugin.rootCoeffa1, in, plugin.rootPrevState1);
                [in, plugin.rootPrevState2] = filter(plugin.rootCoeffb2,...
                    plugin.rootCoeffa2, in, plugin.rootPrevState2);
                [in, plugin.rootPrevState3] = filter(plugin.rootCoeffb3,...
                    plugin.rootCoeffa3, in, plugin.rootPrevState3);
                [in, plugin.rootPrevState4] = filter(plugin.rootCoeffb4,...
                    plugin.rootCoeffa4, in, plugin.rootPrevState4);
                [in, plugin.rootPrevState5] = filter(plugin.rootCoeffb5,...
                    plugin.rootCoeffa5, in, plugin.rootPrevState5);
                [in, plugin.rootPrevState6] = filter(plugin.rootCoeffb6,...
                    plugin.rootCoeffa6, in, plugin.rootPrevState6);
                [in, plugin.rootPrevState7] = filter(plugin.rootCoeffb7,...
                    plugin.rootCoeffa7, in, plugin.rootPrevState7);
                [in, plugin.rootPrevState8] = filter(plugin.rootCoeffb8,...
                    plugin.rootCoeffa8, in, plugin.rootPrevState8);
                [in, plugin.rootPrevState9] = filter(plugin.rootCoeffb9,...
                    plugin.rootCoeffa9, in, plugin.rootPrevState9);
            end
            
            %TODO: output gain?
            %out = 10.^(plugin.outputGain/20) * in);
            out = in;
            
            %TODO: updating visualizer too often? Really only need to
            %update it if the values change. Can track those.
            if ~isempty(plugin.visualizerObject)
                updateVisualizer(plugin);
            end
        end
        
        function setupImpl(plugin,~)
            fs = getSampleRate(plugin);
            
            % Initialize filters
            %TODO: Putting the if statement here allows for only
            %initializing these if the plugin settings has the filters
            %active
            if plugin.rootFiltersActive
                buildRootFilter1(plugin, fs);
                buildRootFilter2(plugin, fs);
                buildRootFilter3(plugin, fs);
                buildRootFilter4(plugin, fs);
                buildRootFilter5(plugin, fs);
                buildRootFilter6(plugin, fs);
                buildRootFilter7(plugin, fs);
                buildRootFilter8(plugin, fs);
                buildRootFilter9(plugin, fs);
            end
            
        end
        
        function resetImpl(~)
            %TODO: resetFilters / resetAllFilters / resetRootFilters /
            %resetThirdFilters / resetFifthFilters / resetSeventhFilters
            
        end
        
    end
    
    %----------------------------------------------------------------------
    % PUBLIC METHODS
    %----------------------------------------------------------------------
    methods
        
        function plugin = HarmonEQ()
            plugin.B = [1 0 0];
            plugin.A = [0 0 1];
        end
        
        function Visualizer(plugin)
            if isempty(plugin.visualizerObject)
                fs = getSampleRate(plugin);
                % TODO: design filters...
                plugin.visualizerObject = dsp.DynamicFilterVisualizer(...
                    512, fs, [20 20e3],...
                    'XScale','Log',...
                    'YLimits',[-20 20],...
                    'Title','HarmonEQ');
            else
                if ~isVisible(plugin.visualizerObject)
                    show(plugin.visualizerObject);
                end
            end
            
            % Step the visual object with the filter
            step(plugin.visualizerObject, plugin.B, plugin.A);
        end
        
        
        %------------------------------------------------------------------
        % SETTERS
        %------------------------------------------------------------------
        function set.rootNote(plugin,val)
            validatestring(val, {'off','A','A# / Bb','B','C','C# / Db',...
                'D','D# / Eb','E','F','F# / Gb','G','G# / Ab'},...
                'set.rootNote', 'RootName');
            % This if statement will throw an error if using single quotes
            % 'off' instead of double quotes "off". Seems to have something
            % to do with type... This is true in the other instances as
            % well.
            if val == "off"
                plugin.rootNote = val;
                plugin.rootFiltersActive = false;
                %TODO: If no root, deactivate all other peaks. This is
                %really for down the road...
                plugin.thirdFiltersActive = false;
                plugin.fifthFiltersActive = false;
                plugin.seventhFiltersActive = false;
            else
                plugin.rootNote = val;
                plugin.rootFiltersActive = true;
            end
            updateRootFilters(plugin);
            %plugin.updateThird1 = true;
            %TODO: This is for later...
%             if plugin.thirdFiltersStatus
%                 updateThirdFilters(plugin);
%             end
            updateRootFrequencies(plugin,val);
            %todo: Necessary for state change control of visualizer:
            %plugin.stateChange = true;
            disp(val);
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
            disp(b);
            disp(a);
        end
        
        
        
        %-----------------------------Builders-----------------------------
        function buildRootFilter1(plugin, fs)
            [plugin.rootCoeffb1, plugin.rootCoeffa1] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.rootFrequency1,...
                plugin.rootQFactor1,...
                plugin.rootGain1);
            plugin.updateRootFilter1 = false;
        end
        
        function buildRootFilter2(plugin, fs)
            [plugin.rootCoeffb2, plugin.rootCoeffa2] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.rootFrequency2,...
                plugin.rootQFactor2,...
                plugin.rootGain2);
            plugin.updateRootFilter2 = false;
        end
        
        function buildRootFilter3(plugin, fs)
            [plugin.rootCoeffb3, plugin.rootCoeffa3] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.rootFrequency3,...
                plugin.rootQFactor3,...
                plugin.rootGain3);
            plugin.updateRootFilter3 = false;
        end
        
        function buildRootFilter4(plugin, fs)
            [plugin.rootCoeffb4, plugin.rootCoeffa4] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.rootFrequency4,...
                plugin.rootQFactor4,...
                plugin.rootGain4);
            plugin.updateRootFilter4 = false;
        end
        
        function buildRootFilter5(plugin, fs)
            [plugin.rootCoeffb5, plugin.rootCoeffa5] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.rootFrequency5,...
                plugin.rootQFactor5,...
                plugin.rootGain5);
            plugin.updateRootFilter5 = false;
        end
        
        function buildRootFilter6(plugin, fs)
            [plugin.rootCoeffb6, plugin.rootCoeffa6] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.rootFrequency6,...
                plugin.rootQFactor6,...
                plugin.rootGain6);
            plugin.updateRootFilter6 = false;
        end
        
        function buildRootFilter7(plugin, fs)
            [plugin.rootCoeffb7, plugin.rootCoeffa7] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.rootFrequency7,...
                plugin.rootQFactor7,...
                plugin.rootGain7);
            plugin.updateRootFilter7 = false;
        end
        
        function buildRootFilter8(plugin, fs)
            [plugin.rootCoeffb8, plugin.rootCoeffa8] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.rootFrequency8,...
                plugin.rootQFactor8,...
                plugin.rootGain8);
            plugin.updateRootFilter8 = false;
        end
        
        function buildRootFilter9(plugin, fs)
            [plugin.rootCoeffb9, plugin.rootCoeffa9] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.rootFrequency9,...
                plugin.rootQFactor9,...
                plugin.rootGain9);
            plugin.updateRootFilter9 = false;
        end
        
        
        
        %-----------------------------Updaters-----------------------------
        function updateRootFrequencies(plugin, val)
            switch val %TODO: Eventually create a getBaseFreq function for this...
                case "off"
                case 'A'
                    rootFreq = 55;
                case 'A# / Bb'
                    rootFreq = 58.27047;
                case 'B'
                    rootFreq = 61.73541;
                case 'C'
                    rootFreq = 32.70320;
                case 'C# / Db'
                    rootFreq = 34.64783;
                case 'D'
                    rootFreq = 36.70810;
                case 'D# / Eb'
                    rootFreq = 38.89087;
                case 'E'
                    rootFreq = 41.20344;
                case 'F'
                    rootFreq = 43.65353;
                case 'F# / Gb'
                    rootFreq = 46.24930;
                case 'G'
                    rootFreq = 48.99943;
                case 'G# / Ab'
                    rootFreq = 51.91309;
            end
            
            if val ~= "off"
                plugin.rootFrequency1 = rootFreq;
                plugin.rootFrequency2 = 2 * rootFreq;
                plugin.rootFrequency3 = 4 * rootFreq;
                plugin.rootFrequency4 = 8 * rootFreq;
                plugin.rootFrequency5 = 16 * rootFreq;
                plugin.rootFrequency6 = 32 * rootFreq;
                plugin.rootFrequency7 = 64 * rootFreq;
                plugin.rootFrequency8 = 128 * rootFreq;
                plugin.rootFrequency9 = 256 * rootFreq;
            end
            
            %TEST
            disp(plugin.rootFrequency1);
        end
        
        function updateRootFilters(plugin)
            plugin.updateRootFilter1 = true;
            plugin.updateRootFilter2 = true;
            plugin.updateRootFilter3 = true;
            plugin.updateRootFilter4 = true;
            plugin.updateRootFilter5 = true;
            plugin.updateRootFilter6 = true;
            plugin.updateRootFilter7 = true;
            plugin.updateRootFilter8 = true;
            plugin.updateRootFilter9 = true;
            plugin.stateChange = true;
        end
        
        function updateFilterCoefficientsMatrix(plugin)
            %TEST
            % If root filters are active, then add their coefficients to
            % the coefficient matrices
            if plugin.rootFiltersActive
                plugin.B = [plugin.rootCoeffb1;...
                    plugin.rootCoeffb2;...
                    plugin.rootCoeffb3;...
                    plugin.rootCoeffb4;...
                    plugin.rootCoeffb5;...
                    plugin.rootCoeffb6;...
                    plugin.rootCoeffb7;...
                    plugin.rootCoeffb8;...
                    plugin.rootCoeffb9];
                plugin.A = [plugin.rootCoeffa1;...
                    plugin.rootCoeffa2;...
                    plugin.rootCoeffa3;...
                    plugin.rootCoeffa4;...
                    plugin.rootCoeffa5;...
                    plugin.rootCoeffa6;...
                    plugin.rootCoeffa7;...
                    plugin.rootCoeffa8;...
                    plugin.rootCoeffa9];
            else
                % If not, set to an allpass filter
                % TODO: This should just be for visualization, in the
                % proessing the plugin should just adjust the gain if
                % necessary and then pass through the input
                plugin.B = [1 0 0];
                plugin.A = [0 0 1];
            end
        end
        
        function updateVisualizer(plugin)
            if ~isempty(plugin.visualizerObject)
                step(plugin.visualizerObject,...
                    plugin.B, plugin.A);
                plugin.visualizerObject.SampleRate = plugin.getSampleRate;
            end
            %TODO: Test this method of minimizing updates to the visualizer
            %plugin.stateChange = false;
        end
        
    end
    
    
end















