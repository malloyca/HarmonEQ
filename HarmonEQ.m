classdef HarmonEQ < matlab.System & audioPlugin
% HarmonEQ.m
% Harmonic Equalizer plugin
% Last updated: 31 March 2021
%
% This is a new test version for HarmonEQ to rebuild it froms scratch. I'm
% finding using the Matlab example plugin as a base overwhelming due to
% there being so much stuff that I don't understand. I want to start with
% something very basic that hopefully I can understand.
%
% To run this with the visualizer in Matlab, run these commands:
% eq = HarmonEQ;
% Visualizer(eq);
% audioTestBench(eq);


% TODO:
% - Look into State-variable filters vs biquads
%

    %----------------------------------------------------------------------
    % TUNABLE PROPERTIES
    %----------------------------------------------------------------------
    properties
        rootNote = 'C';
        rootNoteValue = 0;
        rootGain = 0;
        rootQFactor = 26;
        
        thirdInterval = 'off';
        thirdIntervalDistance = 4;
        thirdNote = 'E';
        thirdGain = 0;
        thirdQFactor = 26;
        
        fifthInterval = 'off';
        fifthIntervalDistance = 7;
        fifthNote = 'G';
        fifthGain = 0;
        fifthQFactor = 26;
        
        seventhInterval = 'off';
        seventhIntervalDistance = 11;
        seventhNote = 'B';
        seventhGain = 0;
        seventhQFactor = 26;
        
        lowRegionGain = 0;
        lowRegionQFactor = 26;
        
                
    end
    
    
    properties
        %--------------------------Harmonic root---------------------------
        % Center frequencies for root bands
        rootFrequency1 = 32.70320;
        rootFrequency2 = 2 * 32.70320;
        rootFrequency3 = 4 * 32.70320;
        rootFrequency4 = 8 * 32.70320;
        rootFrequency5 = 16 * 32.70320;
        rootFrequency6 = 32 * 32.70320;
        rootFrequency7 = 64 * 32.70320;
        rootFrequency8 = 128 * 32.70320;
        rootFrequency9 = 256 * 32.70320;
        
        % Q factors for root bands
        rootQFactor1 = 26;
        rootQFactor2 = 26;
        rootQFactor3 = 26;
        rootQFactor4 = 26;
        rootQFactor5 = 26;
        rootQFactor6 = 26;
        rootQFactor7 = 26;
        rootQFactor8 = 26;
        rootQFactor9 = 26;
        
        % Gain for root bands (dB)
        rootGain1 = 0;
        rootGain2 = 0;
        rootGain3 = 0;
        rootGain4 = 0;
        rootGain5 = 0;
        rootGain6 = 0;
        rootGain7 = 0;
        rootGain8 = 0;
        rootGain9 = 0;
        
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
        
        %-------------------------Harmonic Third---------------------------
        % Center frequencies for harmonic third bands
        thirdFrequency1 = 41.20344;
        thirdFrequency2 = 2 * 41.20344;
        thirdFrequency3 = 4 * 41.20344;
        thirdFrequency4 = 8 * 41.20344;
        thirdFrequency5 = 16 * 41.20344;
        thirdFrequency6 = 32 * 41.20344;
        thirdFrequency7 = 64 * 41.20344;
        thirdFrequency8 = 128 * 41.20344;
        thirdFrequency9 = 256 * 41.20344;
        
        % Q factors for third bands
        thirdQFactor1 = 26;
        thirdQFactor2 = 26;
        thirdQFactor3 = 26;
        thirdQFactor4 = 26;
        thirdQFactor5 = 26;
        thirdQFactor6 = 26;
        thirdQFactor7 = 26;
        thirdQFactor8 = 26;
        thirdQFactor9 = 26;
        
        % Gain for third bands (dB)
        thirdGain1 = 0;
        thirdGain2 = 0;
        thirdGain3 = 0;
        thirdGain4 = 0;
        thirdGain5 = 0;
        thirdGain6 = 0;
        thirdGain7 = 0;
        thirdGain8 = 0;
        thirdGain9 = 0;
        
        % Update status variables for third filters
        updateThirdFilter1 = false;
        updateThirdFilter2 = false;
        updateThirdFilter3 = false;
        updateThirdFilter4 = false;
        updateThirdFilter5 = false;
        updateThirdFilter6 = false;
        updateThirdFilter7 = false;
        updateThirdFilter8 = false;
        updateThirdFilter9 = false;
        
        
        %-------------------------Harmonic Fifth---------------------------
        % Center frequencies for harmonic fifth bands
        fifthFrequency1 = 48.99943;
        fifthFrequency2 = 2 * 48.99943;
        fifthFrequency3 = 4 * 48.99943;
        fifthFrequency4 = 8 * 48.99943;
        fifthFrequency5 = 16 * 48.99943;
        fifthFrequency6 = 32 * 48.99943;
        fifthFrequency7 = 64 * 48.99943;
        fifthFrequency8 = 128 * 48.99943;
        fifthFrequency9 = 256 * 48.99943;
        
        % Q factors for fifth bands
        fifthQFactor1 = 26;
        fifthQFactor2 = 26;
        fifthQFactor3 = 26;
        fifthQFactor4 = 26;
        fifthQFactor5 = 26;
        fifthQFactor6 = 26;
        fifthQFactor7 = 26;
        fifthQFactor8 = 26;
        fifthQFactor9 = 26;
        
        % Gain for fifth bands (dB)
        fifthGain1 = 0;
        fifthGain2 = 0;
        fifthGain3 = 0;
        fifthGain4 = 0;
        fifthGain5 = 0;
        fifthGain6 = 0;
        fifthGain7 = 0;
        fifthGain8 = 0;
        fifthGain9 = 0;
        
        % Update status variables for fifth filters
        updateFifthFilter1 = false;
        updateFifthFilter2 = false;
        updateFifthFilter3 = false;
        updateFifthFilter4 = false;
        updateFifthFilter5 = false;
        updateFifthFilter6 = false;
        updateFifthFilter7 = false;
        updateFifthFilter8 = false;
        updateFifthFilter9 = false;
        
        
        %------------------------Harmonic Seventh--------------------------
        % Center frequencies for harmonic seventh bands
        seventhFrequency1 = 61.73541;
        seventhFrequency2 = 2 * 61.73541;
        seventhFrequency3 = 4 * 61.73541;
        seventhFrequency4 = 8 * 61.73541;
        seventhFrequency5 = 16 * 61.73541;
        seventhFrequency6 = 32 * 61.73541;
        seventhFrequency7 = 64 * 61.73541;
        seventhFrequency8 = 128 * 61.73541;
        seventhFrequency9 = 256 * 61.73541;
        
        % Q factors for seventh bands
        seventhQFactor1 = 26;
        seventhQFactor2 = 26;
        seventhQFactor3 = 26;
        seventhQFactor4 = 26;
        seventhQFactor5 = 26;
        seventhQFactor6 = 26;
        seventhQFactor7 = 26;
        seventhQFactor8 = 26;
        seventhQFactor9 = 26;
        
        % Gain for seventh bands (dB)
        seventhGain1 = 0;
        seventhGain2 = 0;
        seventhGain3 = 0;
        seventhGain4 = 0;
        seventhGain5 = 0;
        seventhGain6 = 0;
        seventhGain7 = 0;
        seventhGain8 = 0;
        seventhGain9 = 0;
        
        % Update status variables for seventh filters
        updateSeventhFilter1 = false;
        updateSeventhFilter2 = false;
        updateSeventhFilter3 = false;
        updateSeventhFilter4 = false;
        updateSeventhFilter5 = false;
        updateSeventhFilter6 = false;
        updateSeventhFilter7 = false;
        updateSeventhFilter8 = false;
        updateSeventhFilter9 = false;
        
        
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
            'D# / Eb','E','F','F# / Gb','G','G# / Ab'}),...
            audioPluginParameter('rootGain',...
            'DisplayName','Root Note Gain',...
            'Mapping',{'lin',-15,15}),...
            audioPluginParameter('rootQFactor',...
            'DisplayName','Root Q Factor',...
            'Mapping',{'pow', 2, 0.5, 100}),...
            ...
            audioPluginParameter('thirdInterval',...
            'DisplayName','Harmonic Third Interval',...
            'Mapping',{'enum','off','Sus2','Min3','Maj3','Sus4'}),...
            audioPluginParameter('thirdGain',...
            'DisplayName','Harmonic Third Gain',...
            'Mapping',{'lin',-15,15}),...
            audioPluginParameter('thirdQFactor',...
            'DisplayName','Harmonic Third Q Factor',...
            'Mapping',{'pow', 2, 0.5, 100}),...
            ...
            audioPluginParameter('fifthInterval',...
            'DisplayName','Harmonic Fifth Interval',...
            'Mapping',{'enum','off','Dim5','Perf5','Aug5'}),...
            audioPluginParameter('fifthGain',...
            'DisplayName','Harmonic Fifth Gain',...
            'Mapping',{'lin',-15,15}),...
            audioPluginParameter('fifthQFactor',...
            'DisplayName','Harmonic Fifth Q Factor',...
            'Mapping',{'pow', 2, 0.5, 100}),...
            ...
            audioPluginParameter('seventhInterval',...
            'DisplayName','Harmonic Seventh Interval',...
            'Mapping',{'enum','off','Dim7','Min7','Maj7'}),...
            audioPluginParameter('seventhGain',...
            'DisplayName','Harmonic Seventh Gain',...
            'Mapping',{'lin',-15,15}),...
            audioPluginParameter('seventhQFactor',...
            'DisplayName','Harmonic Seventh Q Factor',...
            'Mapping',{'pow', 2, 0.5, 100}),...
            ...
            audioPluginParameter('lowRegionGain',...
            'DisplayName','Low Region Gain',...
            'Mapping',{'lin',-15,15}),...
            audioPluginParameter('lowRegionQFactor',...
            'DisplayName','Low Region Q Factor',...
            'Mapping',{'pow', 2, 0.5, 100})...
            );
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
        
        %----------------------Root band coefficients----------------------
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
        
        
        %----------------Harmonic third band coefficients------------------
        thirdCoeffb1;
        thirdCoeffa1;
        thirdPrevState1 = zeros(2);
        thirdCoeffb2;
        thirdCoeffa2;
        thirdPrevState2 = zeros(2);
        thirdCoeffb3;
        thirdCoeffa3;
        thirdPrevState3 = zeros(2);
        thirdCoeffb4;
        thirdCoeffa4;
        thirdPrevState4 = zeros(2);
        thirdCoeffb5;
        thirdCoeffa5;
        thirdPrevState5 = zeros(2);
        thirdCoeffb6;
        thirdCoeffa6;
        thirdPrevState6 = zeros(2);
        thirdCoeffb7;
        thirdCoeffa7;
        thirdPrevState7 = zeros(2);
        thirdCoeffb8;
        thirdCoeffa8;
        thirdPrevState8 = zeros(2);
        thirdCoeffb9;
        thirdCoeffa9;
        thirdPrevState9 = zeros(2);
        
        
        %----------------Harmonic fifth band coefficients------------------
        fifthCoeffb1;
        fifthCoeffa1;
        fifthPrevState1 = zeros(2);
        fifthCoeffb2;
        fifthCoeffa2;
        fifthPrevState2 = zeros(2);
        fifthCoeffb3;
        fifthCoeffa3;
        fifthPrevState3 = zeros(2);
        fifthCoeffb4;
        fifthCoeffa4;
        fifthPrevState4 = zeros(2);
        fifthCoeffb5;
        fifthCoeffa5;
        fifthPrevState5 = zeros(2);
        fifthCoeffb6;
        fifthCoeffa6;
        fifthPrevState6 = zeros(2);
        fifthCoeffb7;
        fifthCoeffa7;
        fifthPrevState7 = zeros(2);
        fifthCoeffb8;
        fifthCoeffa8;
        fifthPrevState8 = zeros(2);
        fifthCoeffb9;
        fifthCoeffa9;
        fifthPrevState9 = zeros(2);
        
        
        
        %----------------Harmonic seventh band coefficients------------------
        seventhCoeffb1;
        seventhCoeffa1;
        seventhPrevState1 = zeros(2);
        seventhCoeffb2;
        seventhCoeffa2;
        seventhPrevState2 = zeros(2);
        seventhCoeffb3;
        seventhCoeffa3;
        seventhPrevState3 = zeros(2);
        seventhCoeffb4;
        seventhCoeffa4;
        seventhPrevState4 = zeros(2);
        seventhCoeffb5;
        seventhCoeffa5;
        seventhPrevState5 = zeros(2);
        seventhCoeffb6;
        seventhCoeffa6;
        seventhPrevState6 = zeros(2);
        seventhCoeffb7;
        seventhCoeffa7;
        seventhPrevState7 = zeros(2);
        seventhCoeffb8;
        seventhCoeffa8;
        seventhPrevState8 = zeros(2);
        seventhCoeffb9;
        seventhCoeffa9;
        seventhPrevState9 = zeros(2);
        
        
        
        % Active state variables
        rootFiltersActive = true;
        thirdFiltersActive = false;
        fifthFiltersActive = false;
        seventhFiltersActive = true;
        
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
            %-----Update root filters
            if plugin.updateRootFilter1
                buildRootFilter1(plugin,fs);
            end
            if plugin.updateRootFilter2
                buildRootFilter2(plugin, fs);
            end
            if plugin.updateRootFilter3
                buildRootFilter3(plugin, fs);
            end
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
            %-----Update harmonic third filters
            if plugin.updateThirdFilter1
                buildThirdFilter1(plugin,fs);
            end
            if plugin.updateThirdFilter2
                buildThirdFilter2(plugin, fs);
            end
            if plugin.updateThirdFilter3
                buildThirdFilter3(plugin, fs);
            end
            if plugin.updateThirdFilter4
                buildThirdFilter4(plugin, fs);
            end
            if plugin.updateThirdFilter5
                buildThirdFilter5(plugin, fs);
            end
            if plugin.updateThirdFilter6
                buildThirdFilter6(plugin, fs);
            end
            if plugin.updateThirdFilter7
                buildThirdFilter7(plugin, fs);
            end
            if plugin.updateThirdFilter8
                buildThirdFilter8(plugin, fs);
            end
            if plugin.updateThirdFilter9
                buildThirdFilter9(plugin, fs);
            end
            %-----Update harmonic fifth filters
            if plugin.updateFifthFilter1
                buildFifthFilter1(plugin,fs);
            end
            if plugin.updateFifthFilter2
                buildFifthFilter2(plugin, fs);
            end
            if plugin.updateFifthFilter3
                buildFifthFilter3(plugin, fs);
            end
            if plugin.updateFifthFilter4
                buildFifthFilter4(plugin, fs);
            end
            if plugin.updateFifthFilter5
                buildFifthFilter5(plugin, fs);
            end
            if plugin.updateFifthFilter6
                buildFifthFilter6(plugin, fs);
            end
            if plugin.updateFifthFilter7
                buildFifthFilter7(plugin, fs);
            end
            if plugin.updateFifthFilter8
                buildFifthFilter8(plugin, fs);
            end
            if plugin.updateFifthFilter9
                buildFifthFilter9(plugin, fs);
            end
            %-----Update harmonic seventh filters
            if plugin.updateSeventhFilter1
                buildSeventhFilter1(plugin,fs);
            end
            if plugin.updateSeventhFilter2
                buildSeventhFilter2(plugin, fs);
            end
            if plugin.updateSeventhFilter3
                buildSeventhFilter3(plugin, fs);
            end
            if plugin.updateSeventhFilter4
                buildSeventhFilter4(plugin, fs);
            end
            if plugin.updateSeventhFilter5
                buildSeventhFilter5(plugin, fs);
            end
            if plugin.updateSeventhFilter6
                buildSeventhFilter6(plugin, fs);
            end
            if plugin.updateSeventhFilter7
                buildSeventhFilter7(plugin, fs);
            end
            if plugin.updateSeventhFilter8
                buildSeventhFilter8(plugin, fs);
            end
            if plugin.updateSeventhFilter9
                buildSeventhFilter9(plugin, fs);
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
            
            if plugin.thirdFiltersActive
                [in, plugin.thirdPrevState1] = filter(plugin.thirdCoeffb1,...
                    plugin.thirdCoeffa1, in, plugin.thirdPrevState1);
                [in, plugin.thirdPrevState2] = filter(plugin.thirdCoeffb2,...
                    plugin.thirdCoeffa2, in, plugin.thirdPrevState2);
                [in, plugin.thirdPrevState3] = filter(plugin.thirdCoeffb3,...
                    plugin.thirdCoeffa3, in, plugin.thirdPrevState3);
                [in, plugin.thirdPrevState4] = filter(plugin.thirdCoeffb4,...
                    plugin.thirdCoeffa4, in, plugin.thirdPrevState4);
                [in, plugin.thirdPrevState5] = filter(plugin.thirdCoeffb5,...
                    plugin.thirdCoeffa5, in, plugin.thirdPrevState5);
                [in, plugin.thirdPrevState6] = filter(plugin.thirdCoeffb6,...
                    plugin.thirdCoeffa6, in, plugin.thirdPrevState6);
                [in, plugin.thirdPrevState7] = filter(plugin.thirdCoeffb7,...
                    plugin.thirdCoeffa7, in, plugin.thirdPrevState7);
                [in, plugin.thirdPrevState8] = filter(plugin.thirdCoeffb8,...
                    plugin.thirdCoeffa8, in, plugin.thirdPrevState8);
                [in, plugin.thirdPrevState9] = filter(plugin.thirdCoeffb9,...
                    plugin.thirdCoeffa9, in, plugin.thirdPrevState9);
            end
            
            if plugin.fifthFiltersActive
                [in, plugin.fifthPrevState1] = filter(plugin.fifthCoeffb1,...
                    plugin.fifthCoeffa1, in, plugin.fifthPrevState1);
                [in, plugin.fifthPrevState2] = filter(plugin.fifthCoeffb2,...
                    plugin.fifthCoeffa2, in, plugin.fifthPrevState2);
                [in, plugin.fifthPrevState3] = filter(plugin.fifthCoeffb3,...
                    plugin.fifthCoeffa3, in, plugin.fifthPrevState3);
                [in, plugin.fifthPrevState4] = filter(plugin.fifthCoeffb4,...
                    plugin.fifthCoeffa4, in, plugin.fifthPrevState4);
                [in, plugin.fifthPrevState5] = filter(plugin.fifthCoeffb5,...
                    plugin.fifthCoeffa5, in, plugin.fifthPrevState5);
                [in, plugin.fifthPrevState6] = filter(plugin.fifthCoeffb6,...
                    plugin.fifthCoeffa6, in, plugin.fifthPrevState6);
                [in, plugin.fifthPrevState7] = filter(plugin.fifthCoeffb7,...
                    plugin.fifthCoeffa7, in, plugin.fifthPrevState7);
                [in, plugin.fifthPrevState8] = filter(plugin.fifthCoeffb8,...
                    plugin.fifthCoeffa8, in, plugin.fifthPrevState8);
                [in, plugin.fifthPrevState9] = filter(plugin.fifthCoeffb9,...
                    plugin.fifthCoeffa9, in, plugin.fifthPrevState9);
            end
            
            if plugin.seventhFiltersActive
                [in, plugin.seventhPrevState1] = filter(plugin.seventhCoeffb1,...
                    plugin.seventhCoeffa1, in, plugin.seventhPrevState1);
                [in, plugin.seventhPrevState2] = filter(plugin.seventhCoeffb2,...
                    plugin.seventhCoeffa2, in, plugin.seventhPrevState2);
                [in, plugin.seventhPrevState3] = filter(plugin.seventhCoeffb3,...
                    plugin.seventhCoeffa3, in, plugin.seventhPrevState3);
                [in, plugin.seventhPrevState4] = filter(plugin.seventhCoeffb4,...
                    plugin.seventhCoeffa4, in, plugin.seventhPrevState4);
                [in, plugin.seventhPrevState5] = filter(plugin.seventhCoeffb5,...
                    plugin.seventhCoeffa5, in, plugin.seventhPrevState5);
                [in, plugin.seventhPrevState6] = filter(plugin.seventhCoeffb6,...
                    plugin.seventhCoeffa6, in, plugin.seventhPrevState6);
                [in, plugin.seventhPrevState7] = filter(plugin.seventhCoeffb7,...
                    plugin.seventhCoeffa7, in, plugin.seventhPrevState7);
                [in, plugin.seventhPrevState8] = filter(plugin.seventhCoeffb8,...
                    plugin.seventhCoeffa8, in, plugin.seventhPrevState8);
                [in, plugin.seventhPrevState9] = filter(plugin.seventhCoeffb9,...
                    plugin.seventhCoeffa9, in, plugin.seventhPrevState9);
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
            
            if plugin.thirdFiltersActive
                buildThirdFilter1(plugin, fs);
                buildThirdFilter2(plugin, fs);
                buildThirdFilter3(plugin, fs);
                buildThirdFilter4(plugin, fs);
                buildThirdFilter5(plugin, fs);
                buildThirdFilter6(plugin, fs);
                buildThirdFilter7(plugin, fs);
                buildThirdFilter8(plugin, fs);
                buildThirdFilter9(plugin, fs);
            end
            
            if plugin.fifthFiltersActive
                buildFifthFilter1(plugin, fs);
                buildFifthFilter2(plugin, fs);
                buildFifthFilter3(plugin, fs);
                buildFifthFilter4(plugin, fs);
                buildFifthFilter5(plugin, fs);
                buildFifthFilter6(plugin, fs);
                buildFifthFilter7(plugin, fs);
                buildFifthFilter8(plugin, fs);
                buildFifthFilter9(plugin, fs);
            end
            
            if plugin.seventhFiltersActive
                buildSeventhFilter1(plugin, fs);
                buildSeventhFilter2(plugin, fs);
                buildSeventhFilter3(plugin, fs);
                buildSeventhFilter4(plugin, fs);
                buildSeventhFilter5(plugin, fs);
                buildSeventhFilter6(plugin, fs);
                buildSeventhFilter7(plugin, fs);
                buildSeventhFilter8(plugin, fs);
                buildSeventhFilter9(plugin, fs);
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
        
        %----------------------------Root note-----------------------------
        function set.rootNote(plugin,val)
            validatestring(val, {'off','A','A# / Bb','B','C','C# / Db',...
                'D','D# / Eb','E','F','F# / Gb','G','G# / Ab'},...
                'set.rootNote', 'RootNote');
            % This if statement will throw an error if using single quotes
            % 'off' instead of double quotes "off". Seems to have something
            % to do with type... This is true in the other instances as
            % well.
            if val == "off"
                plugin.rootNote = val;
                plugin.rootFiltersActive = false;
                %TODO: If no root, deactivate all other peaks. This is
                %really for down the road...
                plugin.thirdInterval = 'off';
                plugin.thirdFiltersActive = false;
                plugin.fifthFiltersActive = false;
                plugin.seventhFiltersActive = false;
            else
                plugin.rootNote = val;
                plugin.rootFiltersActive = true;
            end
            setUpdateRootFilters(plugin);
            setUpdateThirdFilters(plugin);
            setUpdateFifthFilters(plugin); %todo: this is for later...
            setUpdateSeventhFilters(plugin); %todo: this is for later...
            
            updateRootFrequencies(plugin,val);
            updateThirdFrequencies(plugin);
            updateFifthFrequencies(plugin);
            updateSeventhFrequencies(plugin);
            %todo: Necessary for state change control of visualizer:
            plugin.stateChange = true;
        end
        
        function set.rootGain(plugin,val)
            plugin.rootGain = val;
            
            %TODO: This is temporary until I implement range gain controls
            plugin.rootGain1 = val;
            plugin.rootGain2 = val;
            plugin.rootGain3 = val;
            plugin.rootGain4 = val;
            plugin.rootGain5 = val;
            plugin.rootGain6 = val;
            plugin.rootGain7 = val;
            plugin.rootGain8 = val;
            plugin.rootGain9 = val;
            
            setUpdateRootFilters(plugin);
            % for visualization update control
            plugin.stateChange = true;
        end
        
        function set.rootQFactor(plugin,val)
            plugin.rootQFactor = val;
            
            %TODO: This is temporary until I implement controls by range
            plugin.rootQFactor1 = val;
            plugin.rootQFactor2 = val;
            plugin.rootQFactor3 = val;
            plugin.rootQFactor4 = val;
            plugin.rootQFactor5 = val;
            plugin.rootQFactor6 = val;
            plugin.rootQFactor7 = val;
            plugin.rootQFactor8 = val;
            plugin.rootQFactor9 = val;
            
            setUpdateRootFilters(plugin);
            % for visualization update control
            plugin.stateChange = true;
        end
        
        
        %--------------------------Harmonic Third--------------------------
        function set.thirdInterval(plugin,val)
            validatestring(val, {'off','Sus2','Min3','Maj3','Sus4'},...
                'set.thirdInterval','ThirdInterval');
            plugin.thirdInterval = val;
            if val == "off"
                plugin.thirdFiltersActive = false;
            else
                switch val
                    case 'Sus2'
                        plugin.thirdIntervalDistance = 2;
                    case 'Min3'
                        plugin.thirdIntervalDistance = 3;
                    case 'Maj3'
                        plugin.thirdIntervalDistance = 4;
                    case 'Sus4'
                        plugin.thirdIntervalDistance = 5;
                end
                
                %if plugin.rootNoteFiltersActive == true?
                plugin.thirdFiltersActive = true;
                updateThirdFrequencies(plugin);
                setUpdateThirdFilters(plugin);
            end
            
        end
        
        function set.thirdGain(plugin,val)
            plugin.thirdGain = val;
            
            %TODO: This is temporary until I implement range gain controls
            plugin.thirdGain1 = val;
            plugin.thirdGain2 = val;
            plugin.thirdGain3 = val;
            plugin.thirdGain4 = val;
            plugin.thirdGain5 = val;
            plugin.thirdGain6 = val;
            plugin.thirdGain7 = val;
            plugin.thirdGain8 = val;
            plugin.thirdGain9 = val;
            
            setUpdateThirdFilters(plugin);
            % for visualization update control
            plugin.stateChange = true;
        end
        
        function set.thirdQFactor(plugin,val)
            plugin.thirdQFactor = val;
            
            %TODO: This is temporary until I implement controls by range
            plugin.thirdQFactor1 = val;
            plugin.thirdQFactor2 = val;
            plugin.thirdQFactor3 = val;
            plugin.thirdQFactor4 = val;
            plugin.thirdQFactor5 = val;
            plugin.thirdQFactor6 = val;
            plugin.thirdQFactor7 = val;
            plugin.thirdQFactor8 = val;
            plugin.thirdQFactor9 = val;
            
            setUpdateThirdFilters(plugin);
            % for visualization update control
            plugin.stateChange = true;
        end
        
        
        %--------------------------Harmonic Fifth--------------------------
        function set.fifthInterval(plugin,val)
            validatestring(val, {'off','Dim5','Perf5','Aug5'},...
                'set.fifthInterval','FifthInterval');
            plugin.fifthInterval = val;
            if val == "off"
                plugin.fifthFiltersActive = false;
            else
                switch val
                    case 'Dim5'
                        plugin.fifthIntervalDistance = 6;
                    case 'Perf5'
                        plugin.fifthIntervalDistance = 7;
                    case 'Aug5'
                        plugin.fifthIntervalDistance = 8;
                end
                
                %if plugin.rootNoteFiltersActive == true?
                plugin.fifthFiltersActive = true;
                updateFifthFrequencies(plugin);
                setUpdateFifthFilters(plugin);
            end 
        end
        
        function set.fifthGain(plugin,val)
            plugin.fifthGain = val;
            
            %TODO: This is temporary until I implement range gain controls
            plugin.fifthGain1 = val;
            plugin.fifthGain2 = val;
            plugin.fifthGain3 = val;
            plugin.fifthGain4 = val;
            plugin.fifthGain5 = val;
            plugin.fifthGain6 = val;
            plugin.fifthGain7 = val;
            plugin.fifthGain8 = val;
            plugin.fifthGain9 = val;
            
            setUpdateFifthFilters(plugin);
            % for visualization update control
            plugin.stateChange = true;
        end
        
        function set.fifthQFactor(plugin,val)
            plugin.fifthQFactor = val;
            
            %TODO: This is temporary until I implement controls by range
            plugin.fifthQFactor1 = val;
            plugin.fifthQFactor2 = val;
            plugin.fifthQFactor3 = val;
            plugin.fifthQFactor4 = val;
            plugin.fifthQFactor5 = val;
            plugin.fifthQFactor6 = val;
            plugin.fifthQFactor7 = val;
            plugin.fifthQFactor8 = val;
            plugin.fifthQFactor9 = val;
            
            setUpdateFifthFilters(plugin);
            % for visualization update control
            plugin.stateChange = true;
        end
        
        
        %--------------------------Harmonic Seventh--------------------------
        function set.seventhInterval(plugin,val)
            validatestring(val, {'off','Dim7','Min7','Maj7'},...
                'set.seventhInterval','SeventhInterval');
            plugin.seventhInterval = val;
            if val == "off"
                plugin.seventhFiltersActive = false;
            else
                switch val
                    case 'Dim7'
                        plugin.seventhIntervalDistance = 9;
                    case 'Min7'
                        plugin.seventhIntervalDistance = 10;
                    case 'Maj7'
                        plugin.seventhIntervalDistance = 11;
                end
                
                %if plugin.rootNoteFiltersActive == true?
                plugin.seventhFiltersActive = true;
                updateSeventhFrequencies(plugin);
                setUpdateSeventhFilters(plugin);
            end 
        end
        
        function set.seventhGain(plugin,val)
            plugin.seventhGain = val;
            
            %TODO: This is temporary until I implement range gain controls
            plugin.seventhGain1 = val;
            plugin.seventhGain2 = val;
            plugin.seventhGain3 = val;
            plugin.seventhGain4 = val;
            plugin.seventhGain5 = val;
            plugin.seventhGain6 = val;
            plugin.seventhGain7 = val;
            plugin.seventhGain8 = val;
            plugin.seventhGain9 = val;
            
            setUpdateSeventhFilters(plugin);
            % for visualization update control
            plugin.stateChange = true;
        end
        
        function set.seventhQFactor(plugin,val)
            plugin.seventhQFactor = val;
            
            %TODO: This is temporary until I implement controls by range
            plugin.seventhQFactor1 = val;
            plugin.seventhQFactor2 = val;
            plugin.seventhQFactor3 = val;
            plugin.seventhQFactor4 = val;
            plugin.seventhQFactor5 = val;
            plugin.seventhQFactor6 = val;
            plugin.seventhQFactor7 = val;
            plugin.seventhQFactor8 = val;
            plugin.seventhQFactor9 = val;
            
            setUpdateSeventhFilters(plugin);
            % for visualization update control
            plugin.stateChange = true;
        end
        
        
        %------------------------Low Region Controls-----------------------
        function set.lowRegionGain(plugin,val)
            plugin.lowRegionGain = val;
            
            %todo: For now this will only control the first two octaves of
            %filters
            %todo: Create updateLowRegionGain function to handle this
            plugin.rootGain1 = val;
            plugin.rootGain2 = val;
            plugin.thirdGain1 = val;
            plugin.thirdGain2 = val;
            plugin.fifthGain1 = val;
            plugin.fifthGain2 = val;
            plugin.seventhGain1 = val;
            plugin.seventhGain2 = val;
            
            
            plugin.updateRootFilter1 = true;
            plugin.updateRootFilter2 = true;
            plugin.updateThirdFilter1 = true;
            plugin.updateThirdFilter2 = true;
            plugin.updateFifthFilter1 = true;
            plugin.updateFifthFilter2 = true;
            plugin.updateSeventhFilter1 = true;
            plugin.updateSeventhFilter2 = true;
            
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
        
        function buildThirdFilter1(plugin, fs)
            [plugin.thirdCoeffb1, plugin.thirdCoeffa1] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.thirdFrequency1,...
                plugin.thirdQFactor1,...
                plugin.thirdGain1);
            plugin.updateThirdFilter1 = false;
        end
        
        function buildThirdFilter2(plugin, fs)
            [plugin.thirdCoeffb2, plugin.thirdCoeffa2] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.thirdFrequency2,...
                plugin.thirdQFactor2,...
                plugin.thirdGain2);
            plugin.updateThirdFilter2 = false;
        end
        
        function buildThirdFilter3(plugin, fs)
            [plugin.thirdCoeffb3, plugin.thirdCoeffa3] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.thirdFrequency3,...
                plugin.thirdQFactor3,...
                plugin.thirdGain3);
            plugin.updateThirdFilter3 = false;
        end
        
        function buildThirdFilter4(plugin, fs)
            [plugin.thirdCoeffb4, plugin.thirdCoeffa4] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.thirdFrequency4,...
                plugin.thirdQFactor4,...
                plugin.thirdGain4);
            plugin.updateThirdFilter4 = false;
        end
        
        function buildThirdFilter5(plugin, fs)
            [plugin.thirdCoeffb5, plugin.thirdCoeffa5] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.thirdFrequency5,...
                plugin.thirdQFactor5,...
                plugin.thirdGain5);
            plugin.updateThirdFilter5 = false;
        end
        
        function buildThirdFilter6(plugin, fs)
            [plugin.thirdCoeffb6, plugin.thirdCoeffa6] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.thirdFrequency6,...
                plugin.thirdQFactor6,...
                plugin.thirdGain6);
            plugin.updateThirdFilter6 = false;
        end
        
        function buildThirdFilter7(plugin, fs)
            [plugin.thirdCoeffb7, plugin.thirdCoeffa7] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.thirdFrequency7,...
                plugin.thirdQFactor7,...
                plugin.thirdGain7);
            plugin.updateThirdFilter7 = false;
        end
        
        function buildThirdFilter8(plugin, fs)
            [plugin.thirdCoeffb8, plugin.thirdCoeffa8] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.thirdFrequency8,...
                plugin.thirdQFactor8,...
                plugin.thirdGain8);
            plugin.updateThirdFilter8 = false;
        end
        
        function buildThirdFilter9(plugin, fs)
            [plugin.thirdCoeffb9, plugin.thirdCoeffa9] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.thirdFrequency9,...
                plugin.thirdQFactor9,...
                plugin.thirdGain9);
            plugin.updateThirdFilter9 = false;
        end
        
        function buildFifthFilter1(plugin, fs)
            [plugin.fifthCoeffb1, plugin.fifthCoeffa1] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.fifthFrequency1,...
                plugin.fifthQFactor1,...
                plugin.fifthGain1);
            plugin.updateFifthFilter1 = false;
        end
        
        function buildFifthFilter2(plugin, fs)
            [plugin.fifthCoeffb2, plugin.fifthCoeffa2] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.fifthFrequency2,...
                plugin.fifthQFactor2,...
                plugin.fifthGain2);
            plugin.updateFifthFilter2 = false;
        end
        
        function buildFifthFilter3(plugin, fs)
            [plugin.fifthCoeffb3, plugin.fifthCoeffa3] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.fifthFrequency3,...
                plugin.fifthQFactor3,...
                plugin.fifthGain3);
            plugin.updateFifthFilter3 = false;
        end
        
        function buildFifthFilter4(plugin, fs)
            [plugin.fifthCoeffb4, plugin.fifthCoeffa4] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.fifthFrequency4,...
                plugin.fifthQFactor4,...
                plugin.fifthGain4);
            plugin.updateFifthFilter4 = false;
        end
        
        function buildFifthFilter5(plugin, fs)
            [plugin.fifthCoeffb5, plugin.fifthCoeffa5] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.fifthFrequency5,...
                plugin.fifthQFactor5,...
                plugin.fifthGain5);
            plugin.updateFifthFilter5 = false;
        end
        
        function buildFifthFilter6(plugin, fs)
            [plugin.fifthCoeffb6, plugin.fifthCoeffa6] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.fifthFrequency6,...
                plugin.fifthQFactor6,...
                plugin.fifthGain6);
            plugin.updateFifthFilter6 = false;
        end
        
        function buildFifthFilter7(plugin, fs)
            [plugin.fifthCoeffb7, plugin.fifthCoeffa7] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.fifthFrequency7,...
                plugin.fifthQFactor7,...
                plugin.fifthGain7);
            plugin.updateFifthFilter7 = false;
        end
        
        function buildFifthFilter8(plugin, fs)
            [plugin.fifthCoeffb8, plugin.fifthCoeffa8] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.fifthFrequency8,...
                plugin.fifthQFactor8,...
                plugin.fifthGain8);
            plugin.updateFifthFilter8 = false;
        end
        
        function buildFifthFilter9(plugin, fs)
            [plugin.fifthCoeffb9, plugin.fifthCoeffa9] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.fifthFrequency9,...
                plugin.fifthQFactor9,...
                plugin.fifthGain9);
            plugin.updateFifthFilter9 = false;
        end
        
        function buildSeventhFilter1(plugin, fs)
            [plugin.seventhCoeffb1, plugin.seventhCoeffa1] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.seventhFrequency1,...
                plugin.seventhQFactor1,...
                plugin.seventhGain1);
            plugin.updateSeventhFilter1 = false;
        end
        
        function buildSeventhFilter2(plugin, fs)
            [plugin.seventhCoeffb2, plugin.seventhCoeffa2] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.seventhFrequency2,...
                plugin.seventhQFactor2,...
                plugin.seventhGain2);
            plugin.updateSeventhFilter2 = false;
        end
        
        function buildSeventhFilter3(plugin, fs)
            [plugin.seventhCoeffb3, plugin.seventhCoeffa3] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.seventhFrequency3,...
                plugin.seventhQFactor3,...
                plugin.seventhGain3);
            plugin.updateSeventhFilter3 = false;
        end
        
        function buildSeventhFilter4(plugin, fs)
            [plugin.seventhCoeffb4, plugin.seventhCoeffa4] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.seventhFrequency4,...
                plugin.seventhQFactor4,...
                plugin.seventhGain4);
            plugin.updateSeventhFilter4 = false;
        end
        
        function buildSeventhFilter5(plugin, fs)
            [plugin.seventhCoeffb5, plugin.seventhCoeffa5] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.seventhFrequency5,...
                plugin.seventhQFactor5,...
                plugin.seventhGain5);
            plugin.updateSeventhFilter5 = false;
        end
        
        function buildSeventhFilter6(plugin, fs)
            [plugin.seventhCoeffb6, plugin.seventhCoeffa6] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.seventhFrequency6,...
                plugin.seventhQFactor6,...
                plugin.seventhGain6);
            plugin.updateSeventhFilter6 = false;
        end
        
        function buildSeventhFilter7(plugin, fs)
            [plugin.seventhCoeffb7, plugin.seventhCoeffa7] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.seventhFrequency7,...
                plugin.seventhQFactor7,...
                plugin.seventhGain7);
            plugin.updateSeventhFilter7 = false;
        end
        
        function buildSeventhFilter8(plugin, fs)
            [plugin.seventhCoeffb8, plugin.seventhCoeffa8] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.seventhFrequency8,...
                plugin.seventhQFactor8,...
                plugin.seventhGain8);
            plugin.updateSeventhFilter8 = false;
        end
        
        function buildSeventhFilter9(plugin, fs)
            [plugin.seventhCoeffb9, plugin.seventhCoeffa9] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.seventhFrequency9,...
                plugin.seventhQFactor9,...
                plugin.seventhGain9);
            plugin.updateSeventhFilter9 = false;
        end
        
        
        
        %-----------------------------Updaters-----------------------------
        function updateRootFrequencies(plugin, val)
            switch val %TODO: Eventually create a getBaseFreq function for this...
                case "off"
                case 'A'
                    rootFreq = 55;
                    rootNoteNumber = 9;
                case 'A# / Bb'
                    rootFreq = 58.27047;
                    rootNoteNumber = 10;
                case 'B'
                    rootFreq = 61.73541;
                    rootNoteNumber = 11;
                case 'C'
                    rootFreq = 32.70320;
                    rootNoteNumber = 0;
                case 'C# / Db'
                    rootFreq = 34.64783;
                    rootNoteNumber = 1;
                case 'D'
                    rootFreq = 36.70810;
                    rootNoteNumber = 2;
                case 'D# / Eb'
                    rootFreq = 38.89087;
                    rootNoteNumber = 3;
                case 'E'
                    rootFreq = 41.20344;
                    rootNoteNumber = 4;
                case 'F'
                    rootFreq = 43.65353;
                    rootNoteNumber = 5;
                case 'F# / Gb'
                    rootFreq = 46.24930;
                    rootNoteNumber = 6;
                case 'G'
                    rootFreq = 48.99943;
                    rootNoteNumber = 7;
                case 'G# / Ab'
                    rootFreq = 51.91309;
                    rootNoteNumber = 8;
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
                
                plugin.rootNoteValue = rootNoteNumber;
            end
            
        end
        
        function updateThirdFrequencies(plugin)
            %todo: This really need to know the root note and harmonic
            %third interval
            
            thirdNoteNumber = mod(plugin.rootNoteValue + plugin.thirdIntervalDistance, 12);
            
             %TODO: Eventually create a getBaseFreq function for this...
            switch thirdNoteNumber
                case 9
                    thirdFreq = 55;
                case 10
                    thirdFreq = 58.27047;
                case 11
                    thirdFreq = 61.73541;
                case 0
                    thirdFreq = 32.70320;
                case 1
                    thirdFreq = 34.64783;
                case 2
                    thirdFreq = 36.70810;
                case 3
                    thirdFreq = 38.89087;
                case 4
                    thirdFreq = 41.20344;
                case 5
                    thirdFreq = 43.65353;
                case 6
                    thirdFreq = 46.24930;
                case 7
                    thirdFreq = 48.99943;
                case 8
                    thirdFreq = 51.91309;
            end
            
            plugin.thirdFrequency1 = thirdFreq;
            plugin.thirdFrequency2 = 2 * thirdFreq;
            plugin.thirdFrequency3 = 4 * thirdFreq;
            plugin.thirdFrequency4 = 8 * thirdFreq;
            plugin.thirdFrequency5 = 16 * thirdFreq;
            plugin.thirdFrequency6 = 32 * thirdFreq;
            plugin.thirdFrequency7 = 64 * thirdFreq;
            plugin.thirdFrequency8 = 128 * thirdFreq;
            plugin.thirdFrequency9 = 256 * thirdFreq;
            
        end
        
        function updateFifthFrequencies(plugin)
            %todo: This really need to know the root note and harmonic
            %third interval
            
            fifthNoteNumber = mod(plugin.rootNoteValue + plugin.fifthIntervalDistance, 12);
            
             %TODO: Eventually create a getBaseFreq function for this...
            switch fifthNoteNumber
                case 9
                    fifthFreq = 55;
                case 10
                    fifthFreq = 58.27047;
                case 11
                    fifthFreq = 61.73541;
                case 0
                    fifthFreq = 32.70320;
                case 1
                    fifthFreq = 34.64783;
                case 2
                    fifthFreq = 36.70810;
                case 3
                    fifthFreq = 38.89087;
                case 4
                    fifthFreq = 41.20344;
                case 5
                    fifthFreq = 43.65353;
                case 6
                    fifthFreq = 46.24930;
                case 7
                    fifthFreq = 48.99943;
                case 8
                    fifthFreq = 51.91309;
            end
            
            plugin.fifthFrequency1 = fifthFreq;
            plugin.fifthFrequency2 = 2 * fifthFreq;
            plugin.fifthFrequency3 = 4 * fifthFreq;
            plugin.fifthFrequency4 = 8 * fifthFreq;
            plugin.fifthFrequency5 = 16 * fifthFreq;
            plugin.fifthFrequency6 = 32 * fifthFreq;
            plugin.fifthFrequency7 = 64 * fifthFreq;
            plugin.fifthFrequency8 = 128 * fifthFreq;
            plugin.fifthFrequency9 = 256 * fifthFreq;
            
        end
        
        function updateSeventhFrequencies(plugin)
            seventhNoteNumber = mod(plugin.rootNoteValue + plugin.seventhIntervalDistance, 12);
            
             %TODO: Eventually create a getBaseFreq function for this...
            switch seventhNoteNumber
                case 9
                    seventhFreq = 55;
                case 10
                    seventhFreq = 58.27047;
                case 11
                    seventhFreq = 61.73541;
                case 0
                    seventhFreq = 32.70320;
                case 1
                    seventhFreq = 34.64783;
                case 2
                    seventhFreq = 36.70810;
                case 3
                    seventhFreq = 38.89087;
                case 4
                    seventhFreq = 41.20344;
                case 5
                    seventhFreq = 43.65353;
                case 6
                    seventhFreq = 46.24930;
                case 7
                    seventhFreq = 48.99943;
                case 8
                    seventhFreq = 51.91309;
            end
            
            plugin.seventhFrequency1 = seventhFreq;
            plugin.seventhFrequency2 = 2 * seventhFreq;
            plugin.seventhFrequency3 = 4 * seventhFreq;
            plugin.seventhFrequency4 = 8 * seventhFreq;
            plugin.seventhFrequency5 = 16 * seventhFreq;
            plugin.seventhFrequency6 = 32 * seventhFreq;
            plugin.seventhFrequency7 = 64 * seventhFreq;
            plugin.seventhFrequency8 = 128 * seventhFreq;
            plugin.seventhFrequency9 = 256 * seventhFreq;
            
        end
        
        function setUpdateRootFilters(plugin)
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
        
        function setUpdateThirdFilters(plugin)
            plugin.updateThirdFilter1 = true;
            plugin.updateThirdFilter2 = true;
            plugin.updateThirdFilter3 = true;
            plugin.updateThirdFilter4 = true;
            plugin.updateThirdFilter5 = true;
            plugin.updateThirdFilter6 = true;
            plugin.updateThirdFilter7 = true;
            plugin.updateThirdFilter8 = true;
            plugin.updateThirdFilter9 = true;
            plugin.stateChange = true;
        end
        
        function setUpdateFifthFilters(plugin)
            plugin.updateFifthFilter1 = true;
            plugin.updateFifthFilter2 = true;
            plugin.updateFifthFilter3 = true;
            plugin.updateFifthFilter4 = true;
            plugin.updateFifthFilter5 = true;
            plugin.updateFifthFilter6 = true;
            plugin.updateFifthFilter7 = true;
            plugin.updateFifthFilter8 = true;
            plugin.updateFifthFilter9 = true;
            plugin.stateChange = true;
        end
        
        function setUpdateSeventhFilters(plugin)
            plugin.updateSeventhFilter1 = true;
            plugin.updateSeventhFilter2 = true;
            plugin.updateSeventhFilter3 = true;
            plugin.updateSeventhFilter4 = true;
            plugin.updateSeventhFilter5 = true;
            plugin.updateSeventhFilter6 = true;
            plugin.updateSeventhFilter7 = true;
            plugin.updateSeventhFilter8 = true;
            plugin.updateSeventhFilter9 = true;
            plugin.stateChange = true;
        end
        
        function updateFilterCoefficientsMatrix(plugin)
            %TODO
            % If root filters are active, then add their coefficients to
            % the coefficient matrices
            
            if plugin.rootFiltersActive
                B_root = [plugin.rootCoeffb1;...
                    plugin.rootCoeffb2;...
                    plugin.rootCoeffb3;...
                    plugin.rootCoeffb4;...
                    plugin.rootCoeffb5;...
                    plugin.rootCoeffb6;...
                    plugin.rootCoeffb7;...
                    plugin.rootCoeffb8;...
                    plugin.rootCoeffb9];
                A_root = [plugin.rootCoeffa1;...
                    plugin.rootCoeffa2;...
                    plugin.rootCoeffa3;...
                    plugin.rootCoeffa4;...
                    plugin.rootCoeffa5;...
                    plugin.rootCoeffa6;...
                    plugin.rootCoeffa7;...
                    plugin.rootCoeffa8;...
                    plugin.rootCoeffa9];
                
                if plugin.thirdFiltersActive
                    B_third = [plugin.thirdCoeffb1;...
                        plugin.thirdCoeffb2;...
                        plugin.thirdCoeffb3;...
                        plugin.thirdCoeffb4;...
                        plugin.thirdCoeffb5;...
                        plugin.thirdCoeffb6;...
                        plugin.thirdCoeffb7;...
                        plugin.thirdCoeffb8;...
                        plugin.thirdCoeffb9];
                    A_third = [plugin.thirdCoeffa1;...
                        plugin.thirdCoeffa2;...
                        plugin.thirdCoeffa3;...
                        plugin.thirdCoeffa4;...
                        plugin.thirdCoeffa5;...
                        plugin.thirdCoeffa6;...
                        plugin.thirdCoeffa7;...
                        plugin.thirdCoeffa8;...
                        plugin.thirdCoeffa9];
                else
                    B_third = [];
                    A_third = [];
                end
                
                if plugin.fifthFiltersActive
                    B_fifth = [plugin.fifthCoeffb1;...
                        plugin.fifthCoeffb2;...
                        plugin.fifthCoeffb3;...
                        plugin.fifthCoeffb4;...
                        plugin.fifthCoeffb5;...
                        plugin.fifthCoeffb6;...
                        plugin.fifthCoeffb7;...
                        plugin.fifthCoeffb8;...
                        plugin.fifthCoeffb9];
                    A_fifth = [plugin.fifthCoeffa1;...
                        plugin.fifthCoeffa2;...
                        plugin.fifthCoeffa3;...
                        plugin.fifthCoeffa4;...
                        plugin.fifthCoeffa5;...
                        plugin.fifthCoeffa6;...
                        plugin.fifthCoeffa7;...
                        plugin.fifthCoeffa8;...
                        plugin.fifthCoeffa9];
                else
                    B_fifth = [];
                    A_fifth = [];
                end
                
                if plugin.seventhFiltersActive
                    B_seventh = [plugin.seventhCoeffb1;...
                        plugin.seventhCoeffb2;...
                        plugin.seventhCoeffb3;...
                        plugin.seventhCoeffb4;...
                        plugin.seventhCoeffb5;...
                        plugin.seventhCoeffb6;...
                        plugin.seventhCoeffb7;...
                        plugin.seventhCoeffb8;...
                        plugin.seventhCoeffb9];
                    A_seventh = [plugin.seventhCoeffa1;...
                        plugin.seventhCoeffa2;...
                        plugin.seventhCoeffa3;...
                        plugin.seventhCoeffa4;...
                        plugin.seventhCoeffa5;...
                        plugin.seventhCoeffa6;...
                        plugin.seventhCoeffa7;...
                        plugin.seventhCoeffa8;...
                        plugin.seventhCoeffa9];
                else
                    B_seventh = [];
                    A_seventh = [];
                end
                
                plugin.B = [B_root; B_third; B_fifth; B_seventh];
                plugin.A = [A_root; A_third; A_fifth; A_seventh];
                
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















