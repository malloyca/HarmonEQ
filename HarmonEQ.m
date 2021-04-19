classdef HarmonEQ < matlab.System & audioPlugin
% HarmonEQ.m
% Harmonic Equalizer plugin
% v0.3-alpha
% Last updated: 13 April 2021
%
% This plugin presents a new control scheme for the traditional equalizer.
% Most people are familiar with the various types of EQs out there
% (graphics EQs, parametric and semi-parametric EQs, etc). These tools work
% well for many jobs, but sometimes certain situations would benefit from
% an EQ that is defined in a more musically-informed way. HarmonEQ is a
% plugin designed to showcase a new control paradigm for the standard
% parametric EQ that is based on harmony instead of direct frequency
% control by the user. This allows the user to target the EQ more finely
% based on the current harmony of a track.
%
% To run this with the visualizer in Matlab, run these commands:
% eq = HarmonEQ;
% Visualizer(eq);
% audioTestBench(eq);
%
% To validate for generation:
% validateAudioPlugin HarmonEQ;
% To export as a VST, run:
% generateAudioPlugin -outdir plugins HarmonEQ;
% To export as an AU (on macOS):
% generateAudioPlugin -au -outdir plugins HarmonEQ;


% TODO:
% - Look into State-variable filters vs biquads
% - Make the parameter smoothing more dynamic at large buffer sizes. Right
% now it goes really slowly if the buffer size is large since it only steps
% once per buffer. It wouldn't be too hard to set it so that it stepped
% multiple times per input buffer for larger buffer sizes
%

    %----------------------------------------------------------------------
    % TUNABLE PROPERTIES
    %----------------------------------------------------------------------
    properties
        rootNote = 'C';
        rootNoteValue = 0; %todo: move this to private
        
        thirdInterval = 'off';
        thirdIntervalDistance = 4; %todo: move this to private
        thirdNote = 'E'; %todo: move this to private
        
        fifthInterval = 'off';
        fifthIntervalDistance = 7; %todo: move this to private
        fifthNote = 'G'; %todo: move this to private
        
        seventhInterval = 'off';
        seventhIntervalDistance = 11; %todo: move this to private
        seventhNote = 'B'; %todo: move this to private
        
        %---------------------Region Gain and Q Values---------------------
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
        
        %-------------------Control frequency crossovers-------------------
        lowCrossoverFreq = 89.87;
        lowMidCrossoverFreq = 359.46;
        midHighCrossoverFreq = 1437.85;
        highCrossoverFreq = 5751.38;
        
                
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
            'VendorName','Colin Malloy',...
            'VendorVersion','0.2',...
            ...
            audioPluginParameter('rootNote','DisplayName','Root Note',...
            'Mapping',{'enum','off','A','A# / Bb','B','C','C# / Db','D',...
            'D# / Eb','E','F','F# / Gb','G','G# / Ab'},...
            'Style','dropdown',...
            'Layout',[2,11],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('thirdInterval',...
            'DisplayName','Harmonic Third Interval',...
            'Mapping',{'enum','off','Sus2','Min3','Maj3','Sus4'},...
            'Style','dropdown',...
            'Layout',[4,11],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('fifthInterval',...
            'DisplayName','Harmonic Fifth Interval',...
            'Mapping',{'enum','off','Dim5','Perf5','Aug5'},...
            'Style','dropdown',...
            'Layout',[6,11],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('seventhInterval',...
            'DisplayName','Harmonic Seventh Interval',...
            'Mapping',{'enum','off','Dim7','Min7','Maj7'},...
            'Style','dropdown',...
            'Layout',[8,11],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('highRegionGain',...
            'DisplayName','High Gain',...
            'Mapping',{'lin',-15,15},...
            'Style','vslider',...
            'Layout',[2,9;8,10],...
            'DisplayNameLocation','above'),...
            audioPluginParameter('highRegionQFactor',...
            'DisplayName','High Q',...
            'Mapping',{'pow', 2, 0.5, 100},...
            'Style','rotary',...
            'Layout',[10,9;10,10],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('highMidRegionGain',...
            'DisplayName','High-Mid Gain',...
            'Mapping',{'lin',-15,15},...
            'Style','vslider',...
            'Layout',[2,7;8,8],...
            'DisplayNameLocation','above'),...
            audioPluginParameter('highMidRegionQFactor',...
            'DisplayName','High-Mid Q',...
            'Mapping',{'pow', 2, 0.5, 100},...
            'Style','rotary',...
            'Layout',[10,7;10,8],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('midRegionGain',...
            'DisplayName','Mid Gain',...
            'Mapping',{'lin',-15,15},...
            'Style','vslider',...
            'Layout',[2,5;8,6],...
            'DisplayNameLocation','above'),...
            audioPluginParameter('midRegionQFactor',...
            'DisplayName','Mid Q',...
            'Mapping',{'pow', 2, 0.5, 100},...
            'Style','rotary',...
            'Layout',[10,5;10,6],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('lowMidRegionGain',...
            'DisplayName','Low-Mid Gain',...
            'Mapping',{'lin',-15,15},...
            'Style','vslider',...
            'Layout',[2,3;8,4],...
            'DisplayNameLocation','above'),...
            audioPluginParameter('lowMidRegionQFactor',...
            'DisplayName','Low-Mid Q',...
            'Mapping',{'pow', 2, 0.5, 100},...
            'Style','rotary',...
            'Layout',[10,3;10,4],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('lowRegionGain',...
            'DisplayName','Low Gain',...
            'Mapping',{'lin',-15,15},...
            'Style','vslider',...
            'Layout',[2,1;8,2],...
            'DisplayNameLocation','above'),...
            audioPluginParameter('lowRegionQFactor',...
            'DisplayName','Low Q',...
            'Mapping',{'pow', 2, 0.5, 100},...
            'Style','rotary',...
            'Layout',[10,1;10,2],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('lowCrossoverFreq',...
            'DisplayName','Low Crossover',...
            'Mapping',{'log',63.54,127.09},...
            'Style','rotary',...
            'Layout',[11,2;11,3],...
            'DisplayNameLocation','below'),...
            ...
            audioPluginParameter('lowMidCrossoverFreq',...
            'DisplayName','Low-Mid Crossover',...
            'Mapping',{'log',254.18,508.36},...
            'Style','rotary',...
            'Layout',[11,4;11,5],...
            'DisplayNameLocation','below'),...
            ...
            audioPluginParameter('midHighCrossoverFreq',...
            'DisplayName','Mid-High Crossover',...
            'Mapping',{'log',1016.71,2033.42},...
            'Style','rotary',...
            'Layout',[11,6;11,7],...
            'DisplayNameLocation','below'),...
            ...
            audioPluginParameter('highCrossoverFreq',...
            'DisplayName','High Crossover',...
            'Mapping',{'log',4066.84,8133.68},...
            'Style','rotary',...
            'Layout',[11,8;11,9],...
            'DisplayNameLocation','below'),...
            ...
            audioPluginGridLayout(...
            'RowHeight',[25,25,25,25,25,25,25,25,25,100,100,25],... %todo: I don't think the 25 near the end is necessary
            'ColumnWidth',[50,50,50,50,50,50,50,50,50,50,150],...
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
        
        
        %------------------Parameter smoothing variables-------------------
        % Track Filter regions
        rootFilter1Region = 1; % Not currently changeable
        rootFilter2Region = 1;
        rootFilter3Region = 2; % Not currently changeable
        rootFilter4Region = 2;
        rootFilter5Region = 3; % Not currently changeable
        rootFilter6Region = 3;
        rootFilter7Region = 4; % Not currently changeable
        rootFilter8Region = 4;
        rootFilter9Region = 5; % Not currently changeable
        
        % Root filter smoothing variables
        rootFilter1GainDiff = 0;
        rootFilter1GainTarget = 0;
        rootFilter1GainSmooth = false;
        rootFilter1GainStep = Inf;
        rootFilter1QDiff = 26;
        rootFilter1QTarget = 26;
        rootFilter1QSmooth = false
        rootFilter1QStep = Inf;
        
        rootFilter2GainDiff = 0;
        rootFilter2GainTarget = 0;
        rootFilter2GainSmooth = false;
        rootFilter2GainStep = Inf;
        rootFilter2QDiff = 26;
        rootFilter2QTarget = 26;
        rootFilter2QSmooth = false
        rootFilter2QStep = Inf;
        
        rootFilter3GainDiff = 0;
        rootFilter3GainTarget = 0;
        rootFilter3GainSmooth = false;
        rootFilter3GainStep = Inf;
        rootFilter3QDiff = 26;
        rootFilter3QTarget = 26;
        rootFilter3QSmooth = false
        rootFilter3QStep = Inf;
        
        rootFilter4GainDiff = 0;
        rootFilter4GainTarget = 0;
        rootFilter4GainSmooth = false;
        rootFilter4GainStep = Inf;
        rootFilter4QDiff = 26;
        rootFilter4QTarget = 26;
        rootFilter4QSmooth = false
        rootFilter4QStep = Inf;
        
        rootFilter5GainDiff = 0;
        rootFilter5GainTarget = 0;
        rootFilter5GainSmooth = false;
        rootFilter5GainStep = Inf;
        rootFilter5QDiff = 26;
        rootFilter5QTarget = 26;
        rootFilter5QSmooth = false
        rootFilter5QStep = Inf;
        
        rootFilter6GainDiff = 0;
        rootFilter6GainTarget = 0;
        rootFilter6GainSmooth = false;
        rootFilter6GainStep = Inf;
        rootFilter6QDiff = 26;
        rootFilter6QTarget = 26;
        rootFilter6QSmooth = false
        rootFilter6QStep = Inf;
        
        rootFilter7GainDiff = 0;
        rootFilter7GainTarget = 0;
        rootFilter7GainSmooth = false;
        rootFilter7GainStep = Inf;
        rootFilter7QDiff = 26;
        rootFilter7QTarget = 26;
        rootFilter7QSmooth = false
        rootFilter7QStep = Inf;
        
        rootFilter8GainDiff = 0;
        rootFilter8GainTarget = 0;
        rootFilter8GainSmooth = false;
        rootFilter8GainStep = Inf;
        rootFilter8QDiff = 26;
        rootFilter8QTarget = 26;
        rootFilter8QSmooth = false
        rootFilter8QStep = Inf;
        
        rootFilter9GainDiff = 0;
        rootFilter9GainTarget = 0;
        rootFilter9GainSmooth = false;
        rootFilter9GainStep = Inf;
        rootFilter9QDiff = 26;
        rootFilter9QTarget = 26;
        rootFilter9QSmooth = false
        rootFilter9QStep = Inf;
        
        %-----Harmonic third region tracking
        thirdFilter1Region = 1; % Not currently changeable
        thirdFilter2Region = 1;
        thirdFilter3Region = 2; % Not currently changeable
        thirdFilter4Region = 2;
        thirdFilter5Region = 3; % Not currently changeable
        thirdFilter6Region = 3;
        thirdFilter7Region = 4; % Not currently changeable
        thirdFilter8Region = 4;
        thirdFilter9Region = 5; % Not currently changeable
        
        %-----Harmonic third smoothing variables
        thirdFilter1GainDiff = 0;
        thirdFilter1GainTarget = 0;
        thirdFilter1GainSmooth = false;
        thirdFilter1GainStep = Inf;
        thirdFilter1QDiff = 26;
        thirdFilter1QTarget = 26;
        thirdFilter1QSmooth = false
        thirdFilter1QStep = Inf;
        
        thirdFilter2GainDiff = 0;
        thirdFilter2GainTarget = 0;
        thirdFilter2GainSmooth = false;
        thirdFilter2GainStep = Inf;
        thirdFilter2QDiff = 26;
        thirdFilter2QTarget = 26;
        thirdFilter2QSmooth = false
        thirdFilter2QStep = Inf;
        
        thirdFilter3GainDiff = 0;
        thirdFilter3GainTarget = 0;
        thirdFilter3GainSmooth = false;
        thirdFilter3GainStep = Inf;
        thirdFilter3QDiff = 26;
        thirdFilter3QTarget = 26;
        thirdFilter3QSmooth = false
        thirdFilter3QStep = Inf;
        
        thirdFilter4GainDiff = 0;
        thirdFilter4GainTarget = 0;
        thirdFilter4GainSmooth = false;
        thirdFilter4GainStep = Inf;
        thirdFilter4QDiff = 26;
        thirdFilter4QTarget = 26;
        thirdFilter4QSmooth = false
        thirdFilter4QStep = Inf;
        
        thirdFilter5GainDiff = 0;
        thirdFilter5GainTarget = 0;
        thirdFilter5GainSmooth = false;
        thirdFilter5GainStep = Inf;
        thirdFilter5QDiff = 26;
        thirdFilter5QTarget = 26;
        thirdFilter5QSmooth = false
        thirdFilter5QStep = Inf;
        
        thirdFilter6GainDiff = 0;
        thirdFilter6GainTarget = 0;
        thirdFilter6GainSmooth = false;
        thirdFilter6GainStep = Inf;
        thirdFilter6QDiff = 26;
        thirdFilter6QTarget = 26;
        thirdFilter6QSmooth = false
        thirdFilter6QStep = Inf;
        
        %test
        thirdFilter8SmoothStatus = false;
        thirdFilter8SmoothStep = 0;
        thirdFilter8GainDiff = 0;
        thirdFilter8GainTarget = 0;
        thirdFilter8QDiff = 26;
        thirdFilter8QTarget = 26;
        
        %-----Harmonic fifth region tracking
        fifthFilter1Region = 1; % Not currently changeable
        fifthFilter2Region = 1;
        fifthFilter3Region = 2; % Not currently changeable
        fifthFilter4Region = 2;
        fifthFilter5Region = 3; % Not currently changeable
        fifthFilter6Region = 3;
        fifthFilter7Region = 4; % Not currently changeable
        fifthFilter8Region = 4;
        fifthFilter9Region = 5; % Not currently changeable
        
        %-----Harmonic fifth smoothing variables
        fifthFilter2SmoothStatus = false;
        fifthFilter2SmoothStep = 0;
        fifthFilter2GainDiff = 0;
        fifthFilter2GainTarget = 0;
        fifthFilter2QDiff = 26;
        fifthFilter2QTarget = 26;
        
        fifthFilter4SmoothStatus = false;
        fifthFilter4SmoothStep = 0;
        fifthFilter4GainDiff = 0;
        fifthFilter4GainTarget = 0;
        fifthFilter4QDiff = 26;
        fifthFilter4QTarget = 26;
        
        fifthFilter6SmoothStatus = false;
        fifthFilter6SmoothStep = 0;
        fifthFilter6GainDiff = 0;
        fifthFilter6GainTarget = 0;
        fifthFilter6QDiff = 26;
        fifthFilter6QTarget = 26;
        
        fifthFilter8SmoothStatus = false;
        fifthFilter8SmoothStep = 0;
        fifthFilter8GainDiff = 0;
        fifthFilter8GainTarget = 0;
        fifthFilter8QDiff = 26;
        fifthFilter8QTarget = 26;
        
        %-----Harmonic seventh region tracking
        seventhFilter1Region = 1; % Not currently changeable
        seventhFilter2Region = 1;
        seventhFilter3Region = 2; % Not currently changeable
        seventhFilter4Region = 2;
        seventhFilter5Region = 3; % Not currently changeable
        seventhFilter6Region = 3;
        seventhFilter7Region = 4; % Not currently changeable
        seventhFilter8Region = 4;
        seventhFilter9Region = 5; % Not currently changeable
        
        %-----Harmonic seventh smoothing variables
        seventhFilter2SmoothStatus = false;
        seventhFilter2SmoothStep = 0;
        seventhFilter2GainDiff = 0;
        seventhFilter2GainTarget = 0;
        seventhFilter2QDiff = 26;
        seventhFilter2QTarget = 26;
        
        seventhFilter4SmoothStatus = false;
        seventhFilter4SmoothStep = 0;
        seventhFilter4GainDiff = 0;
        seventhFilter4GainTarget = 0;
        seventhFilter4QDiff = 26;
        seventhFilter4QTarget = 26;
        
        seventhFilter6SmoothStatus = false;
        seventhFilter6SmoothStep = 0;
        seventhFilter6GainDiff = 0;
        seventhFilter6GainTarget = 0;
        seventhFilter6QDiff = 26;
        seventhFilter6QTarget = 26;
        
        seventhFilter8SmoothStatus = false;
        seventhFilter8SmoothStep = 0;
        seventhFilter8GainDiff = 0;
        seventhFilter8GainTarget = 0;
        seventhFilter8QDiff = 26;
        seventhFilter8QTarget = 26;
        
        numberOfSmoothSteps = 100; %todo: Find a good value for this
        
        
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
            
            % update visualizer
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
            
            % update visualizer
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
        
        
        %------------------------High Region Controls----------------------
        function set.highRegionGain(plugin,val)
            plugin.highRegionGain = val;
            
            % This currently always controls the high octave of filters and
            % can be configured to control the 8th octave as well
            
            % todo: This should be set up to always affect octave 9
            % filters, they technically don't need if statements, but if I
            % increase the adjustability they will
            
            if (plugin.rootFrequency9 > plugin.highCrossoverFreq)
                updateRootGain9(plugin,val);
                setUpdateRootFilter9(plugin);
            end
            if (plugin.rootFrequency8 > plugin.highCrossoverFreq)
                updateRootGain8(plugin,val);
                setUpdateRootFilter8(plugin);
            end
            
            if (plugin.thirdFrequency9 > plugin.highCrossoverFreq)
                updateThirdGain9(plugin,val);
                setUpdateThirdFilter9(plugin);
            end
            if (plugin.thirdFrequency8 > plugin.highCrossoverFreq)
                updateThirdGain8(plugin,val);
                setUpdateThirdFilter8(plugin);
            end
            
            if (plugin.fifthFrequency9 > plugin.highCrossoverFreq)
                updateFifthGain9(plugin,val);
                setUpdateFifthFilter9(plugin);
            end
            if (plugin.fifthFrequency8 > plugin.highCrossoverFreq)
                updateFifthGain8(plugin,val);
                setUpdateFifthFilter8(plugin);
            end
            
            if (plugin.seventhFrequency9 > plugin.highCrossoverFreq)
                updateSeventhGain9(plugin,val);
                setUpdateSeventhFilter9(plugin);
            end
            if (plugin.seventhFrequency8 > plugin.highCrossoverFreq)
                updateSeventhGain8(plugin,val);
                setUpdateSeventhFilter8(plugin);
            end
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
            
        end
        
        function set.highRegionQFactor(plugin,val)
            plugin.highRegionQFactor = val;
            
            if (plugin.rootFrequency9 > plugin.highCrossoverFreq)
                updateRootQFactor9(plugin,val);
                setUpdateRootFilter9(plugin);
            end
            if (plugin.rootFrequency8 > plugin.highCrossoverFreq)
                updateRootQFactor8(plugin,val);
                setUpdateRootFilter8(plugin);
            end
            
            if (plugin.thirdFrequency9 > plugin.highCrossoverFreq)
                updateThirdQFactor9(plugin,val);
                setUpdateThirdFilter9(plugin);
            end
            if (plugin.thirdFrequency8 > plugin.highCrossoverFreq)
                updateThirdQFactor8(plugin,val);
                setUpdateThirdFilter8(plugin);
            end
            
            if (plugin.fifthFrequency9 > plugin.highCrossoverFreq)
                updateFifthQFactor9(plugin,val);
                setUpdateFifthFilter9(plugin);
            end
            if (plugin.fifthFrequency8 > plugin.highCrossoverFreq)
                updateFifthQFactor8(plugin,val);
                setUpdateFifthFilter8(plugin);
            end
            
            if (plugin.seventhFrequency9 > plugin.highCrossoverFreq)
                updateSeventhQFactor9(plugin,val);
                setUpdateSeventhFilter9(plugin);
            end
            if (plugin.seventhFrequency8 > plugin.highCrossoverFreq)
                updateSeventhQFactor8(plugin,val);
                setUpdateSeventhFilter8(plugin);
            end
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        %----------------------High-Mid Region Controls--------------------
        function set.highMidRegionGain(plugin,val)
            plugin.highMidRegionGain = val;
            
            % todo: Maybe I should update the setUpdate... filter plugins
            % to check the freq and Q when the update rather than doing it
            % here. Or have setUpdateRootFilter8 call updateRootGain8 from
            % within that. Then I don't have to manage gain and Q
            % directly...
            if (plugin.rootFrequency8 < plugin.highCrossoverFreq)
                updateRootGain8(plugin,val);
                setUpdateRootFilter8(plugin);
            end
            updateRootGain7(plugin,val);
            setUpdateRootFilter7(plugin);
            if (plugin.rootFrequency6 > plugin.midHighCrossoverFreq)
                updateRootGain6(plugin,val);
                setUpdateRootFilter6(plugin);
            end
            
            if (plugin.thirdFrequency8 < plugin.highCrossoverFreq)
                updateThirdGain8(plugin,val);
                setUpdateThirdFilter8(plugin);
            end
            updateThirdGain7(plugin,val);
            setUpdateThirdFilter7(plugin);
            if (plugin.thirdFrequency6 > plugin.midHighCrossoverFreq)
                updateThirdGain6(plugin,val);
                setUpdateThirdFilter6(plugin);
            end
            
            if (plugin.fifthFrequency8 < plugin.highCrossoverFreq)
                updateFifthGain8(plugin,val);
                setUpdateFifthFilter8(plugin);
            end
            updateFifthGain7(plugin,val);
            setUpdateFifthFilter7(plugin);
            if (plugin.fifthFrequency6 > plugin.midHighCrossoverFreq)
                updateFifthGain6(plugin,val);
                setUpdateFifthFilter6(plugin);
            end
            
            if (plugin.seventhFrequency8 < plugin.highCrossoverFreq)
                updateSeventhGain8(plugin,val);
                setUpdateSeventhFilter8(plugin);
            end
            updateSeventhGain7(plugin,val);
            setUpdateSeventhFilter7(plugin);
            if (plugin.seventhFrequency6 > plugin.midHighCrossoverFreq)
                updateSeventhGain6(plugin,val);
                setUpdateSeventhFilter6(plugin);
            end
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
            
        end
        
        function set.highMidRegionQFactor(plugin,val)
            plugin.highMidRegionQFactor = val;
            
            % todo: Maybe I should update the setUpdate... filter plugins
            % to check the freq and Q when the update rather than doing it
            % here. Or have setUpdateRootFilter8 call updateRootGain8 from
            % within that. Then I don't have to manage gain and Q
            % directly...
            if (plugin.rootFrequency8 < plugin.highCrossoverFreq)
                updateRootQFactor8(plugin,val);
                setUpdateRootFilter8(plugin);
            end
            updateRootQFactor7(plugin,val);
            setUpdateRootFilter7(plugin);
            if (plugin.rootFrequency6 > plugin.midHighCrossoverFreq)
                updateRootQFactor6(plugin,val);
                setUpdateRootFilter6(plugin);
            end
            
            if (plugin.thirdFrequency8 < plugin.highCrossoverFreq)
                updateThirdQFactor8(plugin,val);
                setUpdateThirdFilter8(plugin);
            end
            updateThirdQFactor7(plugin,val);
            setUpdateThirdFilter7(plugin);
            if (plugin.thirdFrequency6 > plugin.midHighCrossoverFreq)
                updateThirdQFactor6(plugin,val);
                setUpdateThirdFilter6(plugin);
            end
            
            if (plugin.fifthFrequency8 < plugin.highCrossoverFreq)
                updateFifthQFactor8(plugin,val);
                setUpdateFifthFilter8(plugin);
            end
            updateFifthQFactor7(plugin,val);
            setUpdateFifthFilter7(plugin);
            if (plugin.fifthFrequency6 > plugin.midHighCrossoverFreq)
                updateFifthQFactor6(plugin,val);
                setUpdateFifthFilter6(plugin);
            end
            
            if (plugin.seventhFrequency8 < plugin.highCrossoverFreq)
                updateSeventhQFactor8(plugin,val);
                setUpdateSeventhFilter8(plugin);
            end
            updateSeventhQFactor7(plugin,val);
            setUpdateSeventhFilter7(plugin);
            if (plugin.seventhFrequency6 > plugin.midHighCrossoverFreq)
                updateSeventhQFactor6(plugin,val);
                setUpdateSeventhFilter6(plugin);
            end
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        %------------------------Mid Region Controls-----------------------
        function set.midRegionGain(plugin,val)
            plugin.midRegionGain = val;
            
            % todo: Maybe I should update the setUpdate... filter plugins
            % to check the freq and Q when the update rather than doing it
            % here. Or have setUpdateRootFilter8 call updateRootGain8 from
            % within that. Then I don't have to manage gain and Q
            % directly...
            if (plugin.rootFrequency6 < plugin.midHighCrossoverFreq)
                updateRootGain6(plugin,val);
                setUpdateRootFilter6(plugin);
            end
            updateRootGain5(plugin,val);
            setUpdateRootFilter5(plugin);
            if (plugin.rootFrequency4 > plugin.lowMidCrossoverFreq)
                updateRootGain4(plugin,val);
                setUpdateRootFilter4(plugin);
            end
            
            if (plugin.thirdFrequency6 < plugin.midHighCrossoverFreq)
                updateThirdGain6(plugin,val);
                setUpdateThirdFilter6(plugin);
            end
            updateThirdGain5(plugin,val);
            setUpdateThirdFilter5(plugin);
            if (plugin.thirdFrequency4 > plugin.lowMidCrossoverFreq)
                updateThirdGain4(plugin,val);
                setUpdateThirdFilter4(plugin);
            end
            
            if (plugin.fifthFrequency6 < plugin.midHighCrossoverFreq)
                updateFifthGain6(plugin,val);
                setUpdateFifthFilter6(plugin);
            end
            updateFifthGain5(plugin,val);
            setUpdateFifthFilter5(plugin);
            if (plugin.fifthFrequency4 > plugin.lowMidCrossoverFreq)
                updateFifthGain4(plugin,val);
                setUpdateFifthFilter4(plugin);
            end
            
            if (plugin.seventhFrequency6 < plugin.midHighCrossoverFreq)
                updateSeventhGain6(plugin,val);
                setUpdateSeventhFilter6(plugin);
            end
            updateSeventhGain5(plugin,val);
            setUpdateSeventhFilter5(plugin);
            if (plugin.seventhFrequency4 > plugin.lowMidCrossoverFreq)
                updateSeventhGain4(plugin,val);
                setUpdateSeventhFilter4(plugin);
            end
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
            
        end
        
        function set.midRegionQFactor(plugin,val)
            plugin.midRegionQFactor = val;
            
            % todo: Maybe I should update the setUpdate... filter plugins
            % to check the freq and Q when the update rather than doing it
            % here. Or have setUpdateRootFilter8 call updateRootGain8 from
            % within that. Then I don't have to manage gain and Q
            % directly...
            if (plugin.rootFrequency6 < plugin.midHighCrossoverFreq)
                updateRootQFactor6(plugin,val);
                setUpdateRootFilter6(plugin);
            end
            updateRootQFactor5(plugin,val);
            setUpdateRootFilter5(plugin);
            if (plugin.rootFrequency4 > plugin.lowMidCrossoverFreq)
                updateRootQFactor4(plugin,val);
                setUpdateRootFilter4(plugin);
            end
            
            if (plugin.thirdFrequency6 < plugin.midHighCrossoverFreq)
                updateThirdQFactor6(plugin,val);
                setUpdateThirdFilter6(plugin);
            end
            updateThirdQFactor5(plugin,val);
            setUpdateThirdFilter5(plugin);
            if (plugin.thirdFrequency4 > plugin.lowMidCrossoverFreq)
                updateThirdQFactor4(plugin,val);
                setUpdateThirdFilter4(plugin);
            end
            
            if (plugin.fifthFrequency6 < plugin.midHighCrossoverFreq)
                updateFifthQFactor6(plugin,val);
                setUpdateFifthFilter6(plugin);
            end
            updateFifthQFactor5(plugin,val);
            setUpdateFifthFilter5(plugin);
            if (plugin.fifthFrequency4 > plugin.lowMidCrossoverFreq)
                updateFifthQFactor4(plugin,val);
                setUpdateFifthFilter4(plugin);
            end
            
            if (plugin.seventhFrequency6 < plugin.midHighCrossoverFreq)
                updateSeventhQFactor6(plugin,val);
                setUpdateSeventhFilter6(plugin);
            end
            updateSeventhQFactor5(plugin,val);
            setUpdateSeventhFilter5(plugin);
            if (plugin.seventhFrequency4 > plugin.lowMidCrossoverFreq)
                updateSeventhQFactor4(plugin,val);
                setUpdateSeventhFilter4(plugin);
            end
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        %----------------------Low-Mid Region Controls---------------------
        function set.lowMidRegionGain(plugin,val)
            plugin.lowMidRegionGain = val;
            
            % todo: Maybe I should update the setUpdate... filter plugins
            % to check the freq and Q when the update rather than doing it
            % here. Or have setUpdateRootFilter8 call updateRootGain8 from
            % within that. Then I don't have to manage gain and Q
            % directly...
            if (plugin.rootFrequency4 < plugin.lowMidCrossoverFreq)
                updateRootGain4(plugin,val);
                setUpdateRootFilter4(plugin);
            end
            updateRootGain3(plugin,val);
            %setUpdateRootFilter3(plugin); %todo: clean up?
            if (plugin.rootFrequency2 > plugin.lowCrossoverFreq)
                updateRootGain2(plugin,val);
            end
            
            if (plugin.thirdFrequency4 < plugin.lowMidCrossoverFreq)
                updateThirdGain4(plugin,val);
                setUpdateThirdFilter4(plugin);
            end
            updateThirdGain3(plugin,val);
            setUpdateThirdFilter3(plugin);
            if (plugin.thirdFrequency2 > plugin.lowCrossoverFreq)
                updateThirdGain2(plugin,val);
                setUpdateThirdFilter2(plugin);
            end
            
            if (plugin.fifthFrequency4 < plugin.lowMidCrossoverFreq)
                updateFifthGain4(plugin,val);
                setUpdateFifthFilter4(plugin);
            end
            updateFifthGain3(plugin,val);
            setUpdateFifthFilter3(plugin);
            if (plugin.fifthFrequency2 > plugin.lowCrossoverFreq)
                updateFifthGain2(plugin,val);
                setUpdateFifthFilter2(plugin);
            end
            
            if (plugin.seventhFrequency4 < plugin.lowMidCrossoverFreq)
                updateSeventhGain4(plugin,val);
                setUpdateSeventhFilter4(plugin);
            end
            updateSeventhGain3(plugin,val);
            setUpdateSeventhFilter3(plugin);
            if (plugin.seventhFrequency2 > plugin.lowCrossoverFreq)
                updateSeventhGain2(plugin,val);
                setUpdateSeventhFilter2(plugin);
            end
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
            
        end
        
        function set.lowMidRegionQFactor(plugin,val)
            plugin.lowMidRegionQFactor = val;
            
            % todo: Maybe I should update the setUpdate... filter plugins
            % to check the freq and Q when the update rather than doing it
            % here. Or have setUpdateRootFilter8 call updateRootGain8 from
            % within that. Then I don't have to manage gain and Q
            % directly...
            if (plugin.rootFrequency4 < plugin.lowMidCrossoverFreq)
                updateRootQFactor4(plugin,val);
                setUpdateRootFilter4(plugin);
            end
            updateRootQFactor3(plugin,val);
            setUpdateRootFilter3(plugin);
            if (plugin.rootFrequency2 > plugin.lowCrossoverFreq)
                updateRootQFactor2(plugin,val);
                setUpdateRootFilter2(plugin);
            end
            
            if (plugin.thirdFrequency4 < plugin.lowMidCrossoverFreq)
                updateThirdQFactor4(plugin,val);
                setUpdateThirdFilter4(plugin);
            end
            updateThirdQFactor3(plugin,val);
            setUpdateThirdFilter3(plugin);
            if (plugin.thirdFrequency2 > plugin.lowCrossoverFreq)
                updateThirdQFactor2(plugin,val);
                setUpdateThirdFilter2(plugin);
            end
            
            if (plugin.fifthFrequency4 < plugin.lowMidCrossoverFreq)
                updateFifthQFactor4(plugin,val);
                setUpdateFifthFilter4(plugin);
            end
            updateFifthQFactor3(plugin,val);
            setUpdateFifthFilter3(plugin);
            if (plugin.fifthFrequency2 > plugin.lowCrossoverFreq)
                updateFifthQFactor2(plugin,val);
                setUpdateFifthFilter2(plugin);
            end
            
            if (plugin.seventhFrequency4 < plugin.lowMidCrossoverFreq)
                updateSeventhQFactor4(plugin,val);
                setUpdateSeventhFilter4(plugin);
            end
            updateSeventhQFactor3(plugin,val);
            setUpdateSeventhFilter3(plugin);
            if (plugin.seventhFrequency2 > plugin.lowCrossoverFreq)
                updateSeventhQFactor2(plugin,val);
                setUpdateSeventhFilter2(plugin);
            end
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        
        %------------------------Low Region Controls-----------------------
        function set.lowRegionGain(plugin,val)
            plugin.lowRegionGain = val;
            
            % todo: Maybe I should update the setUpdate... filter plugins
            % to check the freq and Q when the update rather than doing it
            % here. Or have setUpdateRootFilter8 call updateRootGain8 from
            % within that. Then I don't have to manage gain and Q
            % directly...
            if (plugin.rootFrequency2 < plugin.lowCrossoverFreq)
                updateRootGain2(plugin,val);
            end
            updateRootGain1(plugin,val);
            
            if (plugin.thirdFrequency2 < plugin.lowCrossoverFreq)
                updateThirdGain2(plugin,val);
                setUpdateThirdFilter2(plugin);
            end
            updateThirdGain1(plugin,val);
            setUpdateThirdFilter1(plugin);
            
            if (plugin.fifthFrequency2 < plugin.lowCrossoverFreq)
                updateFifthGain2(plugin,val);
                setUpdateFifthFilter2(plugin);
            end
            updateFifthGain1(plugin,val);
            setUpdateFifthFilter1(plugin);
            
            if (plugin.seventhFrequency2 < plugin.lowCrossoverFreq)
                updateSeventhGain2(plugin,val);
                setUpdateSeventhFilter2(plugin);
            end
            updateSeventhGain1(plugin,val);
            setUpdateSeventhFilter1(plugin);
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
            
        end
        
        function set.lowRegionQFactor(plugin,val)
            plugin.lowRegionQFactor = val;
            
            % todo: Maybe I should update the setUpdate... filter plugins
            % to check the freq and Q when thet update rather than doing it
            % here. Or have setUpdateRootFilter8 call updateRootGain8 from
            % within that. Then I don't have to manage gain and Q
            % directly...
            
            %todo - can probably call updateRootFilter2Params here
            if (plugin.rootFrequency2 < plugin.lowCrossoverFreq)
                updateRootQFactor2(plugin,val);
                setUpdateRootFilter2(plugin);
            end
            updateRootQFactor1(plugin,val);
            setUpdateRootFilter1(plugin);
            
            if (plugin.thirdFrequency2 < plugin.lowCrossoverFreq)
                updateThirdQFactor2(plugin,val);
                setUpdateThirdFilter2(plugin);
            end
            updateThirdQFactor1(plugin,val);
            setUpdateThirdFilter1(plugin);
            
            if (plugin.fifthFrequency2 < plugin.lowCrossoverFreq)
                updateFifthQFactor2(plugin,val);
                setUpdateFifthFilter2(plugin);
            end
            updateFifthQFactor1(plugin,val);
            setUpdateFifthFilter1(plugin);
            
            if (plugin.seventhFrequency2 < plugin.lowCrossoverFreq)
                updateSeventhQFactor2(plugin,val);
                setUpdateSeventhFilter2(plugin);
            end
            updateSeventhQFactor1(plugin,val);
            setUpdateSeventhFilter1(plugin);
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        %------------------------Crossover controls------------------------
        function set.highCrossoverFreq(plugin,val)
            plugin.highCrossoverFreq = val;
            updateRootFilter8Params(plugin);
            updateThirdFilter8Params(plugin);
            updateFifthFilter8Params(plugin);
            updateSeventhFilter8Params(plugin);
        end
        
        function set.midHighCrossoverFreq(plugin,val)
            plugin.midHighCrossoverFreq = val;
            updateRootFilter6Params(plugin);
            updateThirdFilter6Params(plugin);
            updateFifthFilter6Params(plugin);
            updateSeventhFilter6Params(plugin);
        end
        
        function set.lowMidCrossoverFreq(plugin,val)
            plugin.lowMidCrossoverFreq = val;
            updateRootFilter4Params(plugin);
            updateThirdFilter4Params(plugin);
            updateFifthFilter4Params(plugin);
            updateSeventhFilter4Params(plugin);
        end
        
        function set.lowCrossoverFreq(plugin,val)
            plugin.lowCrossoverFreq = val;
            updateRootFilter2Params(plugin);
            updateThirdFilter2Params(plugin);
            updateFifthFilter2Params(plugin);
            updateSeventhFilter2Params(plugin);
        end
        
    end
    
    
    %----------------------------------------------------------------------
    % PRIVATE METHODS
    %----------------------------------------------------------------------
    methods (Access = private)
        
        %--------------------Design Filter Coefficients--------------------
        function [b, a] = peakNotchFilterCoeffs(~, fs, frequency, Q, gain)
            % prep
            Amp = 10.^(gain/40);
            omega0 = 2 * pi * frequency / fs;
            cos_omega = -2 * cos(omega0);
            alpha = sin(omega0) / (2  * Q);
            alpha_A = alpha * Amp;
            alpha_div_A = alpha / Amp;
            
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
            % Case: no smoothing active
            if ~plugin.rootFilter1GainSmooth && ~plugin.rootFilter1QSmooth
                [plugin.rootCoeffb1, plugin.rootCoeffa1] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency1,...
                    plugin.rootQFactor1,...
                    plugin.rootGain1);
                plugin.updateRootFilter1 = false; % No need to update further since no smoothing
            
            else % Case gain or q smoothing is active
                gain = plugin.rootGain1;
                qFactor = plugin.rootQFactor1;
                gainStep = plugin.rootFilter1GainStep;
                qStep = plugin.rootFilter1QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.rootFilter1GainDiff;
                    plugin.rootFilter1GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.rootGain1 = gain; % store updated gain value
                    
                elseif plugin.rootFilter1GainSmooth % Case: final step of gain smoothing
                    gain = plugin.rootFilter1GainTarget; %todo: Make sure this is safe, the target should be left alone after smoothing is complete...
                    plugin.rootGain1 = gain;
                    
                    plugin.rootFilter1GainDiff = 0;
                    plugin.rootFilter1GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.rootFilter1QDiff;
                    plugin.rootFilter1QStep = qStep + 1; %iterate q smooth step counter
                    plugin.rootQFactor1 = qFactor; % store updated q value
                    
                elseif plugin.rootFilter1QSmooth % Case: final step of q smoothing
                    qFactor = plugin.rootFilter1QTarget;
                    plugin.rootQFactor1 = qFactor;
                    
                    plugin.rootFilter1QDiff = 0;
                    plugin.rootFilter1QSmooth = false; % set q smoothing to false
                end
                
                [plugin.rootCoeffb1, plugin.rootCoeffa1] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency1,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildRootFilter2(plugin, fs)
            % Case: no smoothing active
            if ~plugin.rootFilter2GainSmooth && ~plugin.rootFilter2QSmooth
                [plugin.rootCoeffb2, plugin.rootCoeffa2] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency2,...
                    plugin.rootQFactor2,...
                    plugin.rootGain2);
                plugin.updateRootFilter2 = false; % No need to update further since no smoothing
            
            else % Case gain or q smoothing is active
                gain = plugin.rootGain2;
                qFactor = plugin.rootQFactor2;
                gainStep = plugin.rootFilter2GainStep;
                qStep = plugin.rootFilter2QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.rootFilter2GainDiff;
                    plugin.rootFilter2GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.rootGain2 = gain; % store updated gain value
                    
                else % Case: gain smoothing completed
                    gain = plugin.rootFilter2GainTarget; %todo: Make sure this is safe, the target should be left alone after smoothing is compplete...
                    plugin.rootGain2 = gain;
                    
                    plugin.rootFilter2GainDiff = 0;
                    plugin.rootFilter2GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.rootFilter2QDiff;
                    plugin.rootFilter2QStep = qStep + 1; %iterate q smooth step counter
                    plugin.rootQFactor2 = qFactor; % store updated q value
                else
                    qFactor = plugin.rootFilter2QTarget;
                    plugin.rootQFactor2 = qFactor;
                    
                    plugin.rootFilter2QDiff = 0;
                    plugin.rootFilter2QSmooth = false; % set q smoothing to false
                end
                
                [plugin.rootCoeffb2, plugin.rootCoeffa2] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.rootFrequency2,...
                        qFactor,...
                        gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildRootFilter3(plugin, fs)
            % Case: no smoothing active
            if ~plugin.rootFilter3GainSmooth && ~plugin.rootFilter3QSmooth
                [plugin.rootCoeffb3, plugin.rootCoeffa3] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency3,...
                    plugin.rootQFactor3,...
                    plugin.rootGain3);
                plugin.updateRootFilter3 = false; % No need to update further since no smoothing
            
            else % Case gain or q smoothing is active
                gain = plugin.rootGain3;
                qFactor = plugin.rootQFactor3;
                gainStep = plugin.rootFilter3GainStep;
                qStep = plugin.rootFilter3QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.rootFilter3GainDiff;
                    plugin.rootFilter3GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.rootGain3 = gain; % store updated gain value
                    
                elseif plugin.rootFilter3GainSmooth % Case: final step of gain smoothing
                    gain = plugin.rootFilter3GainTarget; %todo: Make sure this is safe, the target should be left alone after smoothing is complete...
                    plugin.rootGain3 = gain;
                    
                    plugin.rootFilter3GainDiff = 0;
                    plugin.rootFilter3GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.rootFilter3QDiff;
                    plugin.rootFilter3QStep = qStep + 1; %iterate q smooth step counter
                    plugin.rootQFactor3 = qFactor; % store updated q value
                    
                elseif plugin.rootFilter3QSmooth % Case: final step of q smoothing
                    qFactor = plugin.rootFilter3QTarget;
                    plugin.rootQFactor3 = qFactor;
                    
                    plugin.rootFilter3QDiff = 0;
                    plugin.rootFilter3QSmooth = false; % set q smoothing to false
                end
                
                [plugin.rootCoeffb3, plugin.rootCoeffa3] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency3,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildRootFilter4(plugin, fs)
            % Case: no smoothing active
            if ~plugin.rootFilter4GainSmooth && ~plugin.rootFilter4QSmooth
                [plugin.rootCoeffb4, plugin.rootCoeffa4] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency4,...
                    plugin.rootQFactor4,...
                    plugin.rootGain4);
                plugin.updateRootFilter4 = false; % No need to update further since no smoothing
            
            else % Case gain or q smoothing is active
                gain = plugin.rootGain4;
                qFactor = plugin.rootQFactor4;
                gainStep = plugin.rootFilter4GainStep;
                qStep = plugin.rootFilter4QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.rootFilter4GainDiff;
                    plugin.rootFilter4GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.rootGain4 = gain; % store updated gain value
                    
                elseif plugin.rootFilter4GainSmooth % Case: final step of gain smoothing
                    gain = plugin.rootFilter4GainTarget; %todo: Make sure this is safe, the target should be left alone after smoothing is complete...
                    plugin.rootGain4 = gain;
                    
                    plugin.rootFilter4GainDiff = 0;
                    plugin.rootFilter4GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.rootFilter4QDiff;
                    plugin.rootFilter4QStep = qStep + 1; %iterate q smooth step counter
                    plugin.rootQFactor4 = qFactor; % store updated q value
                    
                elseif plugin.rootFilter4QSmooth % Case: final step of q smoothing
                    qFactor = plugin.rootFilter4QTarget;
                    plugin.rootQFactor4 = qFactor;
                    
                    plugin.rootFilter4QDiff = 0;
                    plugin.rootFilter4QSmooth = false; % set q smoothing to false
                end
                
                [plugin.rootCoeffb4, plugin.rootCoeffa4] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency4,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildRootFilter5(plugin, fs)
            % Case: no smoothing active
            if ~plugin.rootFilter5GainSmooth && ~plugin.rootFilter5QSmooth
                [plugin.rootCoeffb5, plugin.rootCoeffa5] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency5,...
                    plugin.rootQFactor5,...
                    plugin.rootGain5);
                plugin.updateRootFilter5 = false; % No need to update further since no smoothing
            
            else % Case gain or q smoothing is active
                gain = plugin.rootGain5;
                qFactor = plugin.rootQFactor5;
                gainStep = plugin.rootFilter5GainStep;
                qStep = plugin.rootFilter5QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.rootFilter5GainDiff;
                    plugin.rootFilter5GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.rootGain5 = gain; % store updated gain value
                    
                elseif plugin.rootFilter5GainSmooth % Case: final step of gain smoothing
                    gain = plugin.rootFilter5GainTarget; %todo: Make sure this is safe, the target should be left alone after smoothing is complete...
                    plugin.rootGain5 = gain;
                    
                    plugin.rootFilter5GainDiff = 0;
                    plugin.rootFilter5GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.rootFilter5QDiff;
                    plugin.rootFilter5QStep = qStep + 1; %iterate q smooth step counter
                    plugin.rootQFactor5 = qFactor; % store updated q value
                    
                elseif plugin.rootFilter5QSmooth % Case: final step of q smoothing
                    qFactor = plugin.rootFilter5QTarget;
                    plugin.rootQFactor5 = qFactor;
                    
                    plugin.rootFilter5QDiff = 0;
                    plugin.rootFilter5QSmooth = false; % set q smoothing to false
                end
                
                [plugin.rootCoeffb5, plugin.rootCoeffa5] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency5,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        %test
        function buildRootFilter6(plugin, fs)
            % Case: no smoothing active
            if ~plugin.rootFilter6GainSmooth && ~plugin.rootFilter6QSmooth
                [plugin.rootCoeffb6, plugin.rootCoeffa6] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency6,...
                    plugin.rootQFactor6,...
                    plugin.rootGain6);
                plugin.updateRootFilter6 = false; % No need to update further since no smoothing
            
            else % Case gain or q smoothing is active
                gain = plugin.rootGain6;
                qFactor = plugin.rootQFactor6;
                gainStep = plugin.rootFilter6GainStep;
                qStep = plugin.rootFilter6QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.rootFilter6GainDiff;
                    plugin.rootFilter6GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.rootGain6 = gain; % store updated gain value
                    
                elseif plugin.rootFilter6GainSmooth % Case: final step of gain smoothing
                    gain = plugin.rootFilter6GainTarget; %todo: Make sure this is safe, the target should be left alone after smoothing is complete...
                    plugin.rootGain6 = gain;
                    
                    plugin.rootFilter6GainDiff = 0;
                    plugin.rootFilter6GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.rootFilter6QDiff;
                    plugin.rootFilter6QStep = qStep + 1; %iterate q smooth step counter
                    plugin.rootQFactor6 = qFactor; % store updated q value
                    
                elseif plugin.rootFilter6QSmooth % Case: final step of q smoothing
                    qFactor = plugin.rootFilter6QTarget;
                    plugin.rootQFactor6 = qFactor;
                    
                    plugin.rootFilter6QDiff = 0;
                    plugin.rootFilter6QSmooth = false; % set q smoothing to false
                end
                
                [plugin.rootCoeffb6, plugin.rootCoeffa6] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency6,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildRootFilter7(plugin, fs)
            % Case: no smoothing active
            if ~plugin.rootFilter7GainSmooth && ~plugin.rootFilter7QSmooth
                [plugin.rootCoeffb7, plugin.rootCoeffa7] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency7,...
                    plugin.rootQFactor7,...
                    plugin.rootGain7);
                plugin.updateRootFilter7 = false; % No need to update further since no smoothing
            
            else % Case gain or q smoothing is active
                gain = plugin.rootGain7;
                qFactor = plugin.rootQFactor7;
                gainStep = plugin.rootFilter7GainStep;
                qStep = plugin.rootFilter7QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.rootFilter7GainDiff;
                    plugin.rootFilter7GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.rootGain7 = gain; % store updated gain value
                    
                elseif plugin.rootFilter7GainSmooth % Case: final step of gain smoothing
                    gain = plugin.rootFilter7GainTarget; %todo: Make sure this is safe, the target should be left alone after smoothing is complete...
                    plugin.rootGain7 = gain;
                    
                    plugin.rootFilter7GainDiff = 0;
                    plugin.rootFilter7GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.rootFilter7QDiff;
                    plugin.rootFilter7QStep = qStep + 1; %iterate q smooth step counter
                    plugin.rootQFactor7 = qFactor; % store updated q value
                    
                elseif plugin.rootFilter7QSmooth % Case: final step of q smoothing
                    qFactor = plugin.rootFilter7QTarget;
                    plugin.rootQFactor7 = qFactor;
                    
                    plugin.rootFilter7QDiff = 0;
                    plugin.rootFilter7QSmooth = false; % set q smoothing to false
                end
                
                [plugin.rootCoeffb7, plugin.rootCoeffa7] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency7,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildRootFilter8(plugin, fs)
            % Case: no smoothing active
            if ~plugin.rootFilter8GainSmooth && ~plugin.rootFilter8QSmooth
                [plugin.rootCoeffb8, plugin.rootCoeffa8] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency8,...
                    plugin.rootQFactor8,...
                    plugin.rootGain8);
                plugin.updateRootFilter8 = false; % No need to update further since no smoothing
            
            else % Case gain or q smoothing is active
                gain = plugin.rootGain8;
                qFactor = plugin.rootQFactor8;
                gainStep = plugin.rootFilter8GainStep;
                qStep = plugin.rootFilter8QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.rootFilter8GainDiff;
                    plugin.rootFilter8GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.rootGain8 = gain; % store updated gain value
                    
                elseif plugin.rootFilter8GainSmooth % Case: final step of gain smoothing
                    gain = plugin.rootFilter8GainTarget; %todo: Make sure this is safe, the target should be left alone after smoothing is complete...
                    plugin.rootGain8 = gain;
                    
                    plugin.rootFilter8GainDiff = 0;
                    plugin.rootFilter8GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.rootFilter8QDiff;
                    plugin.rootFilter8QStep = qStep + 1; %iterate q smooth step counter
                    plugin.rootQFactor8 = qFactor; % store updated q value
                    
                elseif plugin.rootFilter8QSmooth % Case: final step of q smoothing
                    qFactor = plugin.rootFilter8QTarget;
                    plugin.rootQFactor8 = qFactor;
                    
                    plugin.rootFilter8QDiff = 0;
                    plugin.rootFilter8QSmooth = false; % set q smoothing to false
                end
                
                [plugin.rootCoeffb8, plugin.rootCoeffa8] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency8,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildRootFilter9(plugin, fs)
            % Case: no smoothing active
            if ~plugin.rootFilter9GainSmooth && ~plugin.rootFilter9QSmooth
                [plugin.rootCoeffb9, plugin.rootCoeffa9] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency9,...
                    plugin.rootQFactor9,...
                    plugin.rootGain9);
                plugin.updateRootFilter9 = false; % No need to update further since no smoothing
            
            else % Case gain or q smoothing is active
                gain = plugin.rootGain9;
                qFactor = plugin.rootQFactor9;
                gainStep = plugin.rootFilter9GainStep;
                qStep = plugin.rootFilter9QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.rootFilter9GainDiff;
                    plugin.rootFilter9GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.rootGain9 = gain; % store updated gain value
                    
                elseif plugin.rootFilter9GainSmooth % Case: final step of gain smoothing
                    gain = plugin.rootFilter9GainTarget; %todo: Make sure this is safe, the target should be left alone after smoothing is complete...
                    plugin.rootGain9 = gain;
                    
                    plugin.rootFilter9GainDiff = 0;
                    plugin.rootFilter9GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.rootFilter9QDiff;
                    plugin.rootFilter9QStep = qStep + 1; %iterate q smooth step counter
                    plugin.rootQFactor9 = qFactor; % store updated q value
                    
                elseif plugin.rootFilter9QSmooth % Case: final step of q smoothing
                    qFactor = plugin.rootFilter9QTarget;
                    plugin.rootQFactor9 = qFactor;
                    
                    plugin.rootFilter9QDiff = 0;
                    plugin.rootFilter9QSmooth = false; % set q smoothing to false
                end
                
                [plugin.rootCoeffb9, plugin.rootCoeffa9] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.rootFrequency9,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        %--------------------Harmonic third filters------------------------
        function buildThirdFilter1(plugin, fs)
            % Case: no smoothing active
            if ~plugin.thirdFilter1GainSmooth && ~plugin.thirdFilter1QSmooth
                [plugin.thirdCoeffb1, plugin.thirdCoeffa1] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency1,...
                    plugin.thirdQFactor1,...
                    plugin.thirdGain1);
                plugin.updateThirdFilter1 = false; % No need to update further since no smoothing
            
            else % Case gain or q smoothing is active
                gain = plugin.thirdGain1;
                qFactor = plugin.thirdQFactor1;
                gainStep = plugin.thirdFilter1GainStep;
                qStep = plugin.thirdFilter1QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.thirdFilter1GainDiff;
                    plugin.thirdFilter1GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.thirdGain1 = gain; % store updated gain value
                    
                elseif plugin.thirdFilter1GainSmooth % Case: final step of gain smoothing
                    gain = plugin.thirdFilter1GainTarget; %todo: Make sure this is safe, the target should be left alone after smoothing is complete...
                    plugin.thirdGain1 = gain;
                    
                    plugin.thirdFilter1GainDiff = 0;
                    plugin.thirdFilter1GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.thirdFilter1QDiff;
                    plugin.thirdFilter1QStep = qStep + 1; %iterate q smooth step counter
                    plugin.thirdQFactor1 = qFactor; % store updated q value
                    
                elseif plugin.thirdFilter1QSmooth % Case: final step of q smoothing
                    qFactor = plugin.thirdFilter1QTarget;
                    plugin.thirdQFactor1 = qFactor;
                    
                    plugin.thirdFilter1QDiff = 0;
                    plugin.thirdFilter1QSmooth = false; % set q smoothing to false
                end
                
                [plugin.thirdCoeffb1, plugin.thirdCoeffa1] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency1,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildThirdFilter2(plugin, fs)
            % Case: no smoothing active
            if ~plugin.thirdFilter2GainSmooth && ~plugin.thirdFilter2QSmooth
                [plugin.thirdCoeffb2, plugin.thirdCoeffa2] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency2,...
                    plugin.thirdQFactor2,...
                    plugin.thirdGain2);
                plugin.updateThirdFilter2 = false; % No need to update further since no smoothing
            
            else % Case gain or q smoothing is active
                gain = plugin.thirdGain2;
                qFactor = plugin.thirdQFactor2;
                gainStep = plugin.thirdFilter2GainStep;
                qStep = plugin.thirdFilter2QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.thirdFilter2GainDiff;
                    plugin.thirdFilter2GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.thirdGain2 = gain; % store updated gain value
                    
                elseif plugin.thirdFilter2GainSmooth % Case: final step of gain smoothing
                    gain = plugin.thirdFilter2GainTarget; %todo: Make sure this is safe, the target should be left alone after smoothing is complete...
                    plugin.thirdGain2 = gain;
                    
                    plugin.thirdFilter2GainDiff = 0;
                    plugin.thirdFilter2GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.thirdFilter2QDiff;
                    plugin.thirdFilter2QStep = qStep + 1; %iterate q smooth step counter
                    plugin.thirdQFactor2 = qFactor; % store updated q value
                    
                elseif plugin.thirdFilter2QSmooth % Case: final step of q smoothing
                    qFactor = plugin.thirdFilter2QTarget;
                    plugin.thirdQFactor2 = qFactor;
                    
                    plugin.thirdFilter2QDiff = 0;
                    plugin.thirdFilter2QSmooth = false; % set q smoothing to false
                end
                
                [plugin.thirdCoeffb2, plugin.thirdCoeffa2] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency2,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildThirdFilter3(plugin, fs)
            % Case: no smoothing active
            if ~plugin.thirdFilter3GainSmooth && ~plugin.thirdFilter3QSmooth
                [plugin.thirdCoeffb3, plugin.thirdCoeffa3] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency3,...
                    plugin.thirdQFactor3,...
                    plugin.thirdGain3);
                plugin.updateThirdFilter3 = false; % No need to update further since no smoothing
            
            else % Case gain or q smoothing is active
                gain = plugin.thirdGain3;
                qFactor = plugin.thirdQFactor3;
                gainStep = plugin.thirdFilter3GainStep;
                qStep = plugin.thirdFilter3QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.thirdFilter3GainDiff;
                    plugin.thirdFilter3GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.thirdGain3 = gain; % store updated gain value
                    
                elseif plugin.thirdFilter3GainSmooth % Case: final step of gain smoothing
                    gain = plugin.thirdFilter3GainTarget; %todo: Make sure this is safe, the target should be left alone after smoothing is complete...
                    plugin.thirdGain3 = gain;
                    
                    plugin.thirdFilter3GainDiff = 0;
                    plugin.thirdFilter3GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.thirdFilter3QDiff;
                    plugin.thirdFilter3QStep = qStep + 1; %iterate q smooth step counter
                    plugin.thirdQFactor3 = qFactor; % store updated q value
                    
                elseif plugin.thirdFilter3QSmooth % Case: final step of q smoothing
                    qFactor = plugin.thirdFilter3QTarget;
                    plugin.thirdQFactor3 = qFactor;
                    
                    plugin.thirdFilter3QDiff = 0;
                    plugin.thirdFilter3QSmooth = false; % set q smoothing to false
                end
                
                [plugin.thirdCoeffb3, plugin.thirdCoeffa3] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency3,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildThirdFilter4(plugin, fs)
            % Case: no smoothing active
            if ~plugin.thirdFilter4GainSmooth && ~plugin.thirdFilter4QSmooth
                [plugin.thirdCoeffb4, plugin.thirdCoeffa4] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency4,...
                    plugin.thirdQFactor4,...
                    plugin.thirdGain4);
                plugin.updateThirdFilter4 = false; % No need to update further since no smoothing
            
            else % Case gain or q smoothing is active
                gain = plugin.thirdGain4;
                qFactor = plugin.thirdQFactor4;
                gainStep = plugin.thirdFilter4GainStep;
                qStep = plugin.thirdFilter4QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.thirdFilter4GainDiff;
                    plugin.thirdFilter4GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.thirdGain4 = gain; % store updated gain value
                    
                elseif plugin.thirdFilter4GainSmooth % Case: final step of gain smoothing
                    gain = plugin.thirdFilter4GainTarget; %todo: Make sure this is safe, the target should be left alone after smoothing is complete...
                    plugin.thirdGain4 = gain;
                    
                    plugin.thirdFilter4GainDiff = 0;
                    plugin.thirdFilter4GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.thirdFilter4QDiff;
                    plugin.thirdFilter4QStep = qStep + 1; %iterate q smooth step counter
                    plugin.thirdQFactor4 = qFactor; % store updated q value
                    
                elseif plugin.thirdFilter4QSmooth % Case: final step of q smoothing
                    qFactor = plugin.thirdFilter4QTarget;
                    plugin.thirdQFactor4 = qFactor;
                    
                    plugin.thirdFilter4QDiff = 0;
                    plugin.thirdFilter4QSmooth = false; % set q smoothing to false
                end
                
                [plugin.thirdCoeffb4, plugin.thirdCoeffa4] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency4,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildThirdFilter5(plugin, fs)
            % Case: no smoothing active
            if ~plugin.thirdFilter5GainSmooth && ~plugin.thirdFilter5QSmooth
                [plugin.thirdCoeffb5, plugin.thirdCoeffa5] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency5,...
                    plugin.thirdQFactor5,...
                    plugin.thirdGain5);
                plugin.updateThirdFilter5 = false; % No need to update further since no smoothing
            
            else % Case gain or q smoothing is active
                gain = plugin.thirdGain5;
                qFactor = plugin.thirdQFactor5;
                gainStep = plugin.thirdFilter5GainStep;
                qStep = plugin.thirdFilter5QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.thirdFilter5GainDiff;
                    plugin.thirdFilter5GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.thirdGain5 = gain; % store updated gain value
                    
                elseif plugin.thirdFilter5GainSmooth % Case: final step of gain smoothing
                    gain = plugin.thirdFilter5GainTarget; %todo: Make sure this is safe, the target should be left alone after smoothing is complete...
                    plugin.thirdGain5 = gain;
                    
                    plugin.thirdFilter5GainDiff = 0;
                    plugin.thirdFilter5GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.thirdFilter5QDiff;
                    plugin.thirdFilter5QStep = qStep + 1; %iterate q smooth step counter
                    plugin.thirdQFactor5 = qFactor; % store updated q value
                    
                elseif plugin.thirdFilter5QSmooth % Case: final step of q smoothing
                    qFactor = plugin.thirdFilter5QTarget;
                    plugin.thirdQFactor5 = qFactor;
                    
                    plugin.thirdFilter5QDiff = 0;
                    plugin.thirdFilter5QSmooth = false; % set q smoothing to false
                end
                
                [plugin.thirdCoeffb5, plugin.thirdCoeffa5] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency5,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildThirdFilter6(plugin, fs)
            % Case: no smoothing active
            if ~plugin.thirdFilter6GainSmooth && ~plugin.thirdFilter6QSmooth
                [plugin.thirdCoeffb6, plugin.thirdCoeffa6] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency6,...
                    plugin.thirdQFactor6,...
                    plugin.thirdGain6);
                plugin.updateThirdFilter6 = false; % No need to update further since no smoothing
            
            else % Case gain or q smoothing is active
                gain = plugin.thirdGain6;
                qFactor = plugin.thirdQFactor6;
                gainStep = plugin.thirdFilter6GainStep;
                qStep = plugin.thirdFilter6QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.thirdFilter6GainDiff;
                    plugin.thirdFilter6GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.thirdGain6 = gain; % store updated gain value
                    
                elseif plugin.thirdFilter6GainSmooth % Case: final step of gain smoothing
                    gain = plugin.thirdFilter6GainTarget; %todo: Make sure this is safe, the target should be left alone after smoothing is complete...
                    plugin.thirdGain6 = gain;
                    
                    plugin.thirdFilter6GainDiff = 0;
                    plugin.thirdFilter6GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.thirdFilter6QDiff;
                    plugin.thirdFilter6QStep = qStep + 1; %iterate q smooth step counter
                    plugin.thirdQFactor6 = qFactor; % store updated q value
                    
                elseif plugin.thirdFilter6QSmooth % Case: final step of q smoothing
                    qFactor = plugin.thirdFilter6QTarget;
                    plugin.thirdQFactor6 = qFactor;
                    
                    plugin.thirdFilter6QDiff = 0;
                    plugin.thirdFilter6QSmooth = false; % set q smoothing to false
                end
                
                [plugin.thirdCoeffb6, plugin.thirdCoeffa6] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency6,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildThirdFilter7(plugin, fs)
            [plugin.thirdCoeffb7, plugin.thirdCoeffa7] = peakNotchFilterCoeffs(...
                plugin, fs, ...
                plugin.thirdFrequency7,...
                plugin.thirdQFactor7,...
                plugin.thirdGain7);
            plugin.updateThirdFilter7 = false;
        end
        
        %test
        function buildThirdFilter8(plugin, fs)
            if ~plugin.thirdFilter8SmoothStatus % No smoothing necessary
                [plugin.thirdCoeffb8, plugin.thirdCoeffa8] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency8,...
                    plugin.thirdQFactor8,...
                    plugin.thirdGain8);
                plugin.updateThirdFilter8 = false; % No need to update further since no smoothing
            else % Case: smoothing active
                gain = plugin.thirdGain8;
                qFactor = plugin.thirdQFactor8;
                step = plugin.thirdFilter8SmoothStep;
                if (step < plugin.numberOfSmoothSteps)
                    gain = gain + plugin.thirdFilter8GainDiff;
                    qFactor = qFactor + plugin.thirdFilter8QDiff;
                    
                    [plugin.thirdCoeffb8, plugin.thirdCoeffa8] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.thirdFrequency8,...
                        qFactor,...
                        gain);
                    
                    plugin.thirdFilter8SmoothStep = step + 1;
                    % Do not set updateThirdFilter8 to false because we want
                    % it to continue updating until we finish the smoothing
                    % operation
                    
                    plugin.thirdGain8 = gain; %store updated third gain
                    plugin.thirdQFactor8 = qFactor; % store updated Q value
                    
                    % Update visualizer
                    updateStateChangeStatus(plugin, true);
                else % Case: at the end of smoothing
                    gain = plugin.thirdFilter8GainTarget;
                    qFactor = plugin.thirdFilter8QTarget;
                    [plugin.thirdCoeffb8, plugin.thirdCoeffa8] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.thirdFrequency8,...
                        qFactor,...
                        gain);
                    plugin.thirdFilter8SmoothStatus = false;
                    plugin.updateThirdFilter8 = false; % No need to update further since smoothing complete
                    
                    plugin.thirdGain8 = gain; %store updated third gain
                    plugin.thirdQFactor8 = qFactor; % store updated Q value
                    updateStateChangeStatus(plugin, true);
                end
            end
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
            if ~plugin.fifthFilter2SmoothStatus % No smoothing necessary
                [plugin.fifthCoeffb2, plugin.fifthCoeffa2] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency2,...
                    plugin.fifthQFactor2,...
                    plugin.fifthGain2);
                plugin.updateFifthFilter2 = false; % No need to update further since no smoothing
            else % Case: smoothing active
                gain = plugin.fifthGain2;
                qFactor = plugin.fifthQFactor2;
                step = plugin.fifthFilter2SmoothStep;
                if (step < plugin.numberOfSmoothSteps)
                    gain = gain + plugin.fifthFilter2GainDiff;
                    qFactor = qFactor + plugin.fifthFilter2QDiff;
                    
                    [plugin.fifthCoeffb2, plugin.fifthCoeffa2] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.fifthFrequency2,...
                        qFactor,...
                        gain);
                    
                    plugin.fifthFilter2SmoothStep = step + 1;
                    % Do not set updateFifthFilter2 to false because we want
                    % it to continue updating until we finish the smoothing
                    % operation
                    
                    plugin.fifthGain2 = gain; %store updated fifth gain
                    plugin.fifthQFactor2 = qFactor; % store updated Q value
                    
                    % Update visualizer
                    updateStateChangeStatus(plugin, true);
                else % Case: at the end of smoothing
                    gain = plugin.fifthFilter2GainTarget;
                    qFactor = plugin.fifthFilter2QTarget;
                    [plugin.fifthCoeffb2, plugin.fifthCoeffa2] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.fifthFrequency2,...
                        qFactor,...
                        gain);
                    plugin.fifthFilter2SmoothStatus = false;
                    plugin.updateFifthFilter2 = false; % No need to update further since smoothing complete
                    
                    plugin.fifthGain2 = gain; %store updated fifth gain
                    plugin.fifthQFactor2 = qFactor; % store updated Q value
                    updateStateChangeStatus(plugin, true);
                end
            end
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
            if ~plugin.fifthFilter4SmoothStatus % No smoothing necessary
                [plugin.fifthCoeffb4, plugin.fifthCoeffa4] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency4,...
                    plugin.fifthQFactor4,...
                    plugin.fifthGain4);
                plugin.updateFifthFilter4 = false; % No need to update further since no smoothing
            else % Case: smoothing active
                gain = plugin.fifthGain4;
                qFactor = plugin.fifthQFactor4;
                step = plugin.fifthFilter4SmoothStep;
                if (step < plugin.numberOfSmoothSteps)
                    gain = gain + plugin.fifthFilter4GainDiff;
                    qFactor = qFactor + plugin.fifthFilter4QDiff;
                    
                    [plugin.fifthCoeffb4, plugin.fifthCoeffa4] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.fifthFrequency4,...
                        qFactor,...
                        gain);
                    
                    plugin.fifthFilter4SmoothStep = step + 1;
                    % Do not set updateFifthFilter4 to false because we want
                    % it to continue updating until we finish the smoothing
                    % operation
                    
                    plugin.fifthGain4 = gain; %store updated fifth gain
                    plugin.fifthQFactor4 = qFactor; % store updated Q value
                    
                    % Update visualizer
                    updateStateChangeStatus(plugin, true);
                else % Case: at the end of smoothing
                    gain = plugin.fifthFilter4GainTarget;
                    qFactor = plugin.fifthFilter4QTarget;
                    [plugin.fifthCoeffb4, plugin.fifthCoeffa4] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.fifthFrequency4,...
                        qFactor,...
                        gain);
                    plugin.fifthFilter4SmoothStatus = false;
                    plugin.updateFifthFilter4 = false; % No need to update further since smoothing complete
                    
                    plugin.fifthGain4 = gain; %store updated fifth gain
                    plugin.fifthQFactor4 = qFactor; % store updated Q value
                    updateStateChangeStatus(plugin, true);
                end
            end
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
            if ~plugin.fifthFilter6SmoothStatus % No smoothing necessary
                [plugin.fifthCoeffb6, plugin.fifthCoeffa6] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency6,...
                    plugin.fifthQFactor6,...
                    plugin.fifthGain6);
                plugin.updateFifthFilter6 = false; % No need to update further since no smoothing
            else % Case: smoothing active
                gain = plugin.fifthGain6;
                qFactor = plugin.fifthQFactor6;
                step = plugin.fifthFilter6SmoothStep;
                if (step < plugin.numberOfSmoothSteps)
                    gain = gain + plugin.fifthFilter6GainDiff;
                    qFactor = qFactor + plugin.fifthFilter6QDiff;
                    
                    [plugin.fifthCoeffb6, plugin.fifthCoeffa6] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.fifthFrequency6,...
                        qFactor,...
                        gain);
                    
                    plugin.fifthFilter6SmoothStep = step + 1;
                    % Do not set updateFifthFilter6 to false because we want
                    % it to continue updating until we finish the smoothing
                    % operation
                    
                    plugin.fifthGain6 = gain; %store updated fifth gain
                    plugin.fifthQFactor6 = qFactor; % store updated Q value
                    
                    % Update visualizer
                    updateStateChangeStatus(plugin, true);
                else % Case: at the end of smoothing
                    gain = plugin.fifthFilter6GainTarget;
                    qFactor = plugin.fifthFilter6QTarget;
                    [plugin.fifthCoeffb6, plugin.fifthCoeffa6] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.fifthFrequency6,...
                        qFactor,...
                        gain);
                    plugin.fifthFilter6SmoothStatus = false;
                    plugin.updateFifthFilter6 = false; % No need to update further since smoothing complete
                    
                    plugin.fifthGain6 = gain; %store updated fifth gain
                    plugin.fifthQFactor6 = qFactor; % store updated Q value
                    updateStateChangeStatus(plugin, true);
                end
            end
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
            if ~plugin.fifthFilter8SmoothStatus % No smoothing necessary
                [plugin.fifthCoeffb8, plugin.fifthCoeffa8] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency8,...
                    plugin.fifthQFactor8,...
                    plugin.fifthGain8);
                plugin.updateFifthFilter8 = false; % No need to update further since no smoothing
            else % Case: smoothing active
                gain = plugin.fifthGain8;
                qFactor = plugin.fifthQFactor8;
                step = plugin.fifthFilter8SmoothStep;
                if (step < plugin.numberOfSmoothSteps)
                    gain = gain + plugin.fifthFilter8GainDiff;
                    qFactor = qFactor + plugin.fifthFilter8QDiff;
                    
                    [plugin.fifthCoeffb8, plugin.fifthCoeffa8] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.fifthFrequency8,...
                        qFactor,...
                        gain);
                    
                    plugin.fifthFilter8SmoothStep = step + 1;
                    % Do not set updateFifthFilter8 to false because we want
                    % it to continue updating until we finish the smoothing
                    % operation
                    
                    plugin.fifthGain8 = gain; %store updated fifth gain
                    plugin.fifthQFactor8 = qFactor; % store updated Q value
                    
                    % Update visualizer
                    updateStateChangeStatus(plugin, true);
                else % Case: at the end of smoothing
                    gain = plugin.fifthFilter8GainTarget;
                    qFactor = plugin.fifthFilter8QTarget;
                    [plugin.fifthCoeffb8, plugin.fifthCoeffa8] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.fifthFrequency8,...
                        qFactor,...
                        gain);
                    plugin.fifthFilter8SmoothStatus = false;
                    plugin.updateFifthFilter8 = false; % No need to update further since smoothing complete
                    
                    plugin.fifthGain8 = gain; %store updated fifth gain
                    plugin.fifthQFactor8 = qFactor; % store updated Q value
                    updateStateChangeStatus(plugin, true);
                end
            end
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
            if ~plugin.seventhFilter2SmoothStatus % No smoothing necessary
                [plugin.seventhCoeffb2, plugin.seventhCoeffa2] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency2,...
                    plugin.seventhQFactor2,...
                    plugin.seventhGain2);
                plugin.updateSeventhFilter2 = false; % No need to update further since no smoothing
            else % Case: smoothing active
                gain = plugin.seventhGain2;
                qFactor = plugin.seventhQFactor2;
                step = plugin.seventhFilter2SmoothStep;
                if (step < plugin.numberOfSmoothSteps)
                    gain = gain + plugin.seventhFilter2GainDiff;
                    qFactor = qFactor + plugin.seventhFilter2QDiff;
                    
                    [plugin.seventhCoeffb2, plugin.seventhCoeffa2] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.seventhFrequency2,...
                        qFactor,...
                        gain);
                    
                    plugin.seventhFilter2SmoothStep = step + 1;
                    % Do not set updateSeventhFilter2 to false because we want
                    % it to continue updating until we finish the smoothing
                    % operation
                    
                    plugin.seventhGain2 = gain; %store updated seventh gain
                    plugin.seventhQFactor2 = qFactor; % store updated Q value
                    
                    % Update visualizer
                    updateStateChangeStatus(plugin, true);
                else % Case: at the end of smoothing
                    gain = plugin.seventhFilter2GainTarget;
                    qFactor = plugin.seventhFilter2QTarget;
                    [plugin.seventhCoeffb2, plugin.seventhCoeffa2] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.seventhFrequency2,...
                        qFactor,...
                        gain);
                    plugin.seventhFilter2SmoothStatus = false;
                    plugin.updateSeventhFilter2 = false; % No need to update further since smoothing complete
                    
                    plugin.seventhGain2 = gain; %store updated seventh gain
                    plugin.seventhQFactor2 = qFactor; % store updated Q value
                    updateStateChangeStatus(plugin, true);
                end
            end
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
            if ~plugin.seventhFilter4SmoothStatus % No smoothing necessary
                [plugin.seventhCoeffb4, plugin.seventhCoeffa4] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency4,...
                    plugin.seventhQFactor4,...
                    plugin.seventhGain4);
                plugin.updateSeventhFilter4 = false; % No need to update further since no smoothing
            else % Case: smoothing active
                gain = plugin.seventhGain4;
                qFactor = plugin.seventhQFactor4;
                step = plugin.seventhFilter4SmoothStep;
                if (step < plugin.numberOfSmoothSteps)
                    gain = gain + plugin.seventhFilter4GainDiff;
                    qFactor = qFactor + plugin.seventhFilter4QDiff;
                    
                    [plugin.seventhCoeffb4, plugin.seventhCoeffa4] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.seventhFrequency4,...
                        qFactor,...
                        gain);
                    
                    plugin.seventhFilter4SmoothStep = step + 1;
                    % Do not set updateSeventhFilter4 to false because we want
                    % it to continue updating until we finish the smoothing
                    % operation
                    
                    plugin.seventhGain4 = gain; %store updated seventh gain
                    plugin.seventhQFactor4 = qFactor; % store updated Q value
                    
                    % Update visualizer
                    updateStateChangeStatus(plugin, true);
                else % Case: at the end of smoothing
                    gain = plugin.seventhFilter4GainTarget;
                    qFactor = plugin.seventhFilter4QTarget;
                    [plugin.seventhCoeffb4, plugin.seventhCoeffa4] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.seventhFrequency4,...
                        qFactor,...
                        gain);
                    plugin.seventhFilter4SmoothStatus = false;
                    plugin.updateSeventhFilter4 = false; % No need to update further since smoothing complete
                    
                    plugin.seventhGain4 = gain; %store updated seventh gain
                    plugin.seventhQFactor4 = qFactor; % store updated Q value
                    updateStateChangeStatus(plugin, true);
                end
            end
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
            if ~plugin.seventhFilter6SmoothStatus % No smoothing necessary
                [plugin.seventhCoeffb6, plugin.seventhCoeffa6] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency6,...
                    plugin.seventhQFactor6,...
                    plugin.seventhGain6);
                plugin.updateSeventhFilter6 = false; % No need to update further since no smoothing
            else % Case: smoothing active
                gain = plugin.seventhGain6;
                qFactor = plugin.seventhQFactor6;
                step = plugin.seventhFilter6SmoothStep;
                if (step < plugin.numberOfSmoothSteps)
                    gain = gain + plugin.seventhFilter6GainDiff;
                    qFactor = qFactor + plugin.seventhFilter6QDiff;
                    
                    [plugin.seventhCoeffb6, plugin.seventhCoeffa6] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.seventhFrequency6,...
                        qFactor,...
                        gain);
                    
                    plugin.seventhFilter6SmoothStep = step + 1;
                    % Do not set updateSeventhFilter6 to false because we want
                    % it to continue updating until we finish the smoothing
                    % operation
                    
                    plugin.seventhGain6 = gain; %store updated seventh gain
                    plugin.seventhQFactor6 = qFactor; % store updated Q value
                    
                    % Update visualizer
                    updateStateChangeStatus(plugin, true);
                else % Case: at the end of smoothing
                    gain = plugin.seventhFilter6GainTarget;
                    qFactor = plugin.seventhFilter6QTarget;
                    [plugin.seventhCoeffb6, plugin.seventhCoeffa6] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.seventhFrequency6,...
                        qFactor,...
                        gain);
                    plugin.seventhFilter6SmoothStatus = false;
                    plugin.updateSeventhFilter6 = false; % No need to update further since smoothing complete
                    
                    plugin.seventhGain6 = gain; %store updated seventh gain
                    plugin.seventhQFactor6 = qFactor; % store updated Q value
                    updateStateChangeStatus(plugin, true);
                end
            end
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
            if ~plugin.seventhFilter8SmoothStatus % No smoothing necessary
                [plugin.seventhCoeffb8, plugin.seventhCoeffa8] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency8,...
                    plugin.seventhQFactor8,...
                    plugin.seventhGain8);
                plugin.updateSeventhFilter8 = false; % No need to update further since no smoothing
            else % Case: smoothing active
                gain = plugin.seventhGain8;
                qFactor = plugin.seventhQFactor8;
                step = plugin.seventhFilter8SmoothStep;
                if (step < plugin.numberOfSmoothSteps)
                    gain = gain + plugin.seventhFilter8GainDiff;
                    qFactor = qFactor + plugin.seventhFilter8QDiff;
                    
                    [plugin.seventhCoeffb8, plugin.seventhCoeffa8] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.seventhFrequency8,...
                        qFactor,...
                        gain);
                    
                    plugin.seventhFilter8SmoothStep = step + 1;
                    % Do not set updateSeventhFilter8 to false because we want
                    % it to continue updating until we finish the smoothing
                    % operation
                    
                    plugin.seventhGain8 = gain; %store updated seventh gain
                    plugin.seventhQFactor8 = qFactor; % store updated Q value
                    
                    % Update visualizer
                    updateStateChangeStatus(plugin, true);
                else % Case: at the end of smoothing
                    gain = plugin.seventhFilter8GainTarget;
                    qFactor = plugin.seventhFilter8QTarget;
                    [plugin.seventhCoeffb8, plugin.seventhCoeffa8] = peakNotchFilterCoeffs(...
                        plugin, fs, ...
                        plugin.seventhFrequency8,...
                        qFactor,...
                        gain);
                    plugin.seventhFilter8SmoothStatus = false;
                    plugin.updateSeventhFilter8 = false; % No need to update further since smoothing complete
                    
                    plugin.seventhGain8 = gain; %store updated seventh gain
                    plugin.seventhQFactor8 = qFactor; % store updated Q value
                    updateStateChangeStatus(plugin, true);
                end
            end
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
        
        %todo: This can probably just call updateRoot2Gain() and
        %updateRoot2Q()...
        %test: don't need to track region right now...
        function updateRootFilter2Params(plugin)
            if plugin.rootFrequency2 < plugin.lowCrossoverFreq % root filter 2 is in low control region
                %plugin.rootFilter2Region = 1; % set filter region to low
                %(1) %todo: not currently using this; remove
                plugin.rootFilter2GainTarget = plugin.lowRegionGain;
                gainDiff = plugin.lowRegionGain - plugin.rootGain2; % set differential for gain
                plugin.rootFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                
                plugin.rootFilter2QTarget = plugin.lowRegionQFactor;
                qDiff = plugin.lowRegionQFactor - plugin.rootQFactor2;
                plugin.rootFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
                
                %todo: convert to individual smoothing for gain and q
                %plugin.rootFilter2SmoothStep = 0; % Reset the step counter for smoothing
                %plugin.rootFilter2SmoothStatus = true; % Activate gain smoothing
                
                plugin.rootFilter2GainStep = 0;
                plugin.rootFilter2GainSmooth = true;
                plugin.rootFilter2QStep = 0;
                plugin.rootFilter2QSmooth = true;
                
                % Updating plugin.rootGain2 will be taken care of by
                % buildRootFilter2()
                
            else % then root filter 2 is in mid-low control region
                %plugin.rootFilter2Region = 2; % set filter region to low
                %(1) %todo: not currently using this; remove
                plugin.rootFilter2GainTarget = plugin.lowMidRegionGain;
                gainDiff = plugin.lowMidRegionGain - plugin.rootGain2; % set differential for gain
                plugin.rootFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                
                plugin.rootFilter2QTarget = plugin.lowMidRegionQFactor;
                qDiff = plugin.lowMidRegionQFactor - plugin.rootQFactor2;
                plugin.rootFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
                
                %todo: clean up
                %plugin.rootFilter2SmoothStep = 0; % Reset the step counter for smoothing
                %plugin.rootFilter2SmoothStatus = true; % Activate gain smoothing
                
                plugin.rootFilter2GainStep = 0;
                plugin.rootFilter2GainSmooth = true;
                plugin.rootFilter2QStep = 0;
                plugin.rootFilter2QSmooth = true;
                
                % Updating plugin.rootGain2 will be taken care of by
                % buildRootFilter2()
            end
            setUpdateRootFilter2(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootFilter4Params(plugin)
            if plugin.rootFrequency4 < plugin.lowMidCrossoverFreq % root filter 4 is in low-mid control region
                %plugin.rootFilter4Region = 2; % set filter region to low (2) %todo: Unnecessary now? delete?
                plugin.rootFilter4GainTarget = plugin.lowMidRegionGain;
                gainDiff = plugin.lowMidRegionGain - plugin.rootGain4; % set differential for gain
                plugin.rootFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                
                plugin.rootFilter4QTarget = plugin.lowMidRegionQFactor;
                qDiff = plugin.lowMidRegionQFactor - plugin.rootQFactor4;
                plugin.rootFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
                
                %todo: convert to individual smoothing for gain and q
                %plugin.rootFilter4SmoothStep = 0; % Reset the step counter for smoothing
                %plugin.rootFilter4SmoothStatus = true; % Activate gain smoothing
                
                plugin.rootFilter4GainStep = 0;
                plugin.rootFilter4GainSmooth = true;
                plugin.rootFilter4QStep = 0;
                plugin.rootFilter4QSmooth = true;
                
                % Updating plugin.rootGain4 will be taken care of by
                % buildRootFilter4()
                
            else % then root filter 4 is in mid control region
                %plugin.rootFilter4Region = 3; % set filter region to mid (3) %todo: delete?
                plugin.rootFilter4GainTarget = plugin.midRegionGain;
                gainDiff = plugin.midRegionGain - plugin.rootGain4; % set differential for gain
                plugin.rootFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                
                plugin.rootFilter4QTarget = plugin.midRegionQFactor;
                qDiff = plugin.midRegionQFactor - plugin.rootQFactor4;
                plugin.rootFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
                
                %todo: clean up
                %plugin.rootFilter4SmoothStep = 0; % Reset the step counter for smoothing
                %plugin.rootFilter4SmoothStatus = true; % Activate gain smoothing
                
                plugin.rootFilter4GainStep = 0;
                plugin.rootFilter4GainSmooth = true;
                plugin.rootFilter4QStep = 0;
                plugin.rootFilter4QSmooth = true;
                
                % Updating plugin.rootGain4 will be taken care of by
                % buildRootFilter4()
            end
            setUpdateRootFilter4(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootFilter6Params(plugin)
            if plugin.rootFrequency6 < plugin.midHighCrossoverFreq % root filter 6 is in mid control region
                %plugin.rootFilter6Region = 3; % set filter region to low (2) %todo: Unnecessary now? delete?
                plugin.rootFilter6GainTarget = plugin.midRegionGain;
                gainDiff = plugin.midRegionGain - plugin.rootGain6; % set differential for gain
                plugin.rootFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                
                plugin.rootFilter6QTarget = plugin.midRegionQFactor;
                qDiff = plugin.midRegionQFactor - plugin.rootQFactor6;
                plugin.rootFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
                
                %todo: convert to individual smoothing for gain and q
                %plugin.rootFilter6SmoothStep = 0; % Reset the step counter for smoothing
                %plugin.rootFilter6SmoothStatus = true; % Activate gain smoothing
                
                plugin.rootFilter6GainStep = 0;
                plugin.rootFilter6GainSmooth = true;
                plugin.rootFilter6QStep = 0;
                plugin.rootFilter6QSmooth = true;
                
                % Updating plugin.rootGain6 will be taken care of by
                % buildRootFilter6()
                
            else % then root filter 6 is in high-mid control region
                %plugin.rootFilter6Region = 4; % set filter region to mid (3) %todo: delete?
                plugin.rootFilter6GainTarget = plugin.highMidRegionGain;
                gainDiff = plugin.highMidRegionGain - plugin.rootGain6; % set differential for gain
                plugin.rootFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                
                plugin.rootFilter6QTarget = plugin.highMidRegionQFactor;
                qDiff = plugin.highMidRegionQFactor - plugin.rootQFactor6;
                plugin.rootFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
                
                %todo: clean up
                %plugin.rootFilter6SmoothStep = 0; % Reset the step counter for smoothing
                %plugin.rootFilter6SmoothStatus = true; % Activate gain smoothing
                
                plugin.rootFilter6GainStep = 0;
                plugin.rootFilter6GainSmooth = true;
                plugin.rootFilter6QStep = 0;
                plugin.rootFilter6QSmooth = true;
                
                % Updating plugin.rootGain6 will be taken care of by
                % buildRootFilter6()
            end
            setUpdateRootFilter6(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootFilter8Params(plugin)
            if plugin.rootFrequency8 < plugin.highCrossoverFreq % root filter 8 is in high-mid control region
                %plugin.rootFilter8Region = 4; % set filter region to high-mid (4) %todo: Unnecessary now? delete?
                plugin.rootFilter8GainTarget = plugin.highMidRegionGain;
                gainDiff = plugin.highMidRegionGain - plugin.rootGain8; % set differential for gain
                plugin.rootFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                
                plugin.rootFilter8QTarget = plugin.highMidRegionQFactor;
                qDiff = plugin.highMidRegionQFactor - plugin.rootQFactor8;
                plugin.rootFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
                
                %todo: convert to individual smoothing for gain and q
                %plugin.rootFilter8SmoothStep = 0; % Reset the step counter for smoothing
                %plugin.rootFilter8SmoothStatus = true; % Activate gain smoothing
                
                plugin.rootFilter8GainStep = 0;
                plugin.rootFilter8GainSmooth = true;
                plugin.rootFilter8QStep = 0;
                plugin.rootFilter8QSmooth = true;
                
                % Updating plugin.rootGain8 will be taken care of by
                % buildRootFilter8()
                
            else % then root filter 8 is in high control region
                %plugin.rootFilter8Region = 5; % set filter region to high (5) %todo: delete?
                plugin.rootFilter8GainTarget = plugin.highRegionGain;
                gainDiff = plugin.highRegionGain - plugin.rootGain8; % set differential for gain
                plugin.rootFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                
                plugin.rootFilter8QTarget = plugin.highRegionQFactor;
                qDiff = plugin.highRegionQFactor - plugin.rootQFactor8;
                plugin.rootFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
                
                %todo: clean up
                %plugin.rootFilter8SmoothStep = 0; % Reset the step counter for smoothing
                %plugin.rootFilter8SmoothStatus = true; % Activate gain smoothing
                
                plugin.rootFilter8GainStep = 0;
                plugin.rootFilter8GainSmooth = true;
                plugin.rootFilter8QStep = 0;
                plugin.rootFilter8QSmooth = true;
                
                % Updating plugin.rootGain8 will be taken care of by
                % buildRootFilter8()
            end
            setUpdateRootFilter8(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        
        
        function updateRootGain1(plugin,val)
            plugin.rootFilter1GainTarget = val;
            gainDiff = val - plugin.rootGain1; % set differential for gain
            plugin.rootFilter1GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter1GainStep = 0;
            plugin.rootFilter1GainSmooth = true;
            
            setUpdateRootFilter1(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootGain2(plugin,val)
            plugin.rootFilter2GainTarget = val;
            gainDiff = val - plugin.rootGain2; % set differential for gain
            plugin.rootFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter2GainStep = 0;
            plugin.rootFilter2GainSmooth = true;
            
            setUpdateRootFilter2(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootGain3(plugin,val)
            plugin.rootFilter3GainTarget = val;
            gainDiff = val - plugin.rootGain3; % set differential for gain
            plugin.rootFilter3GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter3GainStep = 0;
            plugin.rootFilter3GainSmooth = true;
            
            setUpdateRootFilter3(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootGain4(plugin,val)
            plugin.rootFilter4GainTarget = val;
            gainDiff = val - plugin.rootGain4; % set differential for gain
            plugin.rootFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter4GainStep = 0;
            plugin.rootFilter4GainSmooth = true;
            
            setUpdateRootFilter4(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootGain5(plugin,val)
            plugin.rootFilter5GainTarget = val;
            gainDiff = val - plugin.rootGain5; % set differential for gain
            plugin.rootFilter5GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter5GainStep = 0;
            plugin.rootFilter5GainSmooth = true;
            
            setUpdateRootFilter5(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootGain6(plugin,val)
            plugin.rootFilter6GainTarget = val;
            gainDiff = val - plugin.rootGain6; % set differential for gain
            plugin.rootFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter6GainStep = 0;
            plugin.rootFilter6GainSmooth = true;
            
            setUpdateRootFilter6(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootGain7(plugin,val)
            plugin.rootFilter7GainTarget = val;
            gainDiff = val - plugin.rootGain7; % set differential for gain
            plugin.rootFilter7GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter7GainStep = 0;
            plugin.rootFilter7GainSmooth = true;
            
            setUpdateRootFilter7(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        %test
        function updateRootGain8(plugin,val)
            plugin.rootFilter8GainTarget = val;
            gainDiff = val - plugin.rootGain8; % set differential for gain
            plugin.rootFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter8GainStep = 0;
            plugin.rootFilter8GainSmooth = true;
            
            setUpdateRootFilter8(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootGain9(plugin,val)
            plugin.rootFilter9GainTarget = val;
            gainDiff = val - plugin.rootGain9; % set differential for gain
            plugin.rootFilter9GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter9GainStep = 0;
            plugin.rootFilter9GainSmooth = true;
            
            setUpdateRootFilter9(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootQFactor1(plugin,val)
            plugin.rootFilter1QTarget = val;
            qDiff = val - plugin.rootQFactor1; % set differential for q
            plugin.rootFilter1QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter1QStep = 0;
            plugin.rootFilter1QSmooth = true;
            
            setUpdateRootFilter1(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        %test
        function updateRootQFactor2(plugin,val)
            plugin.rootFilter2QTarget = val;
            qDiff = val - plugin.rootQFactor2; % set differential for q
            plugin.rootFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter2QStep = 0;
            plugin.rootFilter2QSmooth = true;
            
            setUpdateRootFilter2(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootQFactor3(plugin,val)
            plugin.rootFilter3QTarget = val;
            qDiff = val - plugin.rootQFactor3; % set differential for q
            plugin.rootFilter3QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter3QStep = 0;
            plugin.rootFilter3QSmooth = true;
            
            setUpdateRootFilter3(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootQFactor4(plugin,val)
            plugin.rootFilter4QTarget = val;
            qDiff = val - plugin.rootQFactor4; % set differential for q
            plugin.rootFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter4QStep = 0;
            plugin.rootFilter4QSmooth = true;
            
            setUpdateRootFilter4(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootQFactor5(plugin,val)
            plugin.rootFilter5QTarget = val;
            qDiff = val - plugin.rootQFactor5; % set differential for q
            plugin.rootFilter5QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter5QStep = 0;
            plugin.rootFilter5QSmooth = true;
            
            setUpdateRootFilter5(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootQFactor6(plugin,val)
            plugin.rootFilter6QTarget = val;
            qDiff = val - plugin.rootQFactor6; % set differential for q
            plugin.rootFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter6QStep = 0;
            plugin.rootFilter6QSmooth = true;
            
            setUpdateRootFilter6(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootQFactor7(plugin,val)
            plugin.rootFilter7QTarget = val;
            qDiff = val - plugin.rootQFactor7; % set differential for q
            plugin.rootFilter7QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter7QStep = 0;
            plugin.rootFilter7QSmooth = true;
            
            setUpdateRootFilter7(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootQFactor8(plugin,val)
            plugin.rootFilter8QTarget = val;
            qDiff = val - plugin.rootQFactor8; % set differential for q
            plugin.rootFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter8QStep = 0;
            plugin.rootFilter8QSmooth = true;
            
            setUpdateRootFilter8(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootQFactor9(plugin,val)
            plugin.rootFilter9QTarget = val;
            qDiff = val - plugin.rootQFactor9; % set differential for q
            plugin.rootFilter9QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.rootFilter9QStep = 0;
            plugin.rootFilter9QSmooth = true;
            
            setUpdateRootFilter9(plugin);
            updateStateChangeStatus(plugin, true);
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
            updateStateChangeStatus(plugin, true)
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
        
        function updateThirdFilter2Params(plugin)
            if plugin.thirdFrequency2 < plugin.lowCrossoverFreq % third filter 2 is in low control region
                plugin.thirdFilter2GainTarget = plugin.lowRegionGain;
                gainDiff = plugin.lowRegionGain - plugin.thirdGain2; % set differential for gain
                plugin.thirdFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                
                plugin.thirdFilter2QTarget = plugin.lowRegionQFactor;
                qDiff = plugin.lowRegionQFactor - plugin.thirdQFactor2;
                plugin.thirdFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
                
                plugin.thirdFilter2GainStep = 0;
                plugin.thirdFilter2GainSmooth = true;
                plugin.thirdFilter2QStep = 0;
                plugin.thirdFilter2QSmooth = true;
                
                % Updating plugin.thirdGain2 will be taken care of by
                % buildThirdFilter2()
                
            else % then third filter 2 is in mid-low control region
                plugin.thirdFilter2GainTarget = plugin.lowMidRegionGain;
                gainDiff = plugin.lowMidRegionGain - plugin.thirdGain2; % set differential for gain
                plugin.thirdFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                
                plugin.thirdFilter2QTarget = plugin.lowMidRegionQFactor;
                qDiff = plugin.lowMidRegionQFactor - plugin.thirdQFactor2;
                plugin.thirdFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
                
                plugin.thirdFilter2GainStep = 0;
                plugin.thirdFilter2GainSmooth = true;
                plugin.thirdFilter2QStep = 0;
                plugin.thirdFilter2QSmooth = true;
                
                % Updating plugin.thirdGain2 will be taken care of by
                % buildThirdFilter2()
            end
            setUpdateThirdFilter2(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdFilter4Params(plugin)
            if plugin.thirdFrequency4 < plugin.lowMidCrossoverFreq % third filter 4 is in low-mid control region
                plugin.thirdFilter4GainTarget = plugin.lowMidRegionGain;
                gainDiff = plugin.lowMidRegionGain - plugin.thirdGain4; % set differential for gain
                plugin.thirdFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                
                plugin.thirdFilter4QTarget = plugin.lowMidRegionQFactor;
                qDiff = plugin.lowMidRegionQFactor - plugin.thirdQFactor4;
                plugin.thirdFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
                
                %todo: convert to individual smoothing for gain and q
                %plugin.thirdFilter4SmoothStep = 0; % Reset the step counter for smoothing
                %plugin.thirdFilter4SmoothStatus = true; % Activate gain smoothing
                
                plugin.thirdFilter4GainStep = 0;
                plugin.thirdFilter4GainSmooth = true;
                plugin.thirdFilter4QStep = 0;
                plugin.thirdFilter4QSmooth = true;
                
                % Updating plugin.thirdGain4 will be taken care of by
                % buildThirdFilter4()
                
            else % then third filter 4 is in mid control region
                plugin.thirdFilter4GainTarget = plugin.midRegionGain;
                gainDiff = plugin.midRegionGain - plugin.thirdGain4; % set differential for gain
                plugin.thirdFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                
                plugin.thirdFilter4QTarget = plugin.midRegionQFactor;
                qDiff = plugin.midRegionQFactor - plugin.thirdQFactor4;
                plugin.thirdFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
                
                %todo: clean up
                %plugin.thirdFilter4SmoothStep = 0; % Reset the step counter for smoothing
                %plugin.thirdFilter4SmoothStatus = true; % Activate gain smoothing
                
                plugin.thirdFilter4GainStep = 0;
                plugin.thirdFilter4GainSmooth = true;
                plugin.thirdFilter4QStep = 0;
                plugin.thirdFilter4QSmooth = true;
                
                % Updating plugin.thirdGain4 will be taken care of by
                % buildThirdFilter4()
            end
            setUpdateThirdFilter4(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdFilter6Params(plugin)
            if plugin.thirdFrequency6 < plugin.midHighCrossoverFreq % third filter 6 is in mid control region
                plugin.thirdFilter6GainTarget = plugin.midRegionGain;
                gainDiff = plugin.midRegionGain - plugin.thirdGain6; % set differential for gain
                plugin.thirdFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                
                plugin.thirdFilter6QTarget = plugin.midRegionQFactor;
                qDiff = plugin.midRegionQFactor - plugin.thirdQFactor6;
                plugin.thirdFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
                
                plugin.thirdFilter6GainStep = 0;
                plugin.thirdFilter6GainSmooth = true;
                plugin.thirdFilter6QStep = 0;
                plugin.thirdFilter6QSmooth = true;
                
                % Updating plugin.thirdGain6 will be taken care of by
                % buildThirdFilter6()
                
            else % then third filter 6 is in high-mid control region
                plugin.thirdFilter6GainTarget = plugin.highMidRegionGain;
                gainDiff = plugin.highMidRegionGain - plugin.thirdGain6; % set differential for gain
                plugin.thirdFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                
                plugin.thirdFilter6QTarget = plugin.highMidRegionQFactor;
                qDiff = plugin.highMidRegionQFactor - plugin.thirdQFactor6;
                plugin.thirdFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
                
                plugin.thirdFilter6GainStep = 0;
                plugin.thirdFilter6GainSmooth = true;
                plugin.thirdFilter6QStep = 0;
                plugin.thirdFilter6QSmooth = true;
                
                % Updating plugin.thirdGain6 will be taken care of by
                % buildThirdFilter6()
            end
            setUpdateThirdFilter6(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        %test
        function updateThirdFilter8Params(plugin)
            if plugin.thirdFrequency8 < plugin.highCrossoverFreq % Third filter 8 is in mid-high region
                if plugin.thirdFilter8Region == 4 % Already in mid-high region
                    % Update values if smoothing is done
                    %todo: should this reset the smoothing instead?
                    if ~plugin.thirdFilter8SmoothStatus
                        plugin.thirdGain8 = plugin.highMidRegionGain;
                        plugin.thirdQFactor8 = plugin.highMidRegionQFactor;
                    end
                    
                else % Was in high region (5)
                    plugin.thirdFilter8Region = 4; % set filter region to high (4)
                    plugin.thirdFilter8GainTarget = plugin.highMidRegionGain;
                    gainDiff = plugin.highMidRegionGain - plugin.thirdGain8; % set differential for gain
                    plugin.thirdFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter8QTarget = plugin.highMidRegionQFactor;
                    qDiff = plugin.highMidRegionQFactor - plugin.thirdQFactor8;
                    plugin.thirdFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter8SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.thirdFilter8SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.thirdGain8 will be taken care of by
                    % buildThirdFilter8()
                end
                
            else % Third filter 8 is in high region
                if plugin.thirdFilter8Region == 5 % Already in high region
                    % Update values if smoothing is done
                    if ~plugin.thirdFilter8SmoothStatus
                        plugin.thirdGain8 = plugin.highRegionGain;
                        plugin.thirdQFactor8 = plugin.highRegionQFactor;
                    end
                    
                else % Was in higih-mid region (4)
                    plugin.thirdFilter8Region = 5; % set filter region to high (5)
                    plugin.thirdFilter8GainTarget = plugin.highRegionGain;
                    gainDiff = plugin.highRegionGain - plugin.thirdGain8; % set differential for gain
                    plugin.thirdFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter8QTarget = plugin.highRegionQFactor;
                    qDiff = plugin.highRegionQFactor - plugin.thirdQFactor8;
                    plugin.thirdFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter8SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.thirdFilter8SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.thirdGain8 will be taken care of by
                    % buildThirdFilter8()
                end
                
            end
            
            setUpdateThirdFilter8(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdGain1(plugin,val)
            plugin.thirdFilter1GainTarget = val;
            gainDiff = val - plugin.thirdGain1; % set differential for gain
            plugin.thirdFilter1GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter1GainStep = 0;
            plugin.thirdFilter1GainSmooth = true;
            
            setUpdateThirdFilter1(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdGain2(plugin,val)
            plugin.thirdFilter2GainTarget = val;
            gainDiff = val - plugin.thirdGain2; % set differential for gain
            plugin.thirdFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter2GainStep = 0;
            plugin.thirdFilter2GainSmooth = true;
            
            setUpdateThirdFilter2(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdGain3(plugin,val)
            plugin.thirdFilter3GainTarget = val;
            gainDiff = val - plugin.thirdGain3; % set differential for gain
            plugin.thirdFilter3GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter3GainStep = 0;
            plugin.thirdFilter3GainSmooth = true;
            
            setUpdateThirdFilter3(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdGain4(plugin,val)
            plugin.thirdFilter4GainTarget = val;
            gainDiff = val - plugin.thirdGain4; % set differential for gain
            plugin.thirdFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter4GainStep = 0;
            plugin.thirdFilter4GainSmooth = true;
            
            setUpdateThirdFilter4(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdGain5(plugin,val)
            plugin.thirdFilter5GainTarget = val;
            gainDiff = val - plugin.thirdGain5; % set differential for gain
            plugin.thirdFilter5GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter5GainStep = 0;
            plugin.thirdFilter5GainSmooth = true;
            
            setUpdateThirdFilter5(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdGain6(plugin,val)
            plugin.thirdFilter6GainTarget = val;
            gainDiff = val - plugin.thirdGain6; % set differential for gain
            plugin.thirdFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter6GainStep = 0;
            plugin.thirdFilter6GainSmooth = true;
            
            setUpdateThirdFilter6(plugin);
            updateStateChangeStatus(plugin, true);
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
            plugin.thirdFilter1QTarget = val;
            qDiff = val - plugin.thirdQFactor1; % set differential for q
            plugin.thirdFilter1QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter1QStep = 0;
            plugin.thirdFilter1QSmooth = true;
            
            setUpdateThirdFilter1(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdQFactor2(plugin,val)
            plugin.thirdFilter2QTarget = val;
            qDiff = val - plugin.thirdQFactor2; % set differential for q
            plugin.thirdFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter2QStep = 0;
            plugin.thirdFilter2QSmooth = true;
            
            setUpdateThirdFilter2(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdQFactor3(plugin,val)
            plugin.thirdFilter3QTarget = val;
            qDiff = val - plugin.thirdQFactor3; % set differential for q
            plugin.thirdFilter3QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter3QStep = 0;
            plugin.thirdFilter3QSmooth = true;
            
            setUpdateThirdFilter3(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdQFactor4(plugin,val)
            plugin.thirdFilter4QTarget = val;
            qDiff = val - plugin.thirdQFactor4; % set differential for q
            plugin.thirdFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter4QStep = 0;
            plugin.thirdFilter4QSmooth = true;
            
            setUpdateThirdFilter4(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdQFactor5(plugin,val)
            plugin.thirdFilter5QTarget = val;
            qDiff = val - plugin.thirdQFactor5; % set differential for q
            plugin.thirdFilter5QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter5QStep = 0;
            plugin.thirdFilter5QSmooth = true;
            
            setUpdateThirdFilter5(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdQFactor6(plugin,val)
            plugin.thirdFilter6QTarget = val;
            qDiff = val - plugin.thirdQFactor6; % set differential for q
            plugin.thirdFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter6QStep = 0;
            plugin.thirdFilter6QSmooth = true;
            
            setUpdateThirdFilter6(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        %test
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
            updateStateChangeStatus(plugin,true);
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
        
        function updateFifthFilter2Params(plugin)
            if plugin.fifthFrequency2 < plugin.lowCrossoverFreq % fifth filter 2 is in low region
                if plugin.fifthFilter2Region == 1 % Already in low region
                    % Update values if smoothing is done
                    %todo: should this reset the smoothing instead?
                    if ~plugin.fifthFilter2SmoothStatus
                        plugin.fifthGain2 = plugin.lowRegionGain;
                        plugin.fifthQFactor2 = plugin.lowRegionQFactor;
                    end
                    
                else % Was in low-mid region (2)
                    plugin.fifthFilter2Region = 1; % set filter region to low (1)
                    plugin.fifthFilter2GainTarget = plugin.lowRegionGain;
                    gainDiff = plugin.lowRegionGain - plugin.fifthGain2; % set differential for gain
                    plugin.fifthFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter2QTarget = plugin.lowRegionQFactor;
                    qDiff = plugin.lowRegionQFactor - plugin.fifthQFactor2;
                    plugin.fifthFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter2SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.fifthFilter2SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.fifthGain2 will be taken care of by
                    % buildFifthFilter2()
                    
                end
            else % Fifth filter 2 is in low-mid region
                if plugin.fifthFilter2Region == 2 % Already in low-mid region
                    % Update values if smoothing is done
                    if ~plugin.fifthFilter2SmoothStatus
                        plugin.fifthGain2 = plugin.lowMidRegionGain;
                        plugin.fifthQFactor2 = plugin.lowMidRegionQFactor;
                    end
                    
                else % Was in low Fregion (1)
                    plugin.fifthFilter2Region = 2; % set filter region to low (1)
                    plugin.fifthFilter2GainTarget = plugin.lowMidRegionGain;
                    gainDiff = plugin.lowMidRegionGain - plugin.fifthGain2; % set differential for gain
                    plugin.fifthFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter2QTarget = plugin.lowMidRegionQFactor;
                    qDiff = plugin.lowMidRegionQFactor - plugin.fifthQFactor2;
                    plugin.fifthFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter2SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.fifthFilter2SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.fifthGain2 will be taken care of by
                    % buildFifthFilter2()
                    
                end
            end
            
            setUpdateFifthFilter2(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthFilter4Params(plugin)
            if plugin.fifthFrequency4 < plugin.lowMidCrossoverFreq % Fifth filter 4 is in low-mid region
                if plugin.fifthFilter4Region == 2 % Already in low-mid region (2)
                    % Update values if smoothing is done
                    %todo: should this reset the smoothing instead?
                    if ~plugin.fifthFilter4SmoothStatus
                        plugin.fifthGain4 = plugin.lowMidRegionGain;
                        plugin.fifthQFactor4 = plugin.lowMidRegionQFactor;
                    end
                    
                else % Was in mid region (3)
                    plugin.fifthFilter4Region = 2; % set filter region to low-mid (2)
                    plugin.fifthFilter4GainTarget = plugin.lowMidRegionGain;
                    gainDiff = plugin.lowMidRegionGain - plugin.fifthGain4; % set differential for gain
                    plugin.fifthFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter4QTarget = plugin.lowMidRegionQFactor;
                    qDiff = plugin.lowMidRegionQFactor - plugin.fifthQFactor4;
                    plugin.fifthFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter4SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.fifthFilter4SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.fifthGain4 will be taken care of by
                    % buildFifthFilter4()
                end
                
            else % Fifth filter 4 is in mid region
                if plugin.fifthFilter4Region == 3 % Already in mid region
                    % Update values if smoothing is done
                    if ~plugin.fifthFilter4SmoothStatus
                        plugin.fifthGain4 = plugin.midRegionGain;
                        plugin.fifthQFactor4 = plugin.midRegionQFactor;
                    end
                    
                else % Was in low-mid Fregion (2)
                    plugin.fifthFilter4Region = 3; % set filter region to mid (3)
                    plugin.fifthFilter4GainTarget = plugin.midRegionGain;
                    gainDiff = plugin.midRegionGain - plugin.fifthGain4; % set differential for gain
                    plugin.fifthFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter4QTarget = plugin.midRegionQFactor;
                    qDiff = plugin.midRegionQFactor - plugin.fifthQFactor4;
                    plugin.fifthFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter4SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.fifthFilter4SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.fifthGain4 will be taken care of by
                    % buildFifthFilter4()
                    
                end
            end
            
            setUpdateFifthFilter4(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthFilter6Params(plugin)
            if plugin.fifthFrequency6 < plugin.midHighCrossoverFreq % fifth filter 6 is in mid region
                if plugin.fifthFilter6Region == 3 % Already in mid region
                    % Update values if smoothing is done
                    %todo: should this reset the smoothing instead?
                    if ~plugin.fifthFilter6SmoothStatus
                        plugin.fifthGain6 = plugin.midRegionGain;
                        plugin.fifthQFactor6 = plugin.midRegionQFactor;
                    end
                    
                else % Was in high-mid region (4)
                    plugin.fifthFilter6Region = 3; % set filter region to low (4)
                    plugin.fifthFilter6GainTarget = plugin.midRegionGain;
                    gainDiff = plugin.midRegionGain - plugin.fifthGain6; % set differential for gain
                    plugin.fifthFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter6QTarget = plugin.midRegionQFactor;
                    qDiff = plugin.midRegionQFactor - plugin.fifthQFactor6;
                    plugin.fifthFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter6SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.fifthFilter6SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.fifthGain6 will be taken care of by
                    % buildFifthFilter6()
                    
                end
            else % fifth filter 6 is in high-mid region
                if plugin.fifthFilter6Region == 4 % Already in high-mid region
                    % Update values if smoothing is done
                    if ~plugin.fifthFilter6SmoothStatus
                        plugin.fifthGain6 = plugin.highMidRegionGain;
                        plugin.fifthQFactor6 = plugin.highMidRegionQFactor;
                    end
                    
                else % Was in mid Fregion (3)
                    plugin.fifthFilter6Region = 4; % set filter region to high-mid (4)
                    plugin.fifthFilter6GainTarget = plugin.highMidRegionGain;
                    gainDiff = plugin.highMidRegionGain - plugin.fifthGain6; % set differential for gain
                    plugin.fifthFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter6QTarget = plugin.highMidRegionQFactor;
                    qDiff = plugin.highMidRegionQFactor - plugin.fifthQFactor6;
                    plugin.fifthFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter6SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.fifthFilter6SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.fifthGain6 will be taken care of by
                    % buildFifthFilter6()
                    
                end
            end
            
            setUpdateFifthFilter6(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthFilter8Params(plugin)
            if plugin.fifthFrequency8 < plugin.highCrossoverFreq % fifth filter 8 is in mid-high region
                if plugin.fifthFilter8Region == 4 % Already in mid-high region
                    % Update values if smoothing is done
                    %todo: should this reset the smoothing instead?
                    if ~plugin.fifthFilter8SmoothStatus
                        plugin.fifthGain8 = plugin.highMidRegionGain;
                        plugin.fifthQFactor8 = plugin.highMidRegionQFactor;
                    end
                    
                else % Was in high region (5)
                    plugin.fifthFilter8Region = 4; % set filter region to high (4)
                    plugin.fifthFilter8GainTarget = plugin.highMidRegionGain;
                    gainDiff = plugin.highMidRegionGain - plugin.fifthGain8; % set differential for gain
                    plugin.fifthFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter8QTarget = plugin.highMidRegionQFactor;
                    qDiff = plugin.highMidRegionQFactor - plugin.fifthQFactor8;
                    plugin.fifthFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter8SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.fifthFilter8SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.fifthGain8 will be taken care of by
                    % buildFifthFilter8()
                end
                
            else % fifth filter 8 is in high region
                if plugin.fifthFilter8Region == 5 % Already in high region
                    % Update values if smoothing is done
                    if ~plugin.fifthFilter8SmoothStatus
                        plugin.fifthGain8 = plugin.highRegionGain;
                        plugin.fifthQFactor8 = plugin.highRegionQFactor;
                    end
                    
                else % Was in higih-mid region (4)
                    plugin.fifthFilter8Region = 5; % set filter region to high (5)
                    plugin.fifthFilter8GainTarget = plugin.highRegionGain;
                    gainDiff = plugin.highRegionGain - plugin.fifthGain8; % set differential for gain
                    plugin.fifthFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter8QTarget = plugin.highRegionQFactor;
                    qDiff = plugin.highRegionQFactor - plugin.fifthQFactor8;
                    plugin.fifthFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter8SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.fifthFilter8SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.fifthGain8 will be taken care of by
                    % buildFifthFilter8()
                end
                
            end
            
            setUpdateFifthFilter8(plugin);
            updateStateChangeStatus(plugin, true);
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
            updateStateChangeStatus(plugin, true);
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
        
        function updateSeventhFilter2Params(plugin)
            if plugin.seventhFrequency2 < plugin.lowCrossoverFreq % Seventh filter 2 is in low region
                if plugin.seventhFilter2Region == 1 % Already in low region
                    % Update values if smoothing is done
                    %todo: should this reset the smoothing instead?
                    if ~plugin.seventhFilter2SmoothStatus
                        plugin.seventhGain2 = plugin.lowRegionGain;
                        plugin.seventhQFactor2 = plugin.lowRegionQFactor;
                    end
                    
                else % Was in low-mid region (2)
                    plugin.seventhFilter2Region = 1; % set filter region to low (1)
                    plugin.seventhFilter2GainTarget = plugin.lowRegionGain;
                    gainDiff = plugin.lowRegionGain - plugin.seventhGain2; % set differential for gain
                    plugin.seventhFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter2QTarget = plugin.lowRegionQFactor;
                    qDiff = plugin.lowRegionQFactor - plugin.seventhQFactor2;
                    plugin.seventhFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter2SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.seventhFilter2SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.seventhGain2 will be taken care of by
                    % buildSeventhFilter2()
                    
                end
            else % Seventh filter 2 is in low-mid region
                if plugin.seventhFilter2Region == 2 % Already in low-mid region
                    % Update values if smoothing is done
                    if ~plugin.seventhFilter2SmoothStatus
                        plugin.seventhGain2 = plugin.lowMidRegionGain;
                        plugin.seventhQFactor2 = plugin.lowMidRegionQFactor;
                    end
                    
                else % Was in low Fregion (1)
                    plugin.seventhFilter2Region = 2; % set filter region to low (1)
                    plugin.seventhFilter2GainTarget = plugin.lowMidRegionGain;
                    gainDiff = plugin.lowMidRegionGain - plugin.seventhGain2; % set differential for gain
                    plugin.seventhFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter2QTarget = plugin.lowMidRegionQFactor;
                    qDiff = plugin.lowMidRegionQFactor - plugin.seventhQFactor2;
                    plugin.seventhFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter2SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.seventhFilter2SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.seventhGain2 will be taken care of by
                    % buildSeventhFilter2()
                    
                end
            end
            
            setUpdateSeventhFilter2(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhFilter4Params(plugin)
            if plugin.seventhFrequency4 < plugin.lowMidCrossoverFreq % Seventh filter 4 is in low-mid region
                if plugin.seventhFilter4Region == 2 % Already in low-mid region (2)
                    % Update values if smoothing is done
                    %todo: should this reset the smoothing instead?
                    if ~plugin.seventhFilter4SmoothStatus
                        plugin.seventhGain4 = plugin.lowMidRegionGain;
                        plugin.seventhQFactor4 = plugin.lowMidRegionQFactor;
                    end
                    
                else % Was in mid region (3)
                    plugin.seventhFilter4Region = 2; % set filter region to low-mid (2)
                    plugin.seventhFilter4GainTarget = plugin.lowMidRegionGain;
                    gainDiff = plugin.lowMidRegionGain - plugin.seventhGain4; % set differential for gain
                    plugin.seventhFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter4QTarget = plugin.lowMidRegionQFactor;
                    qDiff = plugin.lowMidRegionQFactor - plugin.seventhQFactor4;
                    plugin.seventhFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter4SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.seventhFilter4SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.seventhGain4 will be taken care of by
                    % buildSeventhFilter4()
                end
                
            else % Seventh filter 4 is in mid region
                if plugin.seventhFilter4Region == 3 % Already in mid region
                    % Update values if smoothing is done
                    if ~plugin.seventhFilter4SmoothStatus
                        plugin.seventhGain4 = plugin.midRegionGain;
                        plugin.seventhQFactor4 = plugin.midRegionQFactor;
                    end
                    
                else % Was in low-mid Fregion (2)
                    plugin.seventhFilter4Region = 3; % set filter region to mid (3)
                    plugin.seventhFilter4GainTarget = plugin.midRegionGain;
                    gainDiff = plugin.midRegionGain - plugin.seventhGain4; % set differential for gain
                    plugin.seventhFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter4QTarget = plugin.midRegionQFactor;
                    qDiff = plugin.midRegionQFactor - plugin.seventhQFactor4;
                    plugin.seventhFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter4SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.seventhFilter4SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.seventhGain4 will be taken care of by
                    % buildSeventhFilter4()
                    
                end
            end
            
            setUpdateSeventhFilter4(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhFilter6Params(plugin)
            if plugin.seventhFrequency6 < plugin.midHighCrossoverFreq % Seventh filter 6 is in mid region
                if plugin.seventhFilter6Region == 3 % Already in mid region
                    % Update values if smoothing is done
                    %todo: should this reset the smoothing instead?
                    if ~plugin.seventhFilter6SmoothStatus
                        plugin.seventhGain6 = plugin.midRegionGain;
                        plugin.seventhQFactor6 = plugin.midRegionQFactor;
                    end
                    
                else % Was in high-mid region (4)
                    plugin.seventhFilter6Region = 3; % set filter region to low (4)
                    plugin.seventhFilter6GainTarget = plugin.midRegionGain;
                    gainDiff = plugin.midRegionGain - plugin.seventhGain6; % set differential for gain
                    plugin.seventhFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter6QTarget = plugin.midRegionQFactor;
                    qDiff = plugin.midRegionQFactor - plugin.seventhQFactor6;
                    plugin.seventhFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter6SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.seventhFilter6SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.seventhGain6 will be taken care of by
                    % buildSeventhFilter6()
                    
                end
            else % Seventh filter 6 is in high-mid region
                if plugin.seventhFilter6Region == 4 % Already in high-mid region
                    % Update values if smoothing is done
                    if ~plugin.seventhFilter6SmoothStatus
                        plugin.seventhGain6 = plugin.highMidRegionGain;
                        plugin.seventhQFactor6 = plugin.highMidRegionQFactor;
                    end
                    
                else % Was in mid Fregion (3)
                    plugin.seventhFilter6Region = 4; % set filter region to high-mid (4)
                    plugin.seventhFilter6GainTarget = plugin.highMidRegionGain;
                    gainDiff = plugin.highMidRegionGain - plugin.seventhGain6; % set differential for gain
                    plugin.seventhFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter6QTarget = plugin.highMidRegionQFactor;
                    qDiff = plugin.highMidRegionQFactor - plugin.seventhQFactor6;
                    plugin.seventhFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter6SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.seventhFilter6SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.seventhGain6 will be taken care of by
                    % buildSeventhFilter6()
                    
                end
            end
            
            setUpdateSeventhFilter6(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhFilter8Params(plugin)
            if plugin.seventhFrequency8 < plugin.highCrossoverFreq % seventh filter 8 is in mid-high region
                if plugin.seventhFilter8Region == 4 % Already in mid-high region
                    % Update values if smoothing is done
                    %todo: should this reset the smoothing instead?
                    if ~plugin.seventhFilter8SmoothStatus
                        plugin.seventhGain8 = plugin.highMidRegionGain;
                        plugin.seventhQFactor8 = plugin.highMidRegionQFactor;
                    end
                    
                else % Was in high region (5)
                    plugin.seventhFilter8Region = 4; % set filter region to high (4)
                    plugin.seventhFilter8GainTarget = plugin.highMidRegionGain;
                    gainDiff = plugin.highMidRegionGain - plugin.seventhGain8; % set differential for gain
                    plugin.seventhFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter8QTarget = plugin.highMidRegionQFactor;
                    qDiff = plugin.highMidRegionQFactor - plugin.seventhQFactor8;
                    plugin.seventhFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter8SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.seventhFilter8SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.seventhGain8 will be taken care of by
                    % buildSeventhFilter8()
                end
                
            else % Seventh filter 8 is in high region
                if plugin.seventhFilter8Region == 5 % Already in high region
                    % Update values if smoothing is done
                    if ~plugin.seventhFilter8SmoothStatus
                        plugin.seventhGain8 = plugin.highRegionGain;
                        plugin.seventhQFactor8 = plugin.highRegionQFactor;
                    end
                    
                else % Was in higih-mid region (4)
                    plugin.seventhFilter8Region = 5; % set filter region to high (5)
                    plugin.seventhFilter8GainTarget = plugin.highRegionGain;
                    gainDiff = plugin.highRegionGain - plugin.seventhGain8; % set differential for gain
                    plugin.seventhFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter8QTarget = plugin.highRegionQFactor;
                    qDiff = plugin.highRegionQFactor - plugin.seventhQFactor8;
                    plugin.seventhFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter8SmoothStep = 0; % Reset the step counter for smoothing
                    plugin.seventhFilter8SmoothStatus = true; % Activate gain smoothing
                    % Updating plugin.seventhGain8 will be taken care of by
                    % buildSeventhFilter8()
                end
                
            end
            
            setUpdateSeventhFilter8(plugin);
            updateStateChangeStatus(plugin, true);
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
            updateStateChangeStatus(plugin, true);
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















