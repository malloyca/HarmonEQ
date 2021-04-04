classdef HarmonEQ < matlab.System & audioPlugin
% HarmonEQ.m
% Harmonic Equalizer plugin
% v0.2-alpha
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
%
% To validate for generation:
% validateAudioPlugin HarmonEQ;
% To export as a VST, run:
% generateAudioPlugin -outdir plugins HarmonEQ
% To export as an AU (on macOS):
% 


% TODO:
% - Look into State-variable filters vs biquads
%

    %----------------------------------------------------------------------
    % TUNABLE PROPERTIES
    %----------------------------------------------------------------------
    properties
        rootNote = 'C';
        rootNoteValue = 0;
        rootGain = 0; %deprecated
        rootQFactor = 26; %deprecated
        
        thirdInterval = 'off';
        thirdIntervalDistance = 4;
        thirdNote = 'E';
        thirdGain = 0; %deprecated
        thirdQFactor = 26; %deprecated
        
        fifthInterval = 'off';
        fifthIntervalDistance = 7;
        fifthNote = 'G';
        fifthGain = 0; %deprecated
        fifthQFactor = 26; %deprecated
        
        seventhInterval = 'off';
        seventhIntervalDistance = 11;
        seventhNote = 'B';
        seventhGain = 0; %deprecated
        seventhQFactor = 26; %deprecated
        
        %----------
        highRegionGain = 0;
        highRegionQFactor = 26;
        
        highMidRegionGain = 0;
        highMidRegionQFactor = 26;
        
        midRegionGain = 0;
        midRegionQFactor = 26;
        
        lowMidRegionGain = 0;
        lowMidRegionQFactor = 26;
        
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
    
    %TODO: This is currently working, but is ugly. Need to do:
    % - Add more rows so that the drop down menus in the right column
    % aren't so tall
    % - Add extra rows so that there is room for labels
    % - Eventually... Add extra columns for crossover knobs
    
    properties (Constant, Hidden)
        PluginInterface = audioPluginInterface(...
            'InputChannels',2,...
            'OutputChannels',2,...
            'PluginName','HarmonEQ',...
            'VendorVersion','0.2',...
            ... %TEST - Working on implementing new test UI
            audioPluginParameter('rootNote','DisplayName','Root Note',...
            'Mapping',{'enum','off','A','A# / Bb','B','C','C# / Db','D',...
            'D# / Eb','E','F','F# / Gb','G','G# / Ab'},...
            'Style','dropdown',...
            'Layout',[2,6],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('thirdInterval',...
            'DisplayName','Harmonic Third Interval',...
            'Mapping',{'enum','off','Sus2','Min3','Maj3','Sus4'},...
            'Style','dropdown',...
            'Layout',[4,6],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('fifthInterval',...
            'DisplayName','Harmonic Fifth Interval',...
            'Mapping',{'enum','off','Dim5','Perf5','Aug5'},...
            'Style','dropdown',...
            'Layout',[6,6],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('seventhInterval',...
            'DisplayName','Harmonic Seventh Interval',...
            'Mapping',{'enum','off','Dim7','Min7','Maj7'},...
            'Style','dropdown',...
            'Layout',[8,6],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('highRegionGain',...
            'DisplayName','High Gain',...
            'Mapping',{'lin',-15,15},...
            'Style','vslider',...
            'Layout',[2,5;8,5],...
            'DisplayNameLocation','above'),...
            audioPluginParameter('highRegionQFactor',...
            'DisplayName','High Q',...
            'Mapping',{'pow', 2, 0.5, 100},...
            'Style','rotary',...
            'Layout',[10,5],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('highMidRegionGain',...
            'DisplayName','High-Mid Gain',...
            'Mapping',{'lin',-15,15},...
            'Style','vslider',...
            'Layout',[2,4;8,4],...
            'DisplayNameLocation','above'),...
            audioPluginParameter('highMidRegionQFactor',...
            'DisplayName','High-Mid Q',...
            'Mapping',{'pow', 2, 0.5, 100},...
            'Style','rotary',...
            'Layout',[10,4],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('midRegionGain',...
            'DisplayName','Mid Gain',...
            'Mapping',{'lin',-15,15},...
            'Style','vslider',...
            'Layout',[2,3;8,3],...
            'DisplayNameLocation','above'),...
            audioPluginParameter('midRegionQFactor',...
            'DisplayName','Mid Q',...
            'Mapping',{'pow', 2, 0.5, 100},...
            'Style','rotary',...
            'Layout',[10,3],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('lowMidRegionGain',...
            'DisplayName','Low-Mid Gain',...
            'Mapping',{'lin',-15,15},...
            'Style','vslider',...
            'Layout',[2,2;8,2],...
            'DisplayNameLocation','above'),...
            audioPluginParameter('lowMidRegionQFactor',...
            'DisplayName','Low-Mid Q',...
            'Mapping',{'pow', 2, 0.5, 100},...
            'Style','rotary',...
            'Layout',[10,2],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('lowRegionGain',...
            'DisplayName','Low Gain',...
            'Mapping',{'lin',-15,15},...
            'Style','vslider',...
            'Layout',[2,1;8,1],...
            'DisplayNameLocation','above'),...
            audioPluginParameter('lowRegionQFactor',...
            'DisplayName','Low Q',...
            'Mapping',{'pow', 2, 0.5, 100},...
            'Style','rotary',...
            'Layout',[10,1],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginGridLayout(...
            'RowHeight',[25,25,25,25,25,25,25,25,25,100,25],...
            'ColumnWidth',[100,100,100,100,100,150],...
            'RowSpacing',15)...
            );
    end
    
    
    % todo: Delete this once new UI is setup and working satisfactorily
%     audioPluginParameter('rootGain',...
%             'DisplayName','Root Note Gain',...
%             'Mapping',{'lin',-15,15}),...
%             audioPluginParameter('rootQFactor',...
%             'DisplayName','Root Q Factor',...
%             'Mapping',{'pow', 2, 0.5, 100}),...
%             audioPluginParameter('thirdGain',...
%             'DisplayName','Harmonic Third Gain',...
%             'Mapping',{'lin',-15,15}),...
%             audioPluginParameter('thirdQFactor',...
%             'DisplayName','Harmonic Third Q Factor',...
%             'Mapping',{'pow', 2, 0.5, 100}),...
%              audioPluginParameter('fifthGain',...
%             'DisplayName','Harmonic Fifth Gain',...
%             'Mapping',{'lin',-15,15}),...
%             audioPluginParameter('fifthQFactor',...
%             'DisplayName','Harmonic Fifth Q Factor',...
%             'Mapping',{'pow', 2, 0.5, 100}),...
%             audioPluginParameter('seventhGain',...
%             'DisplayName','Harmonic Seventh Gain',...
%             'Mapping',{'lin',-15,15}),...
%             audioPluginParameter('seventhQFactor',...
%             'DisplayName','Harmonic Seventh Q Factor',...
%             'Mapping',{'pow', 2, 0.5, 100}),...
    
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
        seventhFiltersActive = false;
        
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
            %TEST
            if ~isempty(plugin.visualizerObject) && plugin.stateChange
                updateVisualizer(plugin);
            end
        end
        
        function setupImpl(plugin,~)
            fs = getSampleRate(plugin);
            
            %----------------------Initialize filters----------------------
            %-----Root filters
            buildRootFilter1(plugin, fs);
            buildRootFilter2(plugin, fs);
            buildRootFilter3(plugin, fs);
            buildRootFilter4(plugin, fs);
            buildRootFilter5(plugin, fs);
            buildRootFilter6(plugin, fs);
            buildRootFilter7(plugin, fs);
            buildRootFilter8(plugin, fs);
            buildRootFilter9(plugin, fs);
            %-----Harmonic third filters
            buildThirdFilter1(plugin, fs);
            buildThirdFilter2(plugin, fs);
            buildThirdFilter3(plugin, fs);
            buildThirdFilter4(plugin, fs);
            buildThirdFilter5(plugin, fs);
            buildThirdFilter6(plugin, fs);
            buildThirdFilter7(plugin, fs);
            buildThirdFilter8(plugin, fs);
            buildThirdFilter9(plugin, fs);
            %-----Harmonic fifth filters
            buildFifthFilter1(plugin, fs);
            buildFifthFilter2(plugin, fs);
            buildFifthFilter3(plugin, fs);
            buildFifthFilter4(plugin, fs);
            buildFifthFilter5(plugin, fs);
            buildFifthFilter6(plugin, fs);
            buildFifthFilter7(plugin, fs);
            buildFifthFilter8(plugin, fs);
            buildFifthFilter9(plugin, fs);
            %-----Harmonic seventh filters
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
            %Visualizer This is the visualizer function for HarmonEQ. This
            % function only works inside of Matlab. To use this plugin,
            % run:
            % eq = HarmonEQ;
            % Visualizer(eq);
            % AudioTestBench(eq);
            
            if isempty(plugin.visualizerObject)
                fs = getSampleRate(plugin);
                % TODO: design filters...
                plugin.visualizerObject = dsp.DynamicFilterVisualizer(...
                    2048, fs, [20 20e3],...
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
                deactivateRootFilters(plugin);
                %plugin.rootFiltersActive = false;
                %TODO: If no root, deactivate all other peaks. This is
                %really for down the road...
                %plugin.thirdInterval = 'off'; %todo: this throws an error
                %in validation
                deactivateThirdFilters(plugin);
                deactivateFifthFilters(plugin);
                deactivateSeventhFilters(plugin);
            else
                plugin.rootNote = val;
                activateRootFilters(plugin);
            end
            setUpdateRootFilters(plugin);
            setUpdateThirdFilters(plugin);
            setUpdateFifthFilters(plugin); %todo: this is for later...
            setUpdateSeventhFilters(plugin); %todo: this is for later...
            
            updateRootFrequencies(plugin,val);
            updateThirdFrequencies(plugin);
            updateFifthFrequencies(plugin);
            updateSeventhFrequencies(plugin);
            
            % Update visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        %todo: this function is no longer necessary
        function set.rootGain(plugin,val)
            plugin.rootGain = val;
            
            %TODO: This is temporary until I implement range gain controls
            updateRootGain1(plugin,val);
            updateRootGain2(plugin,val);
            updateRootGain3(plugin,val);
            updateRootGain4(plugin,val);
            updateRootGain5(plugin,val);
            updateRootGain6(plugin,val);
            updateRootGain7(plugin,val);
            updateRootGain8(plugin,val);
            updateRootGain9(plugin,val);
            
            setUpdateRootFilters(plugin);
            
            % Update visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        %todo: this function is no longer necessary
        function set.rootQFactor(plugin,val)
            plugin.rootQFactor = val;
            
            %TODO: This is temporary until I implement controls by range
            updateRootQFactor1(plugin,val);
            updateRootQFactor2(plugin,val)
            updateRootQFactor3(plugin,val)
            updateRootQFactor4(plugin,val)
            updateRootQFactor5(plugin,val)
            updateRootQFactor6(plugin,val)
            updateRootQFactor7(plugin,val)
            updateRootQFactor8(plugin,val)
            updateRootQFactor9(plugin,val)
            
            setUpdateRootFilters(plugin);
            
            % Update visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        %--------------------------Harmonic Third--------------------------
        function set.thirdInterval(plugin,val)
            validatestring(val, {'off','Sus2','Min3','Maj3','Sus4'},...
                'set.thirdInterval','ThirdInterval');
            plugin.thirdInterval = val;
            if val == "off"
                %plugin.thirdFiltersActive = false;
                deactivateThirdFilters(plugin);
            else
                %todo: clean up
                switch val
                    case 'Sus2'
                        %plugin.thirdIntervalDistance = 2;
                        setThirdIntervalDistance(plugin,2);
                    case 'Min3'
                        %plugin.thirdIntervalDistance = 3;
                        setThirdIntervalDistance(plugin,3);
                    case 'Maj3'
                        %plugin.thirdIntervalDistance = 4;
                        setThirdIntervalDistance(plugin,4);
                    case 'Sus4'
                        %plugin.thirdIntervalDistance = 5;
                        setThirdIntervalDistance(plugin,5);
                end
                
                %plugin.thirdFiltersActive = true;
                activateThirdFilters(plugin);
                updateThirdFrequencies(plugin);
                setUpdateThirdFilters(plugin);
            end
            
            %todo: stateChange
            updateStateChangeStatus(plugin,true);
            
        end
        
        function set.thirdGain(plugin,val)
            plugin.thirdGain = val;
            
            %TODO: This is temporary until I implement range gain controls
            updateThirdGain1(plugin,val);
            updateThirdGain2(plugin,val);
            updateThirdGain3(plugin,val);
            updateThirdGain4(plugin,val);
            updateThirdGain5(plugin,val);
            updateThirdGain6(plugin,val);
            updateThirdGain7(plugin,val);
            updateThirdGain8(plugin,val);
            updateThirdGain9(plugin,val);
            
            setUpdateThirdFilters(plugin);
            
            % Update visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        function set.thirdQFactor(plugin,val)
            plugin.thirdQFactor = val;
            
            %TODO: This is temporary until I implement controls by range
            updateThirdQFactor1(plugin,val);
            updateThirdQFactor2(plugin,val);
            updateThirdQFactor3(plugin,val);
            updateThirdQFactor4(plugin,val);
            updateThirdQFactor5(plugin,val);
            updateThirdQFactor6(plugin,val);
            updateThirdQFactor7(plugin,val);
            updateThirdQFactor8(plugin,val);
            updateThirdQFactor9(plugin,val);
            
            setUpdateThirdFilters(plugin);
            
            % Update visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        
        %--------------------------Harmonic Fifth--------------------------
        function set.fifthInterval(plugin,val)
            validatestring(val, {'off','Dim5','Perf5','Aug5'},...
                'set.fifthInterval','FifthInterval');
            plugin.fifthInterval = val;
            
            %todo: clean up
            if val == "off"
                %plugin.fifthFiltersActive = false;
                deactivateFifthFilters(plugin);
            else
                switch val
                    case 'Dim5'
                        %plugin.fifthIntervalDistance = 6;
                        setFifthIntervalDistance(plugin,6);
                    case 'Perf5'
                        %plugin.fifthIntervalDistance = 7;
                        setFifthIntervalDistance(plugin,7);
                    case 'Aug5'
                        %plugin.fifthIntervalDistance = 8;
                        setFifthIntervalDistance(plugin,8);
                end
                
                %if plugin.rootNoteFiltersActive == true?
                %plugin.fifthFiltersActive = true;
                activateFifthFilters(plugin);
                updateFifthFrequencies(plugin);
                setUpdateFifthFilters(plugin);
            end
            
            %todo: stateChange
            updateStateChangeStatus(plugin,true);
        end
        
        function set.fifthGain(plugin,val)
            plugin.fifthGain = val;
            
            %TODO: This is temporary until I implement range gain controls
            updateFifthGain1(plugin,val);
            updateFifthGain2(plugin,val);
            updateFifthGain3(plugin,val);
            updateFifthGain4(plugin,val);
            updateFifthGain5(plugin,val);
            updateFifthGain6(plugin,val);
            updateFifthGain7(plugin,val);
            updateFifthGain8(plugin,val);
            updateFifthGain9(plugin,val);
            
            setUpdateFifthFilters(plugin);
            
            % Update visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        function set.fifthQFactor(plugin,val)
            plugin.fifthQFactor = val;
            
            %TODO: This is temporary until I implement controls by range
            updateFifthQFactor1(plugin,val);
            updateFifthQFactor2(plugin,val);
            updateFifthQFactor3(plugin,val);
            updateFifthQFactor4(plugin,val);
            updateFifthQFactor5(plugin,val);
            updateFifthQFactor6(plugin,val);
            updateFifthQFactor7(plugin,val);
            updateFifthQFactor8(plugin,val);
            updateFifthQFactor9(plugin,val);
            
            setUpdateFifthFilters(plugin);
            
            % Update visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        
        %--------------------------Harmonic Seventh--------------------------
        function set.seventhInterval(plugin,val)
            validatestring(val, {'off','Dim7','Min7','Maj7'},...
                'set.seventhInterval','SeventhInterval');
            plugin.seventhInterval = val;
            if val == "off"
                %plugin.seventhFiltersActive = false;
                deactivateSeventhFilters(plugin);
            else
                switch val
                    case 'Dim7'
                        %plugin.seventhIntervalDistance = 9;
                        setSeventhIntervalDistance(plugin,9);
                    case 'Min7'
                        %plugin.seventhIntervalDistance = 10;
                        setSeventhIntervalDistance(plugin,10);
                    case 'Maj7'
                        %plugin.seventhIntervalDistance = 11;
                        setSeventhIntervalDistance(plugin,11);
                end
                
                %if plugin.rootNoteFiltersActive == true?
                %plugin.seventhFiltersActive = true;
                activateSeventhFilters(plugin);
                updateSeventhFrequencies(plugin);
                setUpdateSeventhFilters(plugin);
            end 
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        function set.seventhGain(plugin,val)
            plugin.seventhGain = val;
            
            %TODO: This is temporary until I implement range gain controls
            updateSeventhGain1(plugin,val);
            updateSeventhGain2(plugin,val);
            updateSeventhGain3(plugin,val);
            updateSeventhGain4(plugin,val);
            updateSeventhGain5(plugin,val);
            updateSeventhGain6(plugin,val);
            updateSeventhGain7(plugin,val);
            updateSeventhGain8(plugin,val);
            updateSeventhGain9(plugin,val);
            
            setUpdateSeventhFilters(plugin);
            
            % Update visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        function set.seventhQFactor(plugin,val)
            plugin.seventhQFactor = val;
            
            %TODO: This is temporary until I implement controls by range
            updateSeventhQFactor1(plugin,val);
            updateSeventhQFactor2(plugin,val);
            updateSeventhQFactor3(plugin,val);
            updateSeventhQFactor4(plugin,val);
            updateSeventhQFactor5(plugin,val);
            updateSeventhQFactor6(plugin,val);
            updateSeventhQFactor7(plugin,val);
            updateSeventhQFactor8(plugin,val);
            updateSeventhQFactor9(plugin,val);
            
            setUpdateSeventhFilters(plugin);
            
            % Update visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        %------------------------High Region Controls----------------------
        function set.highRegionGain(plugin,val)
            plugin.highRegionGain = val;
            
            %todo: For now this will only control the first two octaves of
            %filters
            %todo: Create updateLowRegionGain function to handle this
            %plugin.rootGain9 = val;
            updateRootGain9(plugin,val);
            %plugin.thirdGain9 = val;
            updateThirdGain9(plugin,val);
            %plugin.fifthGain9 = val;
            updateFifthGain9(plugin,val);
            %plugin.seventhGain9 = val;
            updateSeventhGain9(plugin,val);
            
            
            %plugin.updateRootFilter9 = true;
            %plugin.updateThirdFilter9 = true;
            %plugin.updateFifthFilter9 = true;
            %plugin.updateSeventhFilter9 = true;
            setUpdateRootFilter9(plugin);
            setUpdateThirdFilter9(plugin);
            setUpdateFifthFilter9(plugin);
            setUpdateSeventhFilter9(plugin);
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
            
        end
        
        function set.highRegionQFactor(plugin,val)
            plugin.highRegionQFactor = val;
            
            %todo: also create helper functions for this...
            %plugin.rootQFactor9 = val;
            %plugin.thirdQFactor9 = val;
            %plugin.fifthQFactor9 = val;
            %plugin.seventhQFactor9 = val;
            updateRootQFactor9(plugin,val);
            updateThirdQFactor9(plugin,val);
            updateFifthQFactor9(plugin,val);
            updateSeventhQFactor9(plugin,val);
            
            
            %plugin.updateRootFilter9 = true;
            %plugin.updateThirdFilter9 = true;
            %plugin.updateFifthFilter9 = true;
            %plugin.updateSeventhFilter9 = true;
            setUpdateRootFilter9(plugin);
            setUpdateThirdFilter9(plugin);
            setUpdateFifthFilter9(plugin);
            setUpdateSeventhFilter9(plugin);
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        %----------------------High-Mid Region Controls--------------------
        function set.highMidRegionGain(plugin,val)
            plugin.highMidRegionGain = val;
            
            %todo: For now this will only control the first two octaves of
            %filters
            %todo: Create updateLowRegionGain function to handle this
            %plugin.rootGain7 = val;
            %plugin.rootGain8 = val;
            updateRootGain7(plugin,val);
            updateRootGain8(plugin,val);
            %plugin.thirdGain7 = val;
            %plugin.thirdGain8 = val;
            updateThirdGain7(plugin,val);
            updateThirdGain8(plugin,val);
            %plugin.fifthGain7 = val;
            %plugin.fifthGain8 = val;
            %plugin.seventhGain7 = val;
            %plugin.seventhGain8 = val;
            updateFifthGain7(plugin,val);
            updateFifthGain8(plugin,val);
            updateSeventhGain7(plugin,val);
            updateSeventhGain8(plugin,val);
            
            
            %plugin.updateRootFilter7 = true;
            %plugin.updateRootFilter8 = true;
            %plugin.updateThirdFilter7 = true;
            %plugin.updateThirdFilter8 = true;
            %plugin.updateFifthFilter7 = true;
            %plugin.updateFifthFilter8 = true;
            %plugin.updateSeventhFilter7 = true;
            %plugin.updateSeventhFilter8 = true;
            setUpdateRootFilter7(plugin);
            setUpdateRootFilter8(plugin);
            setUpdateThirdFilter7(plugin);
            setUpdateThirdFilter8(plugin);
            setUpdateFifthFilter7(plugin);
            setUpdateFifthFilter8(plugin);
            setUpdateSeventhFilter7(plugin);
            setUpdateSeventhFilter8(plugin);
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
            
        end
        
        function set.highMidRegionQFactor(plugin,val)
            plugin.highMidRegionQFactor = val;
            
            %todo: also create helper functions for this...
            %plugin.rootQFactor7 = val;
            %plugin.rootQFactor8 = val;
            %plugin.thirdQFactor7 = val;
            %plugin.thirdQFactor8 = val;
            %plugin.fifthQFactor7 = val;
            %plugin.fifthQFactor8 = val;
            %plugin.seventhQFactor7 = val;
            %plugin.seventhQFactor8 = val;
            updateRootQFactor7(plugin,val);
            updateRootQFactor8(plugin,val);
            updateThirdQFactor7(plugin,val);
            updateThirdQFactor8(plugin,val);
            updateFifthQFactor7(plugin,val);
            updateFifthQFactor8(plugin,val);
            updateSeventhQFactor7(plugin,val);
            updateSeventhQFactor8(plugin,val);
            
            %plugin.updateRootFilter7 = true;
            %plugin.updateRootFilter8 = true;
            %plugin.updateThirdFilter7 = true;
            %plugin.updateThirdFilter8 = true;
            %plugin.updateFifthFilter7 = true;
            %plugin.updateFifthFilter8 = true;
            %plugin.updateSeventhFilter7 = true;
            %plugin.updateSeventhFilter8 = true;
            setUpdateRootFilter7(plugin);
            setUpdateRootFilter8(plugin);
            setUpdateThirdFilter7(plugin);
            setUpdateThirdFilter8(plugin);
            setUpdateFifthFilter7(plugin);
            setUpdateFifthFilter8(plugin);
            setUpdateSeventhFilter7(plugin);
            setUpdateSeventhFilter8(plugin);
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        %------------------------Mid Region Controls-----------------------
        function set.midRegionGain(plugin,val)
            plugin.midRegionGain = val;
            
            %todo: For now this will only control the first two octaves of
            %filters
            %todo: Create updateLowRegionGain function to handle this
            %plugin.rootGain5 = val;
            %plugin.rootGain6 = val;
            updateRootGain5(plugin,val);
            updateRootGain6(plugin,val);
            %plugin.thirdGain5 = val;
            %plugin.thirdGain6 = val;
            updateThirdGain5(plugin,val);
            updateThirdGain6(plugin,val);
            %plugin.fifthGain5 = val;
            %plugin.fifthGain6 = val;
            %plugin.seventhGain5 = val;
            %plugin.seventhGain6 = val;
            updateFifthGain5(plugin,val);
            updateFifthGain6(plugin,val);
            updateSeventhGain5(plugin,val);
            updateSeventhGain6(plugin,val);
            
            
            %plugin.updateRootFilter5 = true;
            %plugin.updateRootFilter6 = true;
            %plugin.updateThirdFilter5 = true;
            %plugin.updateThirdFilter6 = true;
            %plugin.updateFifthFilter5 = true;
            %plugin.updateFifthFilter6 = true;
            %plugin.updateSeventhFilter5 = true;
            %plugin.updateSeventhFilter6 = true;
            setUpdateRootFilter5(plugin);
            setUpdateRootFilter6(plugin);
            setUpdateThirdFilter5(plugin);
            setUpdateThirdFilter6(plugin);
            setUpdateFifthFilter5(plugin);
            setUpdateFifthFilter6(plugin);
            setUpdateSeventhFilter5(plugin);
            setUpdateSeventhFilter6(plugin);
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
            
        end
        
        function set.midRegionQFactor(plugin,val)
            plugin.midRegionQFactor = val;
            
            %todo: also create helper functions for this...
            plugin.rootQFactor5 = val;
            plugin.rootQFactor6 = val;
            plugin.thirdQFactor5 = val;
            plugin.thirdQFactor6 = val;
            plugin.fifthQFactor5 = val;
            plugin.fifthQFactor6 = val;
            plugin.seventhQFactor5 = val;
            plugin.seventhQFactor6 = val;
            
            
            %plugin.updateRootFilter5 = true;
            %plugin.updateRootFilter6 = true;
            %plugin.updateThirdFilter5 = true;
            %plugin.updateThirdFilter6 = true;
            %plugin.updateFifthFilter5 = true;
            %plugin.updateFifthFilter6 = true;
            %plugin.updateSeventhFilter5 = true;
            %plugin.updateSeventhFilter6 = true;
            setUpdateRootFilter5(plugin);
            setUpdateRootFilter6(plugin);
            setUpdateThirdFilter5(plugin);
            setUpdateThirdFilter6(plugin);
            setUpdateFifthFilter5(plugin);
            setUpdateFifthFilter6(plugin);
            setUpdateSeventhFilter5(plugin);
            setUpdateSeventhFilter6(plugin);
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        %----------------------Low-Mid Region Controls---------------------
        function set.lowMidRegionGain(plugin,val)
            plugin.lowMidRegionGain = val;
            
            %todo: For now this will only control the first two octaves of
            %filters
            %todo: Create updateLowRegionGain function to handle this
            %plugin.rootGain3 = val;
            %plugin.rootGain4 = val;
            updateRootGain3(plugin,val);
            updateRootGain4(plugin,val);
            %plugin.thirdGain3 = val;
            %plugin.thirdGain4 = val;
            updateThirdGain3(plugin,val);
            updateThirdGain4(plugin,val);
            plugin.fifthGain3 = val;
            plugin.fifthGain4 = val;
            plugin.seventhGain3 = val;
            plugin.seventhGain4 = val;
            
            
            %plugin.updateRootFilter3 = true;
            %plugin.updateRootFilter4 = true;
            %plugin.updateThirdFilter3 = true;
            %plugin.updateThirdFilter4 = true;
            %plugin.updateFifthFilter3 = true;
            %plugin.updateFifthFilter4 = true;
            %plugin.updateSeventhFilter3 = true;
            %plugin.updateSeventhFilter4 = true;
            setUpdateRootFilter3(plugin);
            setUpdateRootFilter4(plugin);
            setUpdateThirdFilter3(plugin);
            setUpdateThirdFilter4(plugin);
            setUpdateFifthFilter3(plugin);
            setUpdateFifthFilter4(plugin);
            setUpdateSeventhFilter3(plugin);
            setUpdateSeventhFilter4(plugin);
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
            
        end
        
        function set.lowMidRegionQFactor(plugin,val)
            plugin.lowMidRegionQFactor = val;
            
            %todo: also create helper functions for this...
            plugin.rootQFactor3 = val;
            plugin.rootQFactor4 = val;
            plugin.thirdQFactor3 = val;
            plugin.thirdQFactor4 = val;
            plugin.fifthQFactor3 = val;
            plugin.fifthQFactor4 = val;
            plugin.seventhQFactor3 = val;
            plugin.seventhQFactor4 = val;
            
            
            %plugin.updateRootFilter3 = true;
            %plugin.updateRootFilter4 = true;
            %plugin.updateThirdFilter3 = true;
            %plugin.updateThirdFilter4 = true;
            %plugin.updateFifthFilter3 = true;
            %plugin.updateFifthFilter4 = true;
            %plugin.updateSeventhFilter3 = true;
            %plugin.updateSeventhFilter4 = true;
            setUpdateRootFilter3(plugin);
            setUpdateRootFilter4(plugin);
            setUpdateThirdFilter3(plugin);
            setUpdateThirdFilter4(plugin);
            setUpdateFifthFilter3(plugin);
            setUpdateFifthFilter4(plugin);
            setUpdateSeventhFilter3(plugin);
            setUpdateSeventhFilter4(plugin);
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        
        %------------------------Low Region Controls-----------------------
        function set.lowRegionGain(plugin,val)
            plugin.lowRegionGain = val;
            
            %todo: For now this will only control the first two octaves of
            %filters
            %todo: Create updateLowRegionGain function to handle this
            %plugin.rootGain1 = val;
            %plugin.rootGain2 = val;
            updateRootGain1(plugin,val);
            updateRootGain2(plugin,val);
            %plugin.thirdGain1 = val;
            %plugin.thirdGain2 = val;
            updateThirdGain1(plugin,val);
            updateThirdGain2(plugin,val);
            plugin.fifthGain1 = val;
            plugin.fifthGain2 = val;
            plugin.seventhGain1 = val;
            plugin.seventhGain2 = val;
            
            
            %plugin.updateRootFilter1 = true;
            %plugin.updateRootFilter2 = true;
            %plugin.updateThirdFilter1 = true;
            %plugin.updateThirdFilter2 = true;
            %plugin.updateFifthFilter1 = true;
            %plugin.updateFifthFilter2 = true;
            %plugin.updateSeventhFilter1 = true;
            %plugin.updateSeventhFilter2 = true;
            setUpdateRootFilter1(plugin);
            setUpdateRootFilter2(plugin);
            setUpdateThirdFilter1(plugin);
            setUpdateThirdFilter2(plugin);
            setUpdateFifthFilter1(plugin);
            setUpdateFifthFilter2(plugin);
            setUpdateSeventhFilter1(plugin);
            setUpdateSeventhFilter2(plugin);
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
            
        end
        
        function set.lowRegionQFactor(plugin,val)
            plugin.lowRegionQFactor = val;
            
            %todo: also create helper functions for this...
            plugin.rootQFactor1 = val;
            plugin.rootQFactor2 = val;
            plugin.thirdQFactor1 = val;
            plugin.thirdQFactor2 = val;
            plugin.fifthQFactor1 = val;
            plugin.fifthQFactor2 = val;
            plugin.seventhQFactor1 = val;
            plugin.seventhQFactor2 = val;
            
            
            %plugin.updateRootFilter1 = true;
            %plugin.updateRootFilter2 = true;
            %plugin.updateThirdFilter1 = true;
            %plugin.updateThirdFilter2 = true;
            %plugin.updateFifthFilter1 = true;
            %plugin.updateFifthFilter2 = true;
            %plugin.updateSeventhFilter1 = true;
            %plugin.updateSeventhFilter2 = true;
            setUpdateRootFilter1(plugin);
            setUpdateRootFilter2(plugin);
            setUpdateThirdFilter1(plugin);
            setUpdateThirdFilter2(plugin);
            setUpdateFifthFilter1(plugin);
            setUpdateFifthFilter2(plugin);
            setUpdateSeventhFilter1(plugin);
            setUpdateSeventhFilter2(plugin);
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
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
        
        
        %------------------------------------------------------------------
        % UPDATERS
        %------------------------------------------------------------------
        
        %-----------------------Root filter updaters-----------------------
        function updateRootFrequencies(plugin, val)
            
            rootNoteNumber = plugin.rootNoteValue; % todo: Declaring this here to pass validation
            rootFreq = plugin.rootFrequency1; % todo: Declaring this here to pass validation
            
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
        
        function updateRootGain1(plugin,val)
            plugin.rootGain1 = val;
        end
        
        function updateRootGain2(plugin,val)
            plugin.rootGain2 = val;
        end
        
        function updateRootGain3(plugin,val)
            plugin.rootGain3 = val;
        end
        
        function updateRootGain4(plugin,val)
            plugin.rootGain4 = val;
        end
        
        function updateRootGain5(plugin,val)
            plugin.rootGain5 = val;
        end
        
        function updateRootGain6(plugin,val)
            plugin.rootGain6 = val;
        end
        
        function updateRootGain7(plugin,val)
            plugin.rootGain7 = val;
        end
        
        function updateRootGain8(plugin,val)
            plugin.rootGain8 = val;
        end
        
        function updateRootGain9(plugin,val)
            plugin.rootGain9 = val;
        end
        
        function updateRootQFactor1(plugin,val)
            plugin.rootQFactor1 = val;
        end
        
        function updateRootQFactor2(plugin,val)
            plugin.rootQFactor2 = val;
        end
        
        function updateRootQFactor3(plugin,val)
            plugin.rootQFactor3 = val;
        end
        
        function updateRootQFactor4(plugin,val)
            plugin.rootQFactor4 = val;
        end
        
        function updateRootQFactor5(plugin,val)
            plugin.rootQFactor5 = val;
        end
        
        function updateRootQFactor6(plugin,val)
            plugin.rootQFactor6 = val;
        end
        
        function updateRootQFactor7(plugin,val)
            plugin.rootQFactor7 = val;
        end
        
        function updateRootQFactor8(plugin,val)
            plugin.rootQFactor8 = val;
        end
        
        function updateRootQFactor9(plugin,val)
            plugin.rootQFactor9 = val;
        end
        
        function setUpdateRootFilter1(plugin)
            plugin.updateRootFilter1 = true;
        end
        
        function setUpdateRootFilter2(plugin)
            plugin.updateRootFilter2 = true;
        end
        
        function setUpdateRootFilter3(plugin)
            plugin.updateRootFilter3 = true;
        end
        
        function setUpdateRootFilter4(plugin)
            plugin.updateRootFilter4 = true;
        end
        
        function setUpdateRootFilter5(plugin)
            plugin.updateRootFilter5 = true;
        end
        
        function setUpdateRootFilter6(plugin)
            plugin.updateRootFilter6 = true;
        end
        
        function setUpdateRootFilter7(plugin)
            plugin.updateRootFilter7 = true;
        end
        
        function setUpdateRootFilter8(plugin)
            plugin.updateRootFilter8 = true;
        end
        
        function setUpdateRootFilter9(plugin)
            plugin.updateRootFilter9 = true;
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
        
        function deactivateRootFilters(plugin)
            plugin.rootFiltersActive = false;
        end
        
        function activateRootFilters(plugin)
            plugin.rootFiltersActive = true;
        end
        
        
        %-----------------------Third filter updaters----------------------
        function updateThirdFrequencies(plugin)
            %todo: This really need to know the root note and harmonic
            %third interval
            
            thirdFreq = plugin.thirdFrequency1; % todo: Declaring this here to pass validation
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
        
        function updateThirdGain1(plugin,val)
            plugin.thirdGain1 = val;
        end
        
        function updateThirdGain2(plugin,val)
            plugin.thirdGain2 = val;
        end
        
        function updateThirdGain3(plugin,val)
            plugin.thirdGain3 = val;
        end
        
        function updateThirdGain4(plugin,val)
            plugin.thirdGain4 = val;
        end
        
        function updateThirdGain5(plugin,val)
            plugin.thirdGain5 = val;
        end
        
        function updateThirdGain6(plugin,val)
            plugin.thirdGain6 = val;
        end
        
        function updateThirdGain7(plugin,val)
            plugin.thirdGain7 = val;
        end
        
        function updateThirdGain8(plugin,val)
            plugin.thirdGain8 = val;
        end
        
        function updateThirdGain9(plugin,val)
            plugin.thirdGain9 = val;
        end
        
        function updateThirdQFactor1(plugin,val)
            plugin.thirdQFactor1 = val;
        end
        
        function updateThirdQFactor2(plugin,val)
            plugin.thirdQFactor2 = val;
        end
        
        function updateThirdQFactor3(plugin,val)
            plugin.thirdQFactor3 = val;
        end
        
        function updateThirdQFactor4(plugin,val)
            plugin.thirdQFactor4 = val;
        end
        
        function updateThirdQFactor5(plugin,val)
            plugin.thirdQFactor5 = val;
        end
        
        function updateThirdQFactor6(plugin,val)
            plugin.thirdQFactor6 = val;
        end
        
        function updateThirdQFactor7(plugin,val)
            plugin.thirdQFactor7 = val;
        end
        
        function updateThirdQFactor8(plugin,val)
            plugin.thirdQFactor8 = val;
        end
        
        function updateThirdQFactor9(plugin,val)
            plugin.thirdQFactor9 = val;
        end
        
        function setUpdateThirdFilter1(plugin)
            plugin.updateThirdFilter1 = true;
        end
        
        function setUpdateThirdFilter2(plugin)
            plugin.updateThirdFilter2 = true;
        end
        
        function setUpdateThirdFilter3(plugin)
            plugin.updateThirdFilter3 = true;
        end
        
        function setUpdateThirdFilter4(plugin)
            plugin.updateThirdFilter4 = true;
        end
        
        function setUpdateThirdFilter5(plugin)
            plugin.updateThirdFilter5 = true;
        end
        
        function setUpdateThirdFilter6(plugin)
            plugin.updateThirdFilter6 = true;
        end
        
        function setUpdateThirdFilter7(plugin)
            plugin.updateThirdFilter7 = true;
        end
        
        function setUpdateThirdFilter8(plugin)
            plugin.updateThirdFilter8 = true;
        end
        
        function setUpdateThirdFilter9(plugin)
            plugin.updateThirdFilter9 = true;
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
        
        function setThirdIntervalDistance(plugin,val)
            plugin.thirdIntervalDistance = val;
        end
        
        function deactivateThirdFilters(plugin)
            plugin.thirdFiltersActive = false;
        end
        
        function activateThirdFilters(plugin)
            plugin.thirdFiltersActive = true;
        end
        
        
        %-----------------------Fifth filter updaters----------------------
        function updateFifthFrequencies(plugin)
            %todo: This really need to know the root note and harmonic
            %third interval
            
            fifthFreq = plugin.fifthFrequency1; % todo: Declaring this here to pass validation
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
        
        function updateFifthGain1(plugin,val)
            plugin.fifthGain1 = val;
        end
        
        function updateFifthGain2(plugin,val)
            plugin.fifthGain2 = val;
        end
        
        function updateFifthGain3(plugin,val)
            plugin.fifthGain3 = val;
        end
        
        function updateFifthGain4(plugin,val)
            plugin.fifthGain4 = val;
        end
        
        function updateFifthGain5(plugin,val)
            plugin.fifthGain5 = val;
        end
        
        function updateFifthGain6(plugin,val)
            plugin.fifthGain6 = val;
        end
        
        function updateFifthGain7(plugin,val)
            plugin.fifthGain7 = val;
        end
        
        function updateFifthGain8(plugin,val)
            plugin.fifthGain8 = val;
        end
        
        function updateFifthGain9(plugin,val)
            plugin.fifthGain9 = val;
        end
        
        function updateFifthQFactor1(plugin,val)
            plugin.fifthQFactor1 = val;
        end
        
        function updateFifthQFactor2(plugin,val)
            plugin.fifthQFactor2 = val;
        end
        
        function updateFifthQFactor3(plugin,val)
            plugin.fifthQFactor3 = val;
        end
        
        function updateFifthQFactor4(plugin,val)
            plugin.fifthQFactor4 = val;
        end
        
        function updateFifthQFactor5(plugin,val)
            plugin.fifthQFactor5 = val;
        end
        
        function updateFifthQFactor6(plugin,val)
            plugin.fifthQFactor6 = val;
        end
        
        function updateFifthQFactor7(plugin,val)
            plugin.fifthQFactor7 = val;
        end
        
        function updateFifthQFactor8(plugin,val)
            plugin.fifthQFactor8 = val;
        end
        
        function updateFifthQFactor9(plugin,val)
            plugin.fifthQFactor9 = val;
        end
        
        function setUpdateFifthFilter1(plugin)
            plugin.updateFifthFilter1 = true;
        end
        
        function setUpdateFifthFilter2(plugin)
            plugin.updateFifthFilter2 = true;
        end
        
        function setUpdateFifthFilter3(plugin)
            plugin.updateFifthFilter3 = true;
        end
        
        function setUpdateFifthFilter4(plugin)
            plugin.updateFifthFilter4 = true;
        end
        
        function setUpdateFifthFilter5(plugin)
            plugin.updateFifthFilter5 = true;
        end
        
        function setUpdateFifthFilter6(plugin)
            plugin.updateFifthFilter6 = true;
        end
        
        function setUpdateFifthFilter7(plugin)
            plugin.updateFifthFilter7 = true;
        end
        
        function setUpdateFifthFilter8(plugin)
            plugin.updateFifthFilter8 = true;
        end
        
        function setUpdateFifthFilter9(plugin)
            plugin.updateFifthFilter9 = true;
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
        
        function setFifthIntervalDistance(plugin,val)
            plugin.fifthIntervalDistance = val;
        end
        
        function deactivateFifthFilters(plugin)
            plugin.fifthFiltersActive = false;
        end
        
        function activateFifthFilters(plugin)
            plugin.fifthFiltersActive = true;
        end
        
        
        %----------------------Seventh filter updaters---------------------
        function updateSeventhFrequencies(plugin)
            
            seventhFreq = plugin.seventhFrequency1; % todo: Declaring this here to pass validation
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
        
        function updateSeventhGain1(plugin,val)
            plugin.seventhGain1 = val;
        end
        
        function updateSeventhGain2(plugin,val)
            plugin.seventhGain2 = val;
        end
        
        function updateSeventhGain3(plugin,val)
            plugin.seventhGain3 = val;
        end
        
        function updateSeventhGain4(plugin,val)
            plugin.seventhGain4 = val;
        end
        
        function updateSeventhGain5(plugin,val)
            plugin.seventhGain5 = val;
        end
        
        function updateSeventhGain6(plugin,val)
            plugin.seventhGain6 = val;
        end
        
        function updateSeventhGain7(plugin,val)
            plugin.seventhGain7 = val;
        end
        
        function updateSeventhGain8(plugin,val)
            plugin.seventhGain8 = val;
        end
        
        function updateSeventhGain9(plugin,val)
            plugin.seventhGain9 = val;
        end
        
        function updateSeventhQFactor1(plugin,val)
            plugin.seventhQFactor1 = val;
        end
        
        function updateSeventhQFactor2(plugin,val)
            plugin.seventhQFactor2 = val;
        end
        
        function updateSeventhQFactor3(plugin,val)
            plugin.seventhQFactor3 = val;
        end
        
        function updateSeventhQFactor4(plugin,val)
            plugin.seventhQFactor4 = val;
        end
        
        function updateSeventhQFactor5(plugin,val)
            plugin.seventhQFactor5 = val;
        end
        
        function updateSeventhQFactor6(plugin,val)
            plugin.seventhQFactor6 = val;
        end
        
        function updateSeventhQFactor7(plugin,val)
            plugin.seventhQFactor7 = val;
        end
        
        function updateSeventhQFactor8(plugin,val)
            plugin.seventhQFactor8 = val;
        end
        
        function updateSeventhQFactor9(plugin,val)
            plugin.seventhQFactor9 = val;
        end
        
        function setUpdateSeventhFilter1(plugin)
            plugin.updateSeventhFilter1 = true;
        end
        
        function setUpdateSeventhFilter2(plugin)
            plugin.updateSeventhFilter2 = true;
        end
        
        function setUpdateSeventhFilter3(plugin)
            plugin.updateSeventhFilter3 = true;
        end
        
        function setUpdateSeventhFilter4(plugin)
            plugin.updateSeventhFilter4 = true;
        end
        
        function setUpdateSeventhFilter5(plugin)
            plugin.updateSeventhFilter5 = true;
        end
        
        function setUpdateSeventhFilter6(plugin)
            plugin.updateSeventhFilter6 = true;
        end
        
        function setUpdateSeventhFilter7(plugin)
            plugin.updateSeventhFilter7 = true;
        end
        
        function setUpdateSeventhFilter8(plugin)
            plugin.updateSeventhFilter8 = true;
        end
        
        function setUpdateSeventhFilter9(plugin)
            plugin.updateSeventhFilter9 = true;
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
        
        function setSeventhIntervalDistance(plugin,val)
            plugin.seventhIntervalDistance = val;
        end
        
        function deactivateSeventhFilters(plugin)
            plugin.seventhFiltersActive = false;
        end
        
        function activateSeventhFilters(plugin)
            plugin.seventhFiltersActive = true;
        end
        
        
        %-------------------Filter coefficients updater--------------------
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
        
        function updateStateChangeStatus(plugin,val)
            plugin.stateChange = val;
        end
        
        function updateVisualizer(plugin)
            if ~isempty(plugin.visualizerObject)
                step(plugin.visualizerObject,...
                    plugin.B, plugin.A);
                plugin.visualizerObject.SampleRate = plugin.getSampleRate;
            end
            
            % reset plugin.stateChange after updating visualizer
            updateStateChangeStatus(plugin,false);
        end
        
    end
    
    
end















