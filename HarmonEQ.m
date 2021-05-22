classdef HarmonEQ < matlab.System & audioPlugin
    % HarmonEQ.m
    % Harmonic Equalizer plugin
    % v0.4-alpha
    % Autho: Colin Malloy
    % MATLAB version: R2021a
    % Last updated: 21 May 2021
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
    
    
    
    %----------------------------------------------------------------------
    % TUNABLE PROPERTIES
    %----------------------------------------------------------------------
    properties
        rootNote = EQRootNote.C;
        chordType = EQChordType.noChord;
        automaticMode = false;
        
        rootNoteValue = 0;
        
        thirdInterval = 'off';
        thirdIntervalDistance = 4;
        thirdNote = 'E';
        
        fifthInterval = 'off';
        fifthIntervalDistance = 7;
        fifthNote = 'G';
        
        seventhInterval = 'off';
        seventhIntervalDistance = 11;
        seventhNote = 'B';
        
        gainOut = 0;
        
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
    
    
    properties (Access = private)
        privateRootNote = EQRootNote.C;
        privateChordType = EQChordType.noChord;
        
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
            audioPluginParameter('automaticMode',...
            'DisplayName','Control Mode',...
            'DisplayNameLocation','above',...
            'Mapping', {'enum','Manual','Automatic'},...
            'Layout',[2,12;4,12],...
            'Style','vrocker'),...
            ...
            audioPluginParameter('rootNote','DisplayName','Root Note',...
            'Mapping',{'enum','off','C','C# / Db','D','D# / Eb','E','F',...
            'F# / Gb','G','G# / Ab','A','A# / Bb','B',},...
            'Style','dropdown',...
            'Layout',[7,12],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('chordType',...
            'DisplayName','Chord Type',...
            'Mapping',{'enum','no chord','5','min','maj','dim','aug',...
            'min7','dom7','maj7','m7b5','dim7'},...
            'Style','dropdown',...
            'Layout',[9,12],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('gainOut',...
            'DisplayName', 'Output Gain',...
            'Mapping',{'lin', -12, 12},...
            'Style','rotary',...
            'Layout',[11,12; 12,12],...
            'DisplayNameLocation','below'),...
            ...
            audioPluginParameter('highRegionGain',...
            'DisplayName','High Gain',...
            'Mapping',{'lin',-12,12},...
            'Style','vslider',...
            'Layout',[2,9;8,10],...
            'DisplayNameLocation','above'),...
            audioPluginParameter('highRegionQFactor',...
            'DisplayName','High Q',...
            'Mapping',{'pow', 2, 0.5, 100},...
            'Style','rotary',...
            'Layout',[10,9;11,10],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('highMidRegionGain',...
            'DisplayName','High-Mid Gain',...
            'Mapping',{'lin',-12,12},...
            'Style','vslider',...
            'Layout',[2,7;8,8],...
            'DisplayNameLocation','above'),...
            audioPluginParameter('highMidRegionQFactor',...
            'DisplayName','High-Mid Q',...
            'Mapping',{'pow', 2, 0.5, 100},...
            'Style','rotary',...
            'Layout',[10,7;11,8],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('midRegionGain',...
            'DisplayName','Mid Gain',...
            'Mapping',{'lin',-12,12},...
            'Style','vslider',...
            'Layout',[2,5;8,6],...
            'DisplayNameLocation','above'),...
            audioPluginParameter('midRegionQFactor',...
            'DisplayName','Mid Q',...
            'Mapping',{'pow', 2, 0.5, 100},...
            'Style','rotary',...
            'Layout',[10,5;11,6],...
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
            'Layout',[10,3;11,4],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('lowRegionGain',...
            'DisplayName','Low Gain',...
            'Mapping',{'lin',-12,12},...
            'Style','vslider',...
            'Layout',[2,1;8,2],...
            'DisplayNameLocation','above'),...
            audioPluginParameter('lowRegionQFactor',...
            'DisplayName','Low Q',...
            'Mapping',{'pow', 2, 0.5, 100},...
            'Style','rotary',...
            'Layout',[10,1;11,2],...
            'DisplayNameLocation','above'),...
            ...
            audioPluginParameter('lowCrossoverFreq',...
            'DisplayName','Low Crossover',...
            'Mapping',{'log',63.54,127.09},...
            'Style','rotary',...
            'Layout',[12,2;13,3],...
            'DisplayNameLocation','below'),...
            ...
            audioPluginParameter('lowMidCrossoverFreq',...
            'DisplayName','Low-Mid Crossover',...
            'Mapping',{'log',254.18,508.36},...
            'Style','rotary',...
            'Layout',[12,4;13,5],...
            'DisplayNameLocation','below'),...
            ...
            audioPluginParameter('midHighCrossoverFreq',...
            'DisplayName','Mid-High Crossover',...
            'Mapping',{'log',1016.71,2033.42},...
            'Style','rotary',...
            'Layout',[12,6;13,7],...
            'DisplayNameLocation','below'),...
            ...
            audioPluginParameter('highCrossoverFreq',...
            'DisplayName','High Crossover',...
            'Mapping',{'log',4066.84,8133.68},...
            'Style','rotary',...
            'Layout',[12,8;13,9],...
            'DisplayNameLocation','below'),...
            ...
            audioPluginGridLayout(...
            'RowHeight',[25,25,25,25,25,25,25,25,25,50,50,50,50,25],...
            'ColumnWidth',[50,50,50,50,50,50,50,50,50,50,50,150],...
            'RowSpacing',15)...
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
        
        thirdFilter7GainDiff = 0;
        thirdFilter7GainTarget = 0;
        thirdFilter7GainSmooth = false;
        thirdFilter7GainStep = Inf;
        thirdFilter7QDiff = 26;
        thirdFilter7QTarget = 26;
        thirdFilter7QSmooth = false
        thirdFilter7QStep = Inf;
        
        thirdFilter8GainDiff = 0;
        thirdFilter8GainTarget = 0;
        thirdFilter8GainSmooth = false;
        thirdFilter8GainStep = Inf;
        thirdFilter8QDiff = 26;
        thirdFilter8QTarget = 26;
        thirdFilter8QSmooth = false
        thirdFilter8QStep = Inf;
        
        thirdFilter9GainDiff = 0;
        thirdFilter9GainTarget = 0;
        thirdFilter9GainSmooth = false;
        thirdFilter9GainStep = Inf;
        thirdFilter9QDiff = 26;
        thirdFilter9QTarget = 26;
        thirdFilter9QSmooth = false
        thirdFilter9QStep = Inf;
        
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
        fifthFilter1GainDiff = 0;
        fifthFilter1GainTarget = 0;
        fifthFilter1GainSmooth = false;
        fifthFilter1GainStep = Inf;
        fifthFilter1QDiff = 26;
        fifthFilter1QTarget = 26;
        fifthFilter1QSmooth = false
        fifthFilter1QStep = Inf;
        
        fifthFilter2GainDiff = 0;
        fifthFilter2GainTarget = 0;
        fifthFilter2GainSmooth = false;
        fifthFilter2GainStep = Inf;
        fifthFilter2QDiff = 26;
        fifthFilter2QTarget = 26;
        fifthFilter2QSmooth = false
        fifthFilter2QStep = Inf;
        
        fifthFilter3GainDiff = 0;
        fifthFilter3GainTarget = 0;
        fifthFilter3GainSmooth = false;
        fifthFilter3GainStep = Inf;
        fifthFilter3QDiff = 26;
        fifthFilter3QTarget = 26;
        fifthFilter3QSmooth = false
        fifthFilter3QStep = Inf;
        
        fifthFilter4GainDiff = 0;
        fifthFilter4GainTarget = 0;
        fifthFilter4GainSmooth = false;
        fifthFilter4GainStep = Inf;
        fifthFilter4QDiff = 26;
        fifthFilter4QTarget = 26;
        fifthFilter4QSmooth = false
        fifthFilter4QStep = Inf;
        
        fifthFilter5GainDiff = 0;
        fifthFilter5GainTarget = 0;
        fifthFilter5GainSmooth = false;
        fifthFilter5GainStep = Inf;
        fifthFilter5QDiff = 26;
        fifthFilter5QTarget = 26;
        fifthFilter5QSmooth = false
        fifthFilter5QStep = Inf;
        
        fifthFilter6GainDiff = 0;
        fifthFilter6GainTarget = 0;
        fifthFilter6GainSmooth = false;
        fifthFilter6GainStep = Inf;
        fifthFilter6QDiff = 26;
        fifthFilter6QTarget = 26;
        fifthFilter6QSmooth = false
        fifthFilter6QStep = Inf;
        
        fifthFilter7GainDiff = 0;
        fifthFilter7GainTarget = 0;
        fifthFilter7GainSmooth = false;
        fifthFilter7GainStep = Inf;
        fifthFilter7QDiff = 26;
        fifthFilter7QTarget = 26;
        fifthFilter7QSmooth = false
        fifthFilter7QStep = Inf;
        
        fifthFilter8GainDiff = 0;
        fifthFilter8GainTarget = 0;
        fifthFilter8GainSmooth = false;
        fifthFilter8GainStep = Inf;
        fifthFilter8QDiff = 26;
        fifthFilter8QTarget = 26;
        fifthFilter8QSmooth = false
        fifthFilter8QStep = Inf;
        
        fifthFilter9GainDiff = 0;
        fifthFilter9GainTarget = 0;
        fifthFilter9GainSmooth = false;
        fifthFilter9GainStep = Inf;
        fifthFilter9QDiff = 26;
        fifthFilter9QTarget = 26;
        fifthFilter9QSmooth = false
        fifthFilter9QStep = Inf;
        
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
        seventhFilter1GainDiff = 0;
        seventhFilter1GainTarget = 0;
        seventhFilter1GainSmooth = false;
        seventhFilter1GainStep = Inf;
        seventhFilter1QDiff = 26;
        seventhFilter1QTarget = 26;
        seventhFilter1QSmooth = false
        seventhFilter1QStep = Inf;
        
        seventhFilter2GainDiff = 0;
        seventhFilter2GainTarget = 0;
        seventhFilter2GainSmooth = false;
        seventhFilter2GainStep = Inf;
        seventhFilter2QDiff = 26;
        seventhFilter2QTarget = 26;
        seventhFilter2QSmooth = false
        seventhFilter2QStep = Inf;
        
        seventhFilter3GainDiff = 0;
        seventhFilter3GainTarget = 0;
        seventhFilter3GainSmooth = false;
        seventhFilter3GainStep = Inf;
        seventhFilter3QDiff = 26;
        seventhFilter3QTarget = 26;
        seventhFilter3QSmooth = false
        seventhFilter3QStep = Inf;
        
        seventhFilter4GainDiff = 0;
        seventhFilter4GainTarget = 0;
        seventhFilter4GainSmooth = false;
        seventhFilter4GainStep = Inf;
        seventhFilter4QDiff = 26;
        seventhFilter4QTarget = 26;
        seventhFilter4QSmooth = false
        seventhFilter4QStep = Inf;
        
        seventhFilter5GainDiff = 0;
        seventhFilter5GainTarget = 0;
        seventhFilter5GainSmooth = false;
        seventhFilter5GainStep = Inf;
        seventhFilter5QDiff = 26;
        seventhFilter5QTarget = 26;
        seventhFilter5QSmooth = false
        seventhFilter5QStep = Inf;
        
        seventhFilter6GainDiff = 0;
        seventhFilter6GainTarget = 0;
        seventhFilter6GainSmooth = false;
        seventhFilter6GainStep = Inf;
        seventhFilter6QDiff = 26;
        seventhFilter6QTarget = 26;
        seventhFilter6QSmooth = false
        seventhFilter6QStep = Inf;
        
        seventhFilter7GainDiff = 0;
        seventhFilter7GainTarget = 0;
        seventhFilter7GainSmooth = false;
        seventhFilter7GainStep = Inf;
        seventhFilter7QDiff = 26;
        seventhFilter7QTarget = 26;
        seventhFilter7QSmooth = false
        seventhFilter7QStep = Inf;
        
        seventhFilter8GainDiff = 0;
        seventhFilter8GainTarget = 0;
        seventhFilter8GainSmooth = false;
        seventhFilter8GainStep = Inf;
        seventhFilter8QDiff = 26;
        seventhFilter8QTarget = 26;
        seventhFilter8QSmooth = false
        seventhFilter8QStep = Inf;
        
        seventhFilter9GainDiff = 0;
        seventhFilter9GainTarget = 0;
        seventhFilter9GainSmooth = false;
        seventhFilter9GainStep = Inf;
        seventhFilter9QDiff = 26;
        seventhFilter9QTarget = 26;
        seventhFilter9QSmooth = false
        seventhFilter9QStep = Inf;
        
        inputBuffer;
        outputBuffer;
        numberOfSmoothSteps = 3;
        gainOutSmooth = 1;
        
        % Active state variables
        rootFiltersActive = true;
        thirdFiltersActive = false;
        fifthFiltersActive = false;
        seventhFiltersActive = false;
        
        % Deactivation flag variables
        rootFiltersDeactivating = false;
        thirdFiltersDeactivating = false;
        fifthFiltersDeactivating = false;
        seventhFiltersDeactivating = false;
        
        % Changing note variables
        rootFiltersChangingNote = false;
        thirdFiltersChangingNote = false;
        fifthFiltersChangingNote = false;
        seventhFiltersChangingNote = false;
        
        % For visalization
        visualizerObject;
        
        
        %------------------------Harmonic analysis-------------------------
        chordTemplates;
        chromaTransformMatrix;
        analysisBuffer;
        
        % filter coefficient variables for HP filter
        butterLowB;
        butterLowA;
        butterHiB;
        butterHiA;
        
        nFFT = 2048;
        hannWindow;
        prevEstimateIndex = 0;
        
        peakAlpha = 0.07;
        prevLevel = 0;
        
        resetAnalysisBufferFlag = false;
    end
    
    
    %----------------------------------------------------------------------
    % PROTECTED METHODS
    %----------------------------------------------------------------------
    
    %----------------------------------------------------------------------
    % MAIN PROCESSING BLOCK
    %----------------------------------------------------------------------
    methods (Access = protected)
        function out = stepImpl(plugin,in)
            %-------------------Get necessary parameters-------------------
            fs = getSampleRate(plugin);
            n_fft = plugin.nFFT; % 2048 @ <= 48k, 4096 @ 96k, 8192 @ 192k
            n_fft2 = n_fft / 2;
            monoIn = double(in); % Ensure doubles for analysis
            % Sum to mono for harmonic analysis
            monoIn = plugin.sumToMono(monoIn);
            previousLevel = plugin.prevLevel;
            level = previousLevel;
            alpha = plugin.peakAlpha;
            for i = 1:length(monoIn)
                previousLevel = peakLevelDetection(plugin, monoIn(i), previousLevel, alpha);
                if previousLevel > level
                    level = previousLevel;
                end
            end
            plugin.prevLevel = previousLevel;
            outputGain = plugin.gainOutSmooth;
            [m,~] = size(in);
            
            % write to input buffer
            write(plugin.inputBuffer, in);
            if fs <= 96000 && m > 128
                bufferLength = n_fft2 / 8; % 128 <= 48k, 256 @ 96k, 512 @ 192k
            elseif fs > 96000 && m > 256
                bufferLength = n_fft2 / 8;
            else
                bufferLength = m;
            end
            
            numLoops = ceil(plugin.inputBuffer.NumUnreadSamples / bufferLength);
            
            % EQ audio in subloops
            for i = 1:numLoops
                if i < numLoops
                    audio = read(plugin.inputBuffer, bufferLength);
                else
                    audio = read(plugin.inputBuffer);
                end
                %-------------------Update filter parameters-------------------
                updateRootFiltersForProcessing(plugin,fs);
                updateThirdFiltersForProcessing(plugin,fs);
                updateFifthFiltersForProcessing(plugin,fs);
                updateSeventhFiltersForProcessing(plugin,fs);
                
                % update plugin.B and plugin.A coefficient matrices for
                % visualization
                updateFilterCoefficientsMatrix(plugin);
                
                %------------------------Process audio-------------------------
                if plugin.rootFiltersActive
                    audio = processRootFilters(plugin,audio);
                end
                if plugin.thirdFiltersActive
                    audio = processThirdFilters(plugin,audio);
                end
                if plugin.fifthFiltersActive
                    audio = processFifthFilters(plugin,audio);
                end
                if plugin.seventhFiltersActive
                    audio = processSeventhFilters(plugin,audio);
                end
                
                % Smooth output gain value
                outputGain = outputGainSmoothing(plugin, outputGain);
                outputGain = db2mag(outputGain);
                audio = outputGain .* audio;
                % write to output buffer
                write(plugin.outputBuffer, audio);
            end
            out = read(plugin.outputBuffer);
            plugin.gainOutSmooth = outputGain;
            
            if ~isempty(plugin.visualizerObject) && plugin.stateChange
                updateVisualizer(plugin);
            end
            
            %----------------------Harmonic analysis-----------------------
            if plugin.automaticMode
                % HP and LP filter to reduce high and low pitch noise
                % interference with chord detection
                monoIn = filter(plugin.butterLowB, plugin.butterLowA, monoIn);
                monoIn = filter(plugin.butterHiB, plugin.butterHiA, monoIn);
                if plugin.resetAnalysisBufferFlag
                    resetAnalysisBuffer(plugin);
                end
                write(plugin.analysisBuffer,monoIn);
                % Prep chord templates
                chord_templates = plugin.chordTemplates;
                
                if plugin.analysisBuffer.NumUnreadSamples >=n_fft2
                    
                    magnitudes = getPowSpectrum(plugin, n_fft, n_fft2);
                    
                    % Get normalized chroma vector
                    chromaVector = getNormChroma(plugin,magnitudes);
                    
                    % Calculate similarity values with chord templates
                    prevIndex = plugin.prevEstimateIndex;
                    [best_sim_index, best_similarity, prevEstSim] =...
                        getSimilarities(plugin,chromaVector,...
                        chord_templates, prevIndex);
                    chordEstimate = getChordEstimate(plugin, best_sim_index,...
                        best_similarity, prevIndex, prevEstSim);
                    
                    % Don't update chord if the audio level is low 
                    if level > -20
                        if chordEstimate > 0
                            [~, smooth_root,smooth_chord_type] = ...
                                chordDetectionLookup(chordEstimate);
                            updateRootNote(plugin, smooth_root);
                            updateChordType(plugin, smooth_chord_type);
                        end
                        % Store for next iteration
                        plugin.prevEstimateIndex = chordEstimate;
                    else
                        plugin.prevEstimateIndex = 0;
                    end
                end
                
            end
            
        end
        
        %------------------------------------------------------------------
        % INITIALIZATION
        %------------------------------------------------------------------
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
            
            % Build chord template matrix
            plugin.chordTemplates = buildChordTemplates();
            
            % Build Chroma Transform Matrix
            initializeTransformMatrix(plugin);
            
            % Initialize buffer for harmonic analysis
            plugin.analysisBuffer = dsp.AsyncBuffer;
            write(plugin.analysisBuffer, [0; 0]);
            read(plugin.analysisBuffer, 2);
            
            plugin.inputBuffer = dsp.AsyncBuffer;
            write(plugin.inputBuffer, [0 0; 0 0]);
            read(plugin.inputBuffer);
            
            plugin.outputBuffer = dsp.AsyncBuffer;
            write(plugin.outputBuffer, [0 0; 0 0]);
            read(plugin.outputBuffer);
        end
        
        
        function resetImpl(plugin)
            fs = getSampleRate(plugin);
            % Rebuild Chroma transform matrix in case the sample rate
            % changed
            initializeTransformMatrix(plugin);
            
            % Design highpass filter for automatic chord analysis
            [plugin.butterLowB, plugin.butterLowA] = butter(6, 110/fs, 'high');
            [plugin.butterHiB, plugin.butterHiA] = butter(6, 1200/fs);
            
            % Build Hann window
            plugin.hannWindow = hann(plugin.nFFT,'periodic');
            
            % Reset buffer
            read(plugin.analysisBuffer);
            read(plugin.inputBuffer);
            read(plugin.outputBuffer);
%             plugin.analysisBuffer = dsp.AsyncBuffer;
%             write(plugin.analysisBuffer, [0; 0]);
%             read(plugin.analysisBuffer);
%             
%             plugin.inputBuffer = dsp.AsyncBuffer;
%             write(plugin.inputBuffer, [0 0; 0 0]);
%             read(plugin.inputBuffer);
%             
%             plugin.outputBuffer = dsp.AsyncBuffer;
%             write(plugin.outputBuffer, [0 0; 0 0]);
%             read(plugin.outputBuffer);
        end
        
    end
    
    %----------------------------------------------------------------------
    % PUBLIC METHODS
    %----------------------------------------------------------------------
    methods
        
        %Constructor
        function plugin = HarmonEQ()
            fs = getSampleRate(plugin);
            % Initialize filter coefficients to an allpass filter for the
            % visualizer
            plugin.B = [1 0 0];
            plugin.A = [0 0 1];
            
            % Design highpass filter for automatic chord analysis
            [plugin.butterLowB, plugin.butterLowA] = butter(6, 110/fs, 'high');
            [plugin.butterHiB, plugin.butterHiA] = butter(6, 1200/fs);
            
            % Build Hann window
            plugin.hannWindow = hann(plugin.nFFT,'periodic');
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
        
        function set.automaticMode(plugin,val)
            plugin.automaticMode = val;
            setResetAnalysisBufferFlag(plugin);
        end
        
        function set.gainOut(plugin,val)
            plugin.gainOut = val;
        end
        
        %----------------------------Root note-----------------------------
        function set.rootNote(plugin,val)
            % Update rootNote if in manual mode, do nothing if in automatic
            % chord detection mode
            plugin.rootNote = val;
            updatePrivateRootNote(plugin,val);
        end
        
        %-------------------------Chord type setter------------------------
        function set.chordType(plugin,val)
            % Update chordType if in manual mode, do nothing if in
            % automatic chord detection mode
            plugin.chordType = val;
            updatePrivateChordType(plugin,val);
        end
        
        function updateChord(plugin)
            chord = plugin.privateChordType;
            
            switch chord
                case EQChordType.noChord
                    deactivateThirdFilters(plugin);
                    deactivateFifthFilters(plugin);
                    deactivateSeventhFilters(plugin);
                case EQChordType.five
                    if plugin.rootFiltersActive
                        activateFifthFilters(plugin);
                    end
                    deactivateThirdFilters(plugin);
                    setFifthIntervalDistance(plugin,7);
                    changeFifthFilterNote(plugin);
                    deactivateSeventhFilters(plugin);
                case EQChordType.minor
                    if plugin.rootFiltersActive
                        activateThirdFilters(plugin);
                        activateFifthFilters(plugin);
                    end
                    setThirdIntervalDistance(plugin,3);
                    changeThirdFilterNote(plugin);
                    setFifthIntervalDistance(plugin,7);
                    changeFifthFilterNote(plugin);
                    deactivateSeventhFilters(plugin);
                case EQChordType.major
                    if plugin.rootFiltersActive
                        activateThirdFilters(plugin);
                        activateFifthFilters(plugin);
                    end
                    setThirdIntervalDistance(plugin,4);
                    changeThirdFilterNote(plugin);
                    setFifthIntervalDistance(plugin,7);
                    changeFifthFilterNote(plugin);
                    deactivateSeventhFilters(plugin);
                case EQChordType.diminished
                    if plugin.rootFiltersActive
                        activateThirdFilters(plugin);
                        activateFifthFilters(plugin);
                    end
                    setThirdIntervalDistance(plugin,3);
                    changeThirdFilterNote(plugin);
                    setFifthIntervalDistance(plugin,6);
                    changeFifthFilterNote(plugin);
                    deactivateSeventhFilters(plugin);
                case EQChordType.augmented
                    if plugin.rootFiltersActive
                        activateThirdFilters(plugin);
                        activateFifthFilters(plugin);
                    end
                    setThirdIntervalDistance(plugin,4);
                    changeThirdFilterNote(plugin);
                    setFifthIntervalDistance(plugin,8);
                    changeFifthFilterNote(plugin);
                    deactivateSeventhFilters(plugin);
                case EQChordType.minor7
                    setThirdIntervalDistance(plugin,3);
                    changeThirdFilterNote(plugin);
                    setFifthIntervalDistance(plugin,7);
                    changeFifthFilterNote(plugin);
                    setSeventhIntervalDistance(plugin,10);
                    changeSeventhFilterNote(plugin);
                    if plugin.rootFiltersActive
                        activateThirdFilters(plugin);
                        activateFifthFilters(plugin);
                        activateSeventhFilters(plugin);
                    end
                case EQChordType.dominant7
                    if plugin.rootFiltersActive
                        activateThirdFilters(plugin);
                        activateFifthFilters(plugin);
                        activateSeventhFilters(plugin);
                    end
                    setThirdIntervalDistance(plugin,4);
                    changeThirdFilterNote(plugin);
                    setFifthIntervalDistance(plugin,7);
                    changeFifthFilterNote(plugin);
                    setSeventhIntervalDistance(plugin,10);
                    changeSeventhFilterNote(plugin);
                case EQChordType.major7
                    if plugin.rootFiltersActive
                        activateThirdFilters(plugin);
                        activateFifthFilters(plugin);
                        activateSeventhFilters(plugin);
                    end
                    setThirdIntervalDistance(plugin,4);
                    changeThirdFilterNote(plugin);
                    setFifthIntervalDistance(plugin,7);
                    changeFifthFilterNote(plugin);
                    setSeventhIntervalDistance(plugin,11);
                    changeSeventhFilterNote(plugin);
                case EQChordType.minor7b5
                    if plugin.rootFiltersActive
                        activateThirdFilters(plugin);
                        activateFifthFilters(plugin);
                        activateSeventhFilters(plugin);
                    end
                    setThirdIntervalDistance(plugin,3);
                    changeThirdFilterNote(plugin);
                    setFifthIntervalDistance(plugin,6);
                    changeFifthFilterNote(plugin);
                    setSeventhIntervalDistance(plugin,10);
                    changeSeventhFilterNote(plugin);
                case EQChordType.diminished7
                    if plugin.rootFiltersActive
                        activateThirdFilters(plugin);
                        activateFifthFilters(plugin);
                        activateSeventhFilters(plugin);
                    end
                    setThirdIntervalDistance(plugin,3);
                    changeThirdFilterNote(plugin);
                    setFifthIntervalDistance(plugin,6);
                    changeFifthFilterNote(plugin);
                    setSeventhIntervalDistance(plugin,9);
                    changeSeventhFilterNote(plugin);
            end
        end
        
        
        %------------------------High Region Controls----------------------
        function set.highRegionGain(plugin,val)
            plugin.highRegionGain = val;
            updateHighRegionGain(plugin,val);
        end
        
        function set.highRegionQFactor(plugin,val)
            plugin.highRegionQFactor = val;
            updateHighRegionQFactor(plugin,val);
        end
        
        %----------------------High-Mid Region Controls--------------------
        function set.highMidRegionGain(plugin,val)
            plugin.highMidRegionGain = val;
            updateHighMidRegionGain(plugin,val);
        end
        
        function set.highMidRegionQFactor(plugin,val)
            plugin.highMidRegionQFactor = val;
            updateHighMidRegionQFactor(plugin,val)
        end
        
        %------------------------Mid Region Controls-----------------------
        function set.midRegionGain(plugin,val)
            plugin.midRegionGain = val;
            updateMidRegionGain(plugin,val)
        end
        
        function set.midRegionQFactor(plugin,val)
            plugin.midRegionQFactor = val;
            updateMidRegionQFactor(plugin,val);
        end
        
        %----------------------Low-Mid Region Controls---------------------
        function set.lowMidRegionGain(plugin,val)
            plugin.lowMidRegionGain = val;
            updateLowMidRegionGain(plugin,val);
        end
        
        function set.lowMidRegionQFactor(plugin,val)
            plugin.lowMidRegionQFactor = val;
            updateLowMidRegionQFactor(plugin,val);
        end
        
        
        %------------------------Low Region Controls-----------------------
        function set.lowRegionGain(plugin,val)
            plugin.lowRegionGain = val;
            updateLowRegionGain(plugin,val);
        end
        
        function set.lowRegionQFactor(plugin,val)
            plugin.lowRegionQFactor = val;
            updateLowRegionQFactor(plugin,val)
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
                    gain = plugin.rootFilter1GainTarget; 
                    plugin.rootGain1 = gain;
                    
                    plugin.rootFilter1GainDiff = 0;
                    plugin.rootFilter1GainSmooth = false; % Set gain smoothing to false
                    
                    if plugin.rootFiltersDeactivating
                        plugin.rootFiltersActive = false;
                        plugin.rootFiltersDeactivating = false;
                    elseif plugin.rootFiltersChangingNote
                        plugin.rootFiltersChangingNote = false;
                        updateRootFrequencies(plugin);
                        updateRootFilterParams(plugin);
                    end
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
                    gain = plugin.rootFilter2GainTarget;
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
                    gain = plugin.rootFilter3GainTarget; 
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
                    gain = plugin.rootFilter4GainTarget; 
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
                    gain = plugin.rootFilter5GainTarget; 
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
                    gain = plugin.rootFilter6GainTarget; 
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
                    gain = plugin.rootFilter7GainTarget; 
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
                    gain = plugin.rootFilter8GainTarget; 
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
                    gain = plugin.rootFilter9GainTarget; 
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
        
        %----------------Harmonic third filter builders--------------------
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
                    gain = plugin.thirdFilter1GainTarget;
                    plugin.thirdGain1 = gain;
                    
                    plugin.thirdFilter1GainDiff = 0;
                    plugin.thirdFilter1GainSmooth = false; % Set gain smoothing to false
                    
                    if plugin.thirdFiltersDeactivating
                        plugin.thirdFiltersActive = false;
                        plugin.thirdFiltersDeactivating = false;
                    elseif plugin.thirdFiltersChangingNote
                        plugin.thirdFiltersChangingNote = false;
                        %updateRootFrequencies(plugin);
                        updateThirdFrequencies(plugin);
                        updateThirdFilterParams(plugin);
                    end
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
                    gain = plugin.thirdFilter2GainTarget; 
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
                    gain = plugin.thirdFilter3GainTarget; 
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
                    gain = plugin.thirdFilter4GainTarget; 
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
                    gain = plugin.thirdFilter5GainTarget; 
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
                    gain = plugin.thirdFilter6GainTarget; 
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
            % Case: no smoothing active
            if ~plugin.thirdFilter7GainSmooth && ~plugin.thirdFilter7QSmooth
                [plugin.thirdCoeffb7, plugin.thirdCoeffa7] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency7,...
                    plugin.thirdQFactor7,...
                    plugin.thirdGain7);
                plugin.updateThirdFilter7 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.thirdGain7;
                qFactor = plugin.thirdQFactor7;
                gainStep = plugin.thirdFilter7GainStep;
                qStep = plugin.thirdFilter7QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.thirdFilter7GainDiff;
                    plugin.thirdFilter7GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.thirdGain7 = gain; % store updated gain value
                    
                elseif plugin.thirdFilter7GainSmooth % Case: final step of gain smoothing
                    gain = plugin.thirdFilter7GainTarget; 
                    plugin.thirdGain7 = gain;
                    
                    plugin.thirdFilter7GainDiff = 0;
                    plugin.thirdFilter7GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.thirdFilter7QDiff;
                    plugin.thirdFilter7QStep = qStep + 1; %iterate q smooth step counter
                    plugin.thirdQFactor7 = qFactor; % store updated q value
                    
                elseif plugin.thirdFilter7QSmooth % Case: final step of q smoothing
                    qFactor = plugin.thirdFilter7QTarget;
                    plugin.thirdQFactor7 = qFactor;
                    
                    plugin.thirdFilter7QDiff = 0;
                    plugin.thirdFilter7QSmooth = false; % set q smoothing to false
                end
                
                [plugin.thirdCoeffb7, plugin.thirdCoeffa7] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency7,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildThirdFilter8(plugin, fs)
            % Case: no smoothing active
            if ~plugin.thirdFilter8GainSmooth && ~plugin.thirdFilter8QSmooth
                [plugin.thirdCoeffb8, plugin.thirdCoeffa8] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency8,...
                    plugin.thirdQFactor8,...
                    plugin.thirdGain8);
                plugin.updateThirdFilter8 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.thirdGain8;
                qFactor = plugin.thirdQFactor8;
                gainStep = plugin.thirdFilter8GainStep;
                qStep = plugin.thirdFilter8QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.thirdFilter8GainDiff;
                    plugin.thirdFilter8GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.thirdGain8 = gain; % store updated gain value
                    
                elseif plugin.thirdFilter8GainSmooth % Case: final step of gain smoothing
                    gain = plugin.thirdFilter8GainTarget; 
                    plugin.thirdGain8 = gain;
                    
                    plugin.thirdFilter8GainDiff = 0;
                    plugin.thirdFilter8GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.thirdFilter8QDiff;
                    plugin.thirdFilter8QStep = qStep + 1; %iterate q smooth step counter
                    plugin.thirdQFactor8 = qFactor; % store updated q value
                    
                elseif plugin.thirdFilter8QSmooth % Case: final step of q smoothing
                    qFactor = plugin.thirdFilter8QTarget;
                    plugin.thirdQFactor8 = qFactor;
                    
                    plugin.thirdFilter8QDiff = 0;
                    plugin.thirdFilter8QSmooth = false; % set q smoothing to false
                end
                
                [plugin.thirdCoeffb8, plugin.thirdCoeffa8] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency8,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildThirdFilter9(plugin, fs)
            % Case: no smoothing active
            if ~plugin.thirdFilter9GainSmooth && ~plugin.thirdFilter9QSmooth
                [plugin.thirdCoeffb9, plugin.thirdCoeffa9] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency9,...
                    plugin.thirdQFactor9,...
                    plugin.thirdGain9);
                plugin.updateThirdFilter9 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.thirdGain9;
                qFactor = plugin.thirdQFactor9;
                gainStep = plugin.thirdFilter9GainStep;
                qStep = plugin.thirdFilter9QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.thirdFilter9GainDiff;
                    plugin.thirdFilter9GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.thirdGain9 = gain; % store updated gain value
                    
                elseif plugin.thirdFilter9GainSmooth % Case: final step of gain smoothing
                    gain = plugin.thirdFilter9GainTarget; 
                    plugin.thirdGain9 = gain;
                    
                    plugin.thirdFilter9GainDiff = 0;
                    plugin.thirdFilter9GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.thirdFilter9QDiff;
                    plugin.thirdFilter9QStep = qStep + 1; %iterate q smooth step counter
                    plugin.thirdQFactor9 = qFactor; % store updated q value
                    
                elseif plugin.thirdFilter9QSmooth % Case: final step of q smoothing
                    qFactor = plugin.thirdFilter9QTarget;
                    plugin.thirdQFactor9 = qFactor;
                    
                    plugin.thirdFilter9QDiff = 0;
                    plugin.thirdFilter9QSmooth = false; % set q smoothing to false
                end
                
                [plugin.thirdCoeffb9, plugin.thirdCoeffa9] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.thirdFrequency9,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        %----------------Harmonic fifth filter builders--------------------
        function buildFifthFilter1(plugin, fs)
            % Case: no smoothing active
            if ~plugin.fifthFilter1GainSmooth && ~plugin.fifthFilter1QSmooth
                [plugin.fifthCoeffb1, plugin.fifthCoeffa1] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency1,...
                    plugin.fifthQFactor1,...
                    plugin.fifthGain1);
                plugin.updateFifthFilter1 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.fifthGain1;
                qFactor = plugin.fifthQFactor1;
                gainStep = plugin.fifthFilter1GainStep;
                qStep = plugin.fifthFilter1QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.fifthFilter1GainDiff;
                    plugin.fifthFilter1GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.fifthGain1 = gain; % store updated gain value
                    
                elseif plugin.fifthFilter1GainSmooth % Case: final step of gain smoothing
                    gain = plugin.fifthFilter1GainTarget; 
                    plugin.fifthGain1 = gain;
                    
                    plugin.fifthFilter1GainDiff = 0;
                    plugin.fifthFilter1GainSmooth = false; % Set gain smoothing to false
                    
                    if plugin.fifthFiltersDeactivating
                        plugin.fifthFiltersActive = false;
                        plugin.fifthFiltersDeactivating = false;
                    elseif plugin.fifthFiltersChangingNote
                        plugin.fifthFiltersChangingNote = false;
                        updateFifthFrequencies(plugin);
                        updateFifthFilterParams(plugin);
                    end
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.fifthFilter1QDiff;
                    plugin.fifthFilter1QStep = qStep + 1; %iterate q smooth step counter
                    plugin.fifthQFactor1 = qFactor; % store updated q value
                    
                elseif plugin.fifthFilter1QSmooth % Case: final step of q smoothing
                    qFactor = plugin.fifthFilter1QTarget;
                    plugin.fifthQFactor1 = qFactor;
                    
                    plugin.fifthFilter1QDiff = 0;
                    plugin.fifthFilter1QSmooth = false; % set q smoothing to false
                end
                
                [plugin.fifthCoeffb1, plugin.fifthCoeffa1] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency1,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildFifthFilter2(plugin, fs)
            % Case: no smoothing active
            if ~plugin.fifthFilter2GainSmooth && ~plugin.fifthFilter2QSmooth
                [plugin.fifthCoeffb2, plugin.fifthCoeffa2] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency2,...
                    plugin.fifthQFactor2,...
                    plugin.fifthGain2);
                plugin.updateFifthFilter2 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.fifthGain2;
                qFactor = plugin.fifthQFactor2;
                gainStep = plugin.fifthFilter2GainStep;
                qStep = plugin.fifthFilter2QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.fifthFilter2GainDiff;
                    plugin.fifthFilter2GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.fifthGain2 = gain; % store updated gain value
                    
                elseif plugin.fifthFilter2GainSmooth % Case: final step of gain smoothing
                    gain = plugin.fifthFilter2GainTarget; 
                    plugin.fifthGain2 = gain;
                    
                    plugin.fifthFilter2GainDiff = 0;
                    plugin.fifthFilter2GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.fifthFilter2QDiff;
                    plugin.fifthFilter2QStep = qStep + 1; %iterate q smooth step counter
                    plugin.fifthQFactor2 = qFactor; % store updated q value
                    
                elseif plugin.fifthFilter2QSmooth % Case: final step of q smoothing
                    qFactor = plugin.fifthFilter2QTarget;
                    plugin.fifthQFactor2 = qFactor;
                    
                    plugin.fifthFilter2QDiff = 0;
                    plugin.fifthFilter2QSmooth = false; % set q smoothing to false
                end
                
                [plugin.fifthCoeffb2, plugin.fifthCoeffa2] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency2,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildFifthFilter3(plugin, fs)
            % Case: no smoothing active
            if ~plugin.fifthFilter3GainSmooth && ~plugin.fifthFilter3QSmooth
                [plugin.fifthCoeffb3, plugin.fifthCoeffa3] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency3,...
                    plugin.fifthQFactor3,...
                    plugin.fifthGain3);
                plugin.updateFifthFilter3 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.fifthGain3;
                qFactor = plugin.fifthQFactor3;
                gainStep = plugin.fifthFilter3GainStep;
                qStep = plugin.fifthFilter3QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.fifthFilter3GainDiff;
                    plugin.fifthFilter3GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.fifthGain3 = gain; % store updated gain value
                    
                elseif plugin.fifthFilter3GainSmooth % Case: final step of gain smoothing
                    gain = plugin.fifthFilter3GainTarget; 
                    plugin.fifthGain3 = gain;
                    
                    plugin.fifthFilter3GainDiff = 0;
                    plugin.fifthFilter3GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.fifthFilter3QDiff;
                    plugin.fifthFilter3QStep = qStep + 1; %iterate q smooth step counter
                    plugin.fifthQFactor3 = qFactor; % store updated q value
                    
                elseif plugin.fifthFilter3QSmooth % Case: final step of q smoothing
                    qFactor = plugin.fifthFilter3QTarget;
                    plugin.fifthQFactor3 = qFactor;
                    
                    plugin.fifthFilter3QDiff = 0;
                    plugin.fifthFilter3QSmooth = false; % set q smoothing to false
                end
                
                [plugin.fifthCoeffb3, plugin.fifthCoeffa3] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency3,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildFifthFilter4(plugin, fs)
            % Case: no smoothing active
            if ~plugin.fifthFilter4GainSmooth && ~plugin.fifthFilter4QSmooth
                [plugin.fifthCoeffb4, plugin.fifthCoeffa4] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency4,...
                    plugin.fifthQFactor4,...
                    plugin.fifthGain4);
                plugin.updateFifthFilter4 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.fifthGain4;
                qFactor = plugin.fifthQFactor4;
                gainStep = plugin.fifthFilter4GainStep;
                qStep = plugin.fifthFilter4QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.fifthFilter4GainDiff;
                    plugin.fifthFilter4GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.fifthGain4 = gain; % store updated gain value
                    
                elseif plugin.fifthFilter4GainSmooth % Case: final step of gain smoothing
                    gain = plugin.fifthFilter4GainTarget; 
                    plugin.fifthGain4 = gain;
                    
                    plugin.fifthFilter4GainDiff = 0;
                    plugin.fifthFilter4GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.fifthFilter4QDiff;
                    plugin.fifthFilter4QStep = qStep + 1; %iterate q smooth step counter
                    plugin.fifthQFactor4 = qFactor; % store updated q value
                    
                elseif plugin.fifthFilter4QSmooth % Case: final step of q smoothing
                    qFactor = plugin.fifthFilter4QTarget;
                    plugin.fifthQFactor4 = qFactor;
                    
                    plugin.fifthFilter4QDiff = 0;
                    plugin.fifthFilter4QSmooth = false; % set q smoothing to false
                end
                
                [plugin.fifthCoeffb4, plugin.fifthCoeffa4] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency4,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildFifthFilter5(plugin, fs)
            % Case: no smoothing active
            if ~plugin.fifthFilter5GainSmooth && ~plugin.fifthFilter5QSmooth
                [plugin.fifthCoeffb5, plugin.fifthCoeffa5] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency5,...
                    plugin.fifthQFactor5,...
                    plugin.fifthGain5);
                plugin.updateFifthFilter5 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.fifthGain5;
                qFactor = plugin.fifthQFactor5;
                gainStep = plugin.fifthFilter5GainStep;
                qStep = plugin.fifthFilter5QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.fifthFilter5GainDiff;
                    plugin.fifthFilter5GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.fifthGain5 = gain; % store updated gain value
                    
                elseif plugin.fifthFilter5GainSmooth % Case: final step of gain smoothing
                    gain = plugin.fifthFilter5GainTarget; 
                    plugin.fifthGain5 = gain;
                    
                    plugin.fifthFilter5GainDiff = 0;
                    plugin.fifthFilter5GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.fifthFilter5QDiff;
                    plugin.fifthFilter5QStep = qStep + 1; %iterate q smooth step counter
                    plugin.fifthQFactor5 = qFactor; % store updated q value
                    
                elseif plugin.fifthFilter5QSmooth % Case: final step of q smoothing
                    qFactor = plugin.fifthFilter5QTarget;
                    plugin.fifthQFactor5 = qFactor;
                    
                    plugin.fifthFilter5QDiff = 0;
                    plugin.fifthFilter5QSmooth = false; % set q smoothing to false
                end
                
                [plugin.fifthCoeffb5, plugin.fifthCoeffa5] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency5,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildFifthFilter6(plugin, fs)
            % Case: no smoothing active
            if ~plugin.fifthFilter6GainSmooth && ~plugin.fifthFilter6QSmooth
                [plugin.fifthCoeffb6, plugin.fifthCoeffa6] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency6,...
                    plugin.fifthQFactor6,...
                    plugin.fifthGain6);
                plugin.updateFifthFilter6 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.fifthGain6;
                qFactor = plugin.fifthQFactor6;
                gainStep = plugin.fifthFilter6GainStep;
                qStep = plugin.fifthFilter6QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.fifthFilter6GainDiff;
                    plugin.fifthFilter6GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.fifthGain6 = gain; % store updated gain value
                    
                elseif plugin.fifthFilter6GainSmooth % Case: final step of gain smoothing
                    gain = plugin.fifthFilter6GainTarget; 
                    plugin.fifthGain6 = gain;
                    
                    plugin.fifthFilter6GainDiff = 0;
                    plugin.fifthFilter6GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.fifthFilter6QDiff;
                    plugin.fifthFilter6QStep = qStep + 1; %iterate q smooth step counter
                    plugin.fifthQFactor6 = qFactor; % store updated q value
                    
                elseif plugin.fifthFilter6QSmooth % Case: final step of q smoothing
                    qFactor = plugin.fifthFilter6QTarget;
                    plugin.fifthQFactor6 = qFactor;
                    
                    plugin.fifthFilter6QDiff = 0;
                    plugin.fifthFilter6QSmooth = false; % set q smoothing to false
                end
                
                [plugin.fifthCoeffb6, plugin.fifthCoeffa6] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency6,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildFifthFilter7(plugin, fs)
            % Case: no smoothing active
            if ~plugin.fifthFilter7GainSmooth && ~plugin.fifthFilter7QSmooth
                [plugin.fifthCoeffb7, plugin.fifthCoeffa7] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency7,...
                    plugin.fifthQFactor7,...
                    plugin.fifthGain7);
                plugin.updateFifthFilter7 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.fifthGain7;
                qFactor = plugin.fifthQFactor7;
                gainStep = plugin.fifthFilter7GainStep;
                qStep = plugin.fifthFilter7QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.fifthFilter7GainDiff;
                    plugin.fifthFilter7GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.fifthGain7 = gain; % store updated gain value
                    
                elseif plugin.fifthFilter7GainSmooth % Case: final step of gain smoothing
                    gain = plugin.fifthFilter7GainTarget; 
                    plugin.fifthGain7 = gain;
                    
                    plugin.fifthFilter7GainDiff = 0;
                    plugin.fifthFilter7GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.fifthFilter7QDiff;
                    plugin.fifthFilter7QStep = qStep + 1; %iterate q smooth step counter
                    plugin.fifthQFactor7 = qFactor; % store updated q value
                    
                elseif plugin.fifthFilter7QSmooth % Case: final step of q smoothing
                    qFactor = plugin.fifthFilter7QTarget;
                    plugin.fifthQFactor7 = qFactor;
                    
                    plugin.fifthFilter7QDiff = 0;
                    plugin.fifthFilter7QSmooth = false; % set q smoothing to false
                end
                
                [plugin.fifthCoeffb7, plugin.fifthCoeffa7] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency7,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildFifthFilter8(plugin, fs)
            % Case: no smoothing active
            if ~plugin.fifthFilter8GainSmooth && ~plugin.fifthFilter8QSmooth
                [plugin.fifthCoeffb8, plugin.fifthCoeffa8] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency8,...
                    plugin.fifthQFactor8,...
                    plugin.fifthGain8);
                plugin.updateFifthFilter8 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.fifthGain8;
                qFactor = plugin.fifthQFactor8;
                gainStep = plugin.fifthFilter8GainStep;
                qStep = plugin.fifthFilter8QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.fifthFilter8GainDiff;
                    plugin.fifthFilter8GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.fifthGain8 = gain; % store updated gain value
                    
                elseif plugin.fifthFilter8GainSmooth % Case: final step of gain smoothing
                    gain = plugin.fifthFilter8GainTarget; 
                    plugin.fifthGain8 = gain;
                    
                    plugin.fifthFilter8GainDiff = 0;
                    plugin.fifthFilter8GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.fifthFilter8QDiff;
                    plugin.fifthFilter8QStep = qStep + 1; %iterate q smooth step counter
                    plugin.fifthQFactor8 = qFactor; % store updated q value
                    
                elseif plugin.fifthFilter8QSmooth % Case: final step of q smoothing
                    qFactor = plugin.fifthFilter8QTarget;
                    plugin.fifthQFactor8 = qFactor;
                    
                    plugin.fifthFilter8QDiff = 0;
                    plugin.fifthFilter8QSmooth = false; % set q smoothing to false
                end
                
                [plugin.fifthCoeffb8, plugin.fifthCoeffa8] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency8,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildFifthFilter9(plugin, fs)
            % Case: no smoothing active
            if ~plugin.fifthFilter9GainSmooth && ~plugin.fifthFilter9QSmooth
                [plugin.fifthCoeffb9, plugin.fifthCoeffa9] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency9,...
                    plugin.fifthQFactor9,...
                    plugin.fifthGain9);
                plugin.updateFifthFilter9 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.fifthGain9;
                qFactor = plugin.fifthQFactor9;
                gainStep = plugin.fifthFilter9GainStep;
                qStep = plugin.fifthFilter9QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.fifthFilter9GainDiff;
                    plugin.fifthFilter9GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.fifthGain9 = gain; % store updated gain value
                    
                elseif plugin.fifthFilter9GainSmooth % Case: final step of gain smoothing
                    gain = plugin.fifthFilter9GainTarget; 
                    plugin.fifthGain9 = gain;
                    
                    plugin.fifthFilter9GainDiff = 0;
                    plugin.fifthFilter9GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.fifthFilter9QDiff;
                    plugin.fifthFilter9QStep = qStep + 1; %iterate q smooth step counter
                    plugin.fifthQFactor9 = qFactor; % store updated q value
                    
                elseif plugin.fifthFilter9QSmooth % Case: final step of q smoothing
                    qFactor = plugin.fifthFilter9QTarget;
                    plugin.fifthQFactor9 = qFactor;
                    
                    plugin.fifthFilter9QDiff = 0;
                    plugin.fifthFilter9QSmooth = false; % set q smoothing to false
                end
                
                [plugin.fifthCoeffb9, plugin.fifthCoeffa9] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.fifthFrequency9,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        %---------------Harmonic seventh filter builders-------------------
        function buildSeventhFilter1(plugin, fs)
            % Case: no smoothing active
            if ~plugin.seventhFilter1GainSmooth && ~plugin.seventhFilter1QSmooth
                [plugin.seventhCoeffb1, plugin.seventhCoeffa1] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency1,...
                    plugin.seventhQFactor1,...
                    plugin.seventhGain1);
                plugin.updateSeventhFilter1 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.seventhGain1;
                qFactor = plugin.seventhQFactor1;
                gainStep = plugin.seventhFilter1GainStep;
                qStep = plugin.seventhFilter1QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.seventhFilter1GainDiff;
                    plugin.seventhFilter1GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.seventhGain1 = gain; % store updated gain value
                    
                elseif plugin.seventhFilter1GainSmooth % Case: final step of gain smoothing
                    gain = plugin.seventhFilter1GainTarget; 
                    plugin.seventhGain1 = gain;
                    
                    plugin.seventhFilter1GainDiff = 0;
                    plugin.seventhFilter1GainSmooth = false; % Set gain smoothing to false
                    
                    if plugin.seventhFiltersDeactivating
                        plugin.seventhFiltersActive = false;
                        plugin.seventhFiltersDeactivating = false;
                    elseif plugin.seventhFiltersChangingNote
                        plugin.seventhFiltersChangingNote = false;
                        updateSeventhFrequencies(plugin);
                        updateSeventhFilterParams(plugin);
                    end
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.seventhFilter1QDiff;
                    plugin.seventhFilter1QStep = qStep + 1; %iterate q smooth step counter
                    plugin.seventhQFactor1 = qFactor; % store updated q value
                    
                elseif plugin.seventhFilter1QSmooth % Case: final step of q smoothing
                    qFactor = plugin.seventhFilter1QTarget;
                    plugin.seventhQFactor1 = qFactor;
                    
                    plugin.seventhFilter1QDiff = 0;
                    plugin.seventhFilter1QSmooth = false; % set q smoothing to false
                end
                
                [plugin.seventhCoeffb1, plugin.seventhCoeffa1] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency1,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildSeventhFilter2(plugin, fs)
            % Case: no smoothing active
            if ~plugin.seventhFilter2GainSmooth && ~plugin.seventhFilter2QSmooth
                [plugin.seventhCoeffb2, plugin.seventhCoeffa2] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency2,...
                    plugin.seventhQFactor2,...
                    plugin.seventhGain2);
                plugin.updateSeventhFilter2 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.seventhGain2;
                qFactor = plugin.seventhQFactor2;
                gainStep = plugin.seventhFilter2GainStep;
                qStep = plugin.seventhFilter2QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.seventhFilter2GainDiff;
                    plugin.seventhFilter2GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.seventhGain2 = gain; % store updated gain value
                    
                elseif plugin.seventhFilter2GainSmooth % Case: final step of gain smoothing
                    gain = plugin.seventhFilter2GainTarget; 
                    plugin.seventhGain2 = gain;
                    
                    plugin.seventhFilter2GainDiff = 0;
                    plugin.seventhFilter2GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.seventhFilter2QDiff;
                    plugin.seventhFilter2QStep = qStep + 1; %iterate q smooth step counter
                    plugin.seventhQFactor2 = qFactor; % store updated q value
                    
                elseif plugin.seventhFilter2QSmooth % Case: final step of q smoothing
                    qFactor = plugin.seventhFilter2QTarget;
                    plugin.seventhQFactor2 = qFactor;
                    
                    plugin.seventhFilter2QDiff = 0;
                    plugin.seventhFilter2QSmooth = false; % set q smoothing to false
                end
                
                [plugin.seventhCoeffb2, plugin.seventhCoeffa2] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency2,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildSeventhFilter3(plugin, fs)
            % Case: no smoothing active
            if ~plugin.seventhFilter3GainSmooth && ~plugin.seventhFilter3QSmooth
                [plugin.seventhCoeffb3, plugin.seventhCoeffa3] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency3,...
                    plugin.seventhQFactor3,...
                    plugin.seventhGain3);
                plugin.updateSeventhFilter3 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.seventhGain3;
                qFactor = plugin.seventhQFactor3;
                gainStep = plugin.seventhFilter3GainStep;
                qStep = plugin.seventhFilter3QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.seventhFilter3GainDiff;
                    plugin.seventhFilter3GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.seventhGain3 = gain; % store updated gain value
                    
                elseif plugin.seventhFilter3GainSmooth % Case: final step of gain smoothing
                    gain = plugin.seventhFilter3GainTarget; 
                    plugin.seventhGain3 = gain;
                    
                    plugin.seventhFilter3GainDiff = 0;
                    plugin.seventhFilter3GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.seventhFilter3QDiff;
                    plugin.seventhFilter3QStep = qStep + 1; %iterate q smooth step counter
                    plugin.seventhQFactor3 = qFactor; % store updated q value
                    
                elseif plugin.seventhFilter3QSmooth % Case: final step of q smoothing
                    qFactor = plugin.seventhFilter3QTarget;
                    plugin.seventhQFactor3 = qFactor;
                    
                    plugin.seventhFilter3QDiff = 0;
                    plugin.seventhFilter3QSmooth = false; % set q smoothing to false
                end
                
                [plugin.seventhCoeffb3, plugin.seventhCoeffa3] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency3,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildSeventhFilter4(plugin, fs)
            % Case: no smoothing active
            if ~plugin.seventhFilter4GainSmooth && ~plugin.seventhFilter4QSmooth
                [plugin.seventhCoeffb4, plugin.seventhCoeffa4] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency4,...
                    plugin.seventhQFactor4,...
                    plugin.seventhGain4);
                plugin.updateSeventhFilter4 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.seventhGain4;
                qFactor = plugin.seventhQFactor4;
                gainStep = plugin.seventhFilter4GainStep;
                qStep = plugin.seventhFilter4QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.seventhFilter4GainDiff;
                    plugin.seventhFilter4GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.seventhGain4 = gain; % store updated gain value
                    
                elseif plugin.seventhFilter4GainSmooth % Case: final step of gain smoothing
                    gain = plugin.seventhFilter4GainTarget; 
                    plugin.seventhGain4 = gain;
                    
                    plugin.seventhFilter4GainDiff = 0;
                    plugin.seventhFilter4GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.seventhFilter4QDiff;
                    plugin.seventhFilter4QStep = qStep + 1; %iterate q smooth step counter
                    plugin.seventhQFactor4 = qFactor; % store updated q value
                    
                elseif plugin.seventhFilter4QSmooth % Case: final step of q smoothing
                    qFactor = plugin.seventhFilter4QTarget;
                    plugin.seventhQFactor4 = qFactor;
                    
                    plugin.seventhFilter4QDiff = 0;
                    plugin.seventhFilter4QSmooth = false; % set q smoothing to false
                end
                
                [plugin.seventhCoeffb4, plugin.seventhCoeffa4] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency4,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildSeventhFilter5(plugin, fs)
            % Case: no smoothing active
            if ~plugin.seventhFilter5GainSmooth && ~plugin.seventhFilter5QSmooth
                [plugin.seventhCoeffb5, plugin.seventhCoeffa5] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency5,...
                    plugin.seventhQFactor5,...
                    plugin.seventhGain5);
                plugin.updateSeventhFilter5 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.seventhGain5;
                qFactor = plugin.seventhQFactor5;
                gainStep = plugin.seventhFilter5GainStep;
                qStep = plugin.seventhFilter5QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.seventhFilter5GainDiff;
                    plugin.seventhFilter5GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.seventhGain5 = gain; % store updated gain value
                    
                elseif plugin.seventhFilter5GainSmooth % Case: final step of gain smoothing
                    gain = plugin.seventhFilter5GainTarget; 
                    plugin.seventhGain5 = gain;
                    
                    plugin.seventhFilter5GainDiff = 0;
                    plugin.seventhFilter5GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.seventhFilter5QDiff;
                    plugin.seventhFilter5QStep = qStep + 1; %iterate q smooth step counter
                    plugin.seventhQFactor5 = qFactor; % store updated q value
                    
                elseif plugin.seventhFilter5QSmooth % Case: final step of q smoothing
                    qFactor = plugin.seventhFilter5QTarget;
                    plugin.seventhQFactor5 = qFactor;
                    
                    plugin.seventhFilter5QDiff = 0;
                    plugin.seventhFilter5QSmooth = false; % set q smoothing to false
                end
                
                [plugin.seventhCoeffb5, plugin.seventhCoeffa5] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency5,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildSeventhFilter6(plugin, fs)
            % Case: no smoothing active
            if ~plugin.seventhFilter6GainSmooth && ~plugin.seventhFilter6QSmooth
                [plugin.seventhCoeffb6, plugin.seventhCoeffa6] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency6,...
                    plugin.seventhQFactor6,...
                    plugin.seventhGain6);
                plugin.updateSeventhFilter6 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.seventhGain6;
                qFactor = plugin.seventhQFactor6;
                gainStep = plugin.seventhFilter6GainStep;
                qStep = plugin.seventhFilter6QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.seventhFilter6GainDiff;
                    plugin.seventhFilter6GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.seventhGain6 = gain; % store updated gain value
                    
                elseif plugin.seventhFilter6GainSmooth % Case: final step of gain smoothing
                    gain = plugin.seventhFilter6GainTarget; 
                    plugin.seventhGain6 = gain;
                    
                    plugin.seventhFilter6GainDiff = 0;
                    plugin.seventhFilter6GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.seventhFilter6QDiff;
                    plugin.seventhFilter6QStep = qStep + 1; %iterate q smooth step counter
                    plugin.seventhQFactor6 = qFactor; % store updated q value
                    
                elseif plugin.seventhFilter6QSmooth % Case: final step of q smoothing
                    qFactor = plugin.seventhFilter6QTarget;
                    plugin.seventhQFactor6 = qFactor;
                    
                    plugin.seventhFilter6QDiff = 0;
                    plugin.seventhFilter6QSmooth = false; % set q smoothing to false
                end
                
                [plugin.seventhCoeffb6, plugin.seventhCoeffa6] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency6,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildSeventhFilter7(plugin, fs)
            % Case: no smoothing active
            if ~plugin.seventhFilter7GainSmooth && ~plugin.seventhFilter7QSmooth
                [plugin.seventhCoeffb7, plugin.seventhCoeffa7] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency7,...
                    plugin.seventhQFactor7,...
                    plugin.seventhGain7);
                plugin.updateSeventhFilter7 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.seventhGain7;
                qFactor = plugin.seventhQFactor7;
                gainStep = plugin.seventhFilter7GainStep;
                qStep = plugin.seventhFilter7QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.seventhFilter7GainDiff;
                    plugin.seventhFilter7GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.seventhGain7 = gain; % store updated gain value
                    
                elseif plugin.seventhFilter7GainSmooth % Case: final step of gain smoothing
                    gain = plugin.seventhFilter7GainTarget; 
                    plugin.seventhGain7 = gain;
                    
                    plugin.seventhFilter7GainDiff = 0;
                    plugin.seventhFilter7GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.seventhFilter7QDiff;
                    plugin.seventhFilter7QStep = qStep + 1; %iterate q smooth step counter
                    plugin.seventhQFactor7 = qFactor; % store updated q value
                    
                elseif plugin.seventhFilter7QSmooth % Case: final step of q smoothing
                    qFactor = plugin.seventhFilter7QTarget;
                    plugin.seventhQFactor7 = qFactor;
                    
                    plugin.seventhFilter7QDiff = 0;
                    plugin.seventhFilter7QSmooth = false; % set q smoothing to false
                end
                
                [plugin.seventhCoeffb7, plugin.seventhCoeffa7] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency7,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildSeventhFilter8(plugin, fs)
            % Case: no smoothing active
            if ~plugin.seventhFilter8GainSmooth && ~plugin.seventhFilter8QSmooth
                [plugin.seventhCoeffb8, plugin.seventhCoeffa8] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency8,...
                    plugin.seventhQFactor8,...
                    plugin.seventhGain8);
                plugin.updateSeventhFilter8 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.seventhGain8;
                qFactor = plugin.seventhQFactor8;
                gainStep = plugin.seventhFilter8GainStep;
                qStep = plugin.seventhFilter8QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.seventhFilter8GainDiff;
                    plugin.seventhFilter8GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.seventhGain8 = gain; % store updated gain value
                    
                elseif plugin.seventhFilter8GainSmooth % Case: final step of gain smoothing
                    gain = plugin.seventhFilter8GainTarget; 
                    plugin.seventhGain8 = gain;
                    
                    plugin.seventhFilter8GainDiff = 0;
                    plugin.seventhFilter8GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.seventhFilter8QDiff;
                    plugin.seventhFilter8QStep = qStep + 1; %iterate q smooth step counter
                    plugin.seventhQFactor8 = qFactor; % store updated q value
                    
                elseif plugin.seventhFilter8QSmooth % Case: final step of q smoothing
                    qFactor = plugin.seventhFilter8QTarget;
                    plugin.seventhQFactor8 = qFactor;
                    
                    plugin.seventhFilter8QDiff = 0;
                    plugin.seventhFilter8QSmooth = false; % set q smoothing to false
                end
                
                [plugin.seventhCoeffb8, plugin.seventhCoeffa8] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency8,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        function buildSeventhFilter9(plugin, fs)
            % Case: no smoothing active
            if ~plugin.seventhFilter9GainSmooth && ~plugin.seventhFilter9QSmooth
                [plugin.seventhCoeffb9, plugin.seventhCoeffa9] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency9,...
                    plugin.seventhQFactor9,...
                    plugin.seventhGain9);
                plugin.updateSeventhFilter9 = false; % No need to update further since no smoothing
                
            else % Case gain or q smoothing is active
                gain = plugin.seventhGain9;
                qFactor = plugin.seventhQFactor9;
                gainStep = plugin.seventhFilter9GainStep;
                qStep = plugin.seventhFilter9QStep;
                
                if gainStep < plugin.numberOfSmoothSteps % Case: gain smoothing active and incomplete
                    gain = gain + plugin.seventhFilter9GainDiff;
                    plugin.seventhFilter9GainStep = gainStep + 1; % iterate gain smooth step counter
                    plugin.seventhGain9 = gain; % store updated gain value
                    
                elseif plugin.seventhFilter9GainSmooth % Case: final step of gain smoothing
                    gain = plugin.seventhFilter9GainTarget; 
                    plugin.seventhGain9 = gain;
                    
                    plugin.seventhFilter9GainDiff = 0;
                    plugin.seventhFilter9GainSmooth = false; % Set gain smoothing to false
                end
                
                if qStep < plugin.numberOfSmoothSteps
                    qFactor = qFactor + plugin.seventhFilter9QDiff;
                    plugin.seventhFilter9QStep = qStep + 1; %iterate q smooth step counter
                    plugin.seventhQFactor9 = qFactor; % store updated q value
                    
                elseif plugin.seventhFilter9QSmooth % Case: final step of q smoothing
                    qFactor = plugin.seventhFilter9QTarget;
                    plugin.seventhQFactor9 = qFactor;
                    
                    plugin.seventhFilter9QDiff = 0;
                    plugin.seventhFilter9QSmooth = false; % set q smoothing to false
                end
                
                [plugin.seventhCoeffb9, plugin.seventhCoeffa9] = peakNotchFilterCoeffs(...
                    plugin, fs, ...
                    plugin.seventhFrequency9,...
                    qFactor,...
                    gain);
            end
            updateStateChangeStatus(plugin, true);
        end
        
        
        %------------------------------------------------------------------
        % UPDATERS & HELPERS
        %------------------------------------------------------------------
        
        function updatePrivateRootNote(plugin,val)
            plugin.privateRootNote = val;
            
            switch (plugin.privateRootNote)
                case EQRootNote.off
                    deactivateRootFilters(plugin);
                    deactivateThirdFilters(plugin);
                    deactivateFifthFilters(plugin);
                    deactivateSeventhFilters(plugin);
                otherwise
                    activateRootFilters(plugin);
                    changeRootFilterNote(plugin);
                    updateChord(plugin);
            end
            
            setUpdateRootFilters(plugin);
            setUpdateThirdFilters(plugin);
            setUpdateFifthFilters(plugin);
            setUpdateSeventhFilters(plugin);
            
            % Update visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        function updatePrivateChordType(plugin,val)
            plugin.privateChordType = val;
            updateChord(plugin);
            
            setUpdateRootFilters(plugin);
            setUpdateThirdFilters(plugin);
            setUpdateFifthFilters(plugin);
            setUpdateSeventhFilters(plugin);
            
            % Update visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        %----------------------Control Region Helpers----------------------
        function updateHighRegionGain(plugin,val)
            % This currently always controls the high octave of filters and
            % can be configured to control the 8th octave as well
            if plugin.rootFiltersActive
                updateRootGain9(plugin,val);
                setUpdateRootFilter9(plugin);
                if (plugin.rootFrequency8 > plugin.highCrossoverFreq)
                    updateRootGain8(plugin,val);
                    setUpdateRootFilter8(plugin);
                end
            end
            
            if plugin.thirdFiltersActive
                updateThirdGain9(plugin,val);
                setUpdateThirdFilter9(plugin);
                if (plugin.thirdFrequency8 > plugin.highCrossoverFreq)
                    updateThirdGain8(plugin,val);
                    setUpdateThirdFilter8(plugin);
                end
            end
            
            if plugin.fifthFiltersActive
                updateFifthGain9(plugin,val);
                setUpdateFifthFilter9(plugin);
                if (plugin.fifthFrequency8 > plugin.highCrossoverFreq)
                    updateFifthGain8(plugin,val);
                    setUpdateFifthFilter8(plugin);
                end
            end
            
            if plugin.seventhFiltersActive
                updateSeventhGain9(plugin,val);
                if (plugin.seventhFrequency8 > plugin.highCrossoverFreq)
                    updateSeventhGain8(plugin,val);
                    setUpdateSeventhFilter8(plugin);
                end
            end
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        function updateHighRegionQFactor(plugin,val)
            if plugin.rootFiltersActive
                    updateRootQFactor9(plugin,val);
                    setUpdateRootFilter9(plugin);
                if (plugin.rootFrequency8 > plugin.highCrossoverFreq)
                    updateRootQFactor8(plugin,val);
                    setUpdateRootFilter8(plugin);
                end
            end
            
            if plugin.thirdFiltersActive
                    updateThirdQFactor9(plugin,val);
                    setUpdateThirdFilter9(plugin);
                if (plugin.thirdFrequency8 > plugin.highCrossoverFreq)
                    updateThirdQFactor8(plugin,val);
                    setUpdateThirdFilter8(plugin);
                end
            end
            
            if plugin.fifthFiltersActive
                    updateFifthQFactor9(plugin,val);
                    setUpdateFifthFilter9(plugin);
                if (plugin.fifthFrequency8 > plugin.highCrossoverFreq)
                    updateFifthQFactor8(plugin,val);
                    setUpdateFifthFilter8(plugin);
                end
            end
            
            if plugin.seventhFiltersActive
                    updateSeventhQFactor9(plugin,val);
                    setUpdateSeventhFilter9(plugin);
                if (plugin.seventhFrequency8 > plugin.highCrossoverFreq)
                    updateSeventhQFactor8(plugin,val);
                    setUpdateSeventhFilter8(plugin);
                end
            end
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        function updateHighMidRegionGain(plugin,val)
            if plugin.rootFiltersActive
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
            end
            
            if plugin.thirdFiltersActive
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
            end
            
            if plugin.fifthFiltersActive
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
            end
            
            if plugin.seventhFiltersActive
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
            end
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        function updateHighMidRegionQFactor(plugin,val)
            if plugin.rootFiltersActive
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
            end
            
            if plugin.thirdFiltersActive
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
            end
            
            if plugin.fifthFiltersActive
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
            end
            
            if plugin.seventhFiltersActive
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
            end
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        function updateMidRegionGain(plugin,val)
            if plugin.rootFiltersActive
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
            end
            
            if plugin.thirdFiltersActive
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
            end
            
            if plugin.fifthFiltersActive
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
            end
            
            if plugin.seventhFiltersActive
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
            end
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        function updateMidRegionQFactor(plugin,val)
            if plugin.rootFiltersActive
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
            end
            
            if plugin.thirdFiltersActive
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
            end
            
            if plugin.fifthFiltersActive
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
            end
            
            if plugin.seventhFiltersActive
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
            end
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        function updateLowMidRegionGain(plugin,val)
            if plugin.rootFiltersActive
                if (plugin.rootFrequency4 < plugin.lowMidCrossoverFreq)
                    updateRootGain4(plugin,val);
                    setUpdateRootFilter4(plugin);
                end
                updateRootGain3(plugin,val);
                setUpdateRootFilter3(plugin);
                if (plugin.rootFrequency2 > plugin.lowCrossoverFreq)
                    updateRootGain2(plugin,val);
                end
            end
            
            if plugin.thirdFiltersActive
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
            end
            
            if plugin.fifthFiltersActive
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
            end
            
            if plugin.seventhFiltersActive
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
            end
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        function updateLowMidRegionQFactor(plugin,val)
            if plugin.rootFiltersActive
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
            end
            
            if plugin.thirdFiltersActive
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
            end
            
            if plugin.fifthFiltersActive
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
            end
            
            if plugin.seventhFiltersActive
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
            end
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        function updateLowRegionGain(plugin,val)
            if plugin.rootFiltersActive
                if (plugin.rootFrequency2 < plugin.lowCrossoverFreq)
                    updateRootGain2(plugin,val);
                end
                updateRootGain1(plugin,val);
            end
            
            if plugin.thirdFiltersActive
                if (plugin.thirdFrequency2 < plugin.lowCrossoverFreq)
                    updateThirdGain2(plugin,val);
                    setUpdateThirdFilter2(plugin);
                end
                updateThirdGain1(plugin,val);
                setUpdateThirdFilter1(plugin);
            end
            
            if plugin.fifthFiltersActive
                if (plugin.fifthFrequency2 < plugin.lowCrossoverFreq)
                    updateFifthGain2(plugin,val);
                    setUpdateFifthFilter2(plugin);
                end
                updateFifthGain1(plugin,val);
                setUpdateFifthFilter1(plugin);
            end
            
            if plugin.seventhFiltersActive
                if (plugin.seventhFrequency2 < plugin.lowCrossoverFreq)
                    updateSeventhGain2(plugin,val);
                    setUpdateSeventhFilter2(plugin);
                end
                updateSeventhGain1(plugin,val);
                setUpdateSeventhFilter1(plugin);
            end
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        function updateLowRegionQFactor(plugin,val)
            if plugin.rootFiltersActive
                if (plugin.rootFrequency2 < plugin.lowCrossoverFreq)
                    updateRootQFactor2(plugin,val);
                    setUpdateRootFilter2(plugin);
                end
                updateRootQFactor1(plugin,val);
                setUpdateRootFilter1(plugin);
            end
            
            if plugin.thirdFiltersActive
                if (plugin.thirdFrequency2 < plugin.lowCrossoverFreq)
                    updateThirdQFactor2(plugin,val);
                    setUpdateThirdFilter2(plugin);
                end
                updateThirdQFactor1(plugin,val);
                setUpdateThirdFilter1(plugin);
            end
            
            if plugin.fifthFiltersActive
                if (plugin.fifthFrequency2 < plugin.lowCrossoverFreq)
                    updateFifthQFactor2(plugin,val);
                    setUpdateFifthFilter2(plugin);
                end
                updateFifthQFactor1(plugin,val);
                setUpdateFifthFilter1(plugin);
            end
            
            if plugin.seventhFiltersActive
                if (plugin.seventhFrequency2 < plugin.lowCrossoverFreq)
                    updateSeventhQFactor2(plugin,val);
                    setUpdateSeventhFilter2(plugin);
                end
                updateSeventhQFactor1(plugin,val);
                setUpdateSeventhFilter1(plugin);
            end
            
            % State change update for visualizer
            updateStateChangeStatus(plugin,true);
        end
        
        %-----------------------Root filter updaters-----------------------
        function updateRootFrequencies(plugin)
            root_note = plugin.privateRootNote;
            rootNoteNumber = plugin.rootNoteValue;
            rootFreq = plugin.rootFrequency1;
            
            switch root_note
                case EQRootNote.off
                case EQRootNote.A
                    rootFreq = 55;
                    rootNoteNumber = 9;
                case EQRootNote.Bb
                    rootFreq = 58.27047;
                    rootNoteNumber = 10;
                case EQRootNote.B
                    rootFreq = 61.73541;
                    rootNoteNumber = 11;
                case EQRootNote.C
                    rootFreq = 32.70320;
                    rootNoteNumber = 0;
                case EQRootNote.Db
                    rootFreq = 34.64783;
                    rootNoteNumber = 1;
                case EQRootNote.D
                    rootFreq = 36.70810;
                    rootNoteNumber = 2;
                case EQRootNote.Eb
                    rootFreq = 38.89087;
                    rootNoteNumber = 3;
                case EQRootNote.E
                    rootFreq = 41.20344;
                    rootNoteNumber = 4;
                case EQRootNote.F
                    rootFreq = 43.65353;
                    rootNoteNumber = 5;
                case EQRootNote.Gb
                    rootFreq = 46.24930;
                    rootNoteNumber = 6;
                case EQRootNote.G
                    rootFreq = 48.99943;
                    rootNoteNumber = 7;
                case EQRootNote.Ab
                    rootFreq = 51.91309;
                    rootNoteNumber = 8;
            end
            
            if root_note ~= EQRootNote.off
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
        
        function updateRootFilter2Params(plugin)
            % Case: root filter two is in low control region
            if plugin.rootFrequency2 < plugin.lowCrossoverFreq
                if plugin.rootFilter2GainTarget ~= plugin.lowRegionGain
                    plugin.rootFilter2GainTarget = plugin.lowRegionGain;
                    gainDiff = plugin.lowRegionGain - plugin.rootGain2; % set differential for gain
                    plugin.rootFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.rootFilter2GainStep = 0;
                    plugin.rootFilter2GainSmooth = true;
                end
                
                if plugin.rootFilter2QTarget ~= plugin.lowRegionQFactor
                    plugin.rootFilter2QTarget = plugin.lowRegionQFactor;
                    qDiff = plugin.lowRegionQFactor - plugin.rootQFactor2;
                    plugin.rootFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.rootFilter2QStep = 0;
                    plugin.rootFilter2QSmooth = true;
                end
                
            else % Case: root filter 2 is in mid-low control region
                if plugin.rootFilter2GainTarget ~= plugin.lowMidRegionGain
                    plugin.rootFilter2GainTarget = plugin.lowMidRegionGain;
                    gainDiff = plugin.lowMidRegionGain - plugin.rootGain2; % set differential for gain
                    plugin.rootFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.rootFilter2GainStep = 0;
                    plugin.rootFilter2GainSmooth = true;
                end
                
                if plugin.rootFilter2QTarget ~= plugin.lowMidRegionQFactor
                    plugin.rootFilter2QTarget = plugin.lowMidRegionQFactor;
                    qDiff = plugin.lowMidRegionQFactor - plugin.rootQFactor2;
                    plugin.rootFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.rootFilter2QStep = 0;
                    plugin.rootFilter2QSmooth = true;
                end
            end
            setUpdateRootFilter2(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootFilter4Params(plugin)
            % Case: root filter 4 is in low-mid control region
            if plugin.rootFrequency4 < plugin.lowMidCrossoverFreq
                if plugin.rootFilter4GainTarget ~= plugin.lowMidRegionGain
                    plugin.rootFilter4GainTarget = plugin.lowMidRegionGain;
                    gainDiff = plugin.lowMidRegionGain - plugin.rootGain4; % set differential for gain
                    plugin.rootFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.rootFilter4GainStep = 0;
                    plugin.rootFilter4GainSmooth = true;
                end
                
                if plugin.rootFilter4QTarget ~= plugin.lowMidRegionQFactor
                    plugin.rootFilter4QTarget = plugin.lowMidRegionQFactor;
                    qDiff = plugin.lowMidRegionQFactor - plugin.rootQFactor4;
                    plugin.rootFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.rootFilter4QStep = 0;
                    plugin.rootFilter4QSmooth = true;
                end
                
            else % Case: root filter 4 is in mid control region
                if plugin.rootFilter4GainTarget ~= plugin.midRegionGain
                    plugin.rootFilter4GainTarget = plugin.midRegionGain;
                    gainDiff = plugin.midRegionGain - plugin.rootGain4; % set differential for gain
                    plugin.rootFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.rootFilter4GainStep = 0;
                    plugin.rootFilter4GainSmooth = true;
                end
                
                if plugin.rootFilter4QTarget ~= plugin.midRegionQFactor
                    plugin.rootFilter4QTarget = plugin.midRegionQFactor;
                    qDiff = plugin.midRegionQFactor - plugin.rootQFactor4;
                    plugin.rootFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.rootFilter4QStep = 0;
                    plugin.rootFilter4QSmooth = true;
                end
                
            end
            setUpdateRootFilter4(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootFilter6Params(plugin)
            % Case: root filter 6 is in mid control region
            if plugin.rootFrequency6 < plugin.midHighCrossoverFreq
                if plugin.rootFilter6GainTarget ~= plugin.midRegionGain
                    plugin.rootFilter6GainTarget = plugin.midRegionGain;
                    gainDiff = plugin.midRegionGain - plugin.rootGain6; % set differential for gain
                    plugin.rootFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.rootFilter6GainStep = 0;
                    plugin.rootFilter6GainSmooth = true;
                end
                
                if plugin.rootFilter6QTarget ~= plugin.midRegionQFactor
                    plugin.rootFilter6QTarget = plugin.midRegionQFactor;
                    qDiff = plugin.midRegionQFactor - plugin.rootQFactor6;
                    plugin.rootFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.rootFilter6QStep = 0;
                    plugin.rootFilter6QSmooth = true;
                end
                
            else % Case: root filter 6 is in high-mid control region
                if plugin.rootFilter6GainTarget ~= plugin.highMidRegionGain
                    plugin.rootFilter6GainTarget = plugin.highMidRegionGain;
                    gainDiff = plugin.highMidRegionGain - plugin.rootGain6; % set differential for gain
                    plugin.rootFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.rootFilter6GainStep = 0;
                    plugin.rootFilter6GainSmooth = true;
                end
                
                if plugin.rootFilter6QTarget ~= plugin.highMidRegionQFactor
                    plugin.rootFilter6QTarget = plugin.highMidRegionQFactor;
                    qDiff = plugin.highMidRegionQFactor - plugin.rootQFactor6;
                    plugin.rootFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.rootFilter6QStep = 0;
                    plugin.rootFilter6QSmooth = true;
                end
            end
            setUpdateRootFilter6(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateRootFilter8Params(plugin)
            % Case: root filter 8 is in high-mid control region
            if plugin.rootFrequency8 < plugin.highCrossoverFreq
                if plugin.rootFilter8GainTarget ~= plugin.highMidRegionGain
                    plugin.rootFilter8GainTarget = plugin.highMidRegionGain;
                    gainDiff = plugin.highMidRegionGain - plugin.rootGain8; % set differential for gain
                    plugin.rootFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.rootFilter8GainStep = 0;
                    plugin.rootFilter8GainSmooth = true;
                end
                
                if plugin.rootFilter8QTarget ~= plugin.highMidRegionQFactor
                    plugin.rootFilter8QTarget = plugin.highMidRegionQFactor;
                    qDiff = plugin.highMidRegionQFactor - plugin.rootQFactor8;
                    plugin.rootFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.rootFilter8QStep = 0;
                    plugin.rootFilter8QSmooth = true;
                end
                
            else % Case: root filter 8 is in high control region
                if plugin.rootFilter8GainTarget ~= plugin.highRegionGain
                    plugin.rootFilter8GainTarget = plugin.highRegionGain;
                    gainDiff = plugin.highRegionGain - plugin.rootGain8; % set differential for gain
                    plugin.rootFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.rootFilter8GainStep = 0;
                    plugin.rootFilter8GainSmooth = true;
                end
                
                if plugin.rootFilter8QTarget ~= plugin.highRegionQFactor
                    plugin.rootFilter8QTarget = plugin.highRegionQFactor;
                    qDiff = plugin.highRegionQFactor - plugin.rootQFactor8;
                    plugin.rootFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.rootFilter8QStep = 0;
                    plugin.rootFilter8QSmooth = true;
                end
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
            plugin.rootFiltersDeactivating = true;
            updateRootGain1(plugin, 0);
            updateRootGain2(plugin, 0);
            updateRootGain3(plugin, 0);
            updateRootGain4(plugin, 0);
            updateRootGain5(plugin, 0);
            updateRootGain6(plugin, 0);
            updateRootGain7(plugin, 0);
            updateRootGain8(plugin, 0);
            updateRootGain9(plugin, 0);
        end
        
        function activateRootFilters(plugin)
            if ~plugin.rootFiltersActive
                plugin.rootFiltersActive = true;
                updateRootFilterParams(plugin);
                plugin.rootFiltersDeactivating = false;
            end
        end
        
        function changeRootFilterNote(plugin)
            plugin.rootFiltersChangingNote = true;
            updateRootGain1(plugin, 0);
            updateRootGain2(plugin, 0);
            updateRootGain3(plugin, 0);
            updateRootGain4(plugin, 0);
            updateRootGain5(plugin, 0);
            updateRootGain6(plugin, 0);
            updateRootGain7(plugin, 0);
            updateRootGain8(plugin, 0);
            updateRootGain9(plugin, 0);
        end
        
        function updateRootFilterParams(plugin)
            updateRootGain1(plugin, plugin.lowRegionGain);
            updateRootQFactor1(plugin, plugin.lowRegionQFactor);
            updateRootFilter2Params(plugin);
            updateRootGain3(plugin, plugin.lowMidRegionGain);
            updateRootQFactor3(plugin, plugin.lowMidRegionQFactor);
            updateRootFilter4Params(plugin);
            updateRootGain5(plugin, plugin.midRegionGain);
            updateRootQFactor5(plugin, plugin.midRegionQFactor);
            updateRootFilter6Params(plugin);
            updateRootGain7(plugin, plugin.highMidRegionGain);
            updateRootQFactor7(plugin, plugin.highMidRegionQFactor);
            updateRootFilter8Params(plugin);
            updateRootGain9(plugin, plugin.highRegionGain);
            updateRootQFactor9(plugin, plugin.highRegionQFactor);
        end
        
        
        %-----------------------Third filter updaters----------------------
        function updateThirdFrequencies(plugin)
            thirdFreq = plugin.thirdFrequency1;
            thirdNoteNumber = mod(plugin.rootNoteValue + plugin.thirdIntervalDistance, 12);
            
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
            % Case: third filter 2 is in low control region
            if plugin.thirdFrequency2 < plugin.lowCrossoverFreq
                if plugin.thirdFilter2GainTarget ~= plugin.lowRegionGain
                    plugin.thirdFilter2GainTarget = plugin.lowRegionGain;
                    gainDiff = plugin.lowRegionGain - plugin.thirdGain2; % set differential for gain
                    plugin.thirdFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter2GainStep = 0;
                    plugin.thirdFilter2GainSmooth = true;
                end
                
                if plugin.thirdFilter2QTarget ~= plugin.lowRegionQFactor
                    plugin.thirdFilter2QTarget = plugin.lowRegionQFactor;
                    qDiff = plugin.lowRegionQFactor - plugin.thirdQFactor2;
                    plugin.thirdFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter2QStep = 0;
                    plugin.thirdFilter2QSmooth = true;
                end
                
            else % Case: third filter 2 is in mid-low control region
                if plugin.thirdFilter2GainTarget ~= plugin.lowMidRegionGain
                    plugin.thirdFilter2GainTarget = plugin.lowMidRegionGain;
                    gainDiff = plugin.lowMidRegionGain - plugin.thirdGain2; % set differential for gain
                    plugin.thirdFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter2GainStep = 0;
                    plugin.thirdFilter2GainSmooth = true;
                end
                
                if plugin.thirdFilter2QTarget ~= plugin.lowMidRegionQFactor
                    plugin.thirdFilter2QTarget = plugin.lowMidRegionQFactor;
                    qDiff = plugin.lowMidRegionQFactor - plugin.thirdQFactor2;
                    plugin.thirdFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter2QStep = 0;
                    plugin.thirdFilter2QSmooth = true;
                end
            end
            setUpdateThirdFilter2(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdFilter4Params(plugin)
            % Case: third filter 4 is in low-mid control region
            if plugin.thirdFrequency4 < plugin.lowMidCrossoverFreq
                if plugin.thirdFilter4GainTarget ~= plugin.lowMidRegionGain
                    plugin.thirdFilter4GainTarget = plugin.lowMidRegionGain;
                    gainDiff = plugin.lowMidRegionGain - plugin.thirdGain4; % set differential for gain
                    plugin.thirdFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter4GainStep = 0;
                    plugin.thirdFilter4GainSmooth = true;
                end
                
                if plugin.thirdFilter4QTarget ~= plugin.lowMidRegionQFactor
                    plugin.thirdFilter4QTarget = plugin.lowMidRegionQFactor;
                    qDiff = plugin.lowMidRegionQFactor - plugin.thirdQFactor4;
                    plugin.thirdFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter4QStep = 0;
                    plugin.thirdFilter4QSmooth = true;
                end
                
            else % Case: third filter 4 is in mid control region
                if plugin.thirdFilter4GainTarget ~= plugin.midRegionGain
                    plugin.thirdFilter4GainTarget = plugin.midRegionGain;
                    gainDiff = plugin.midRegionGain - plugin.thirdGain4; % set differential for gain
                    plugin.thirdFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter4GainStep = 0;
                    plugin.thirdFilter4GainSmooth = true;
                end
                
                if plugin.thirdFilter4QTarget ~= plugin.midRegionQFactor
                    plugin.thirdFilter4QTarget = plugin.midRegionQFactor;
                    qDiff = plugin.midRegionQFactor - plugin.thirdQFactor4;
                    plugin.thirdFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter4QStep = 0;
                    plugin.thirdFilter4QSmooth = true;
                end
            end
            setUpdateThirdFilter4(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdFilter6Params(plugin)
            % Case: third filter 6 is in mid control region
            if plugin.thirdFrequency6 < plugin.midHighCrossoverFreq
                if plugin.thirdFilter6GainTarget ~= plugin.midRegionGain
                    plugin.thirdFilter6GainTarget = plugin.midRegionGain;
                    gainDiff = plugin.midRegionGain - plugin.thirdGain6; % set differential for gain
                    plugin.thirdFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter6GainStep = 0;
                    plugin.thirdFilter6GainSmooth = true;
                end
                
                if plugin.thirdFilter6QTarget ~= plugin.midRegionQFactor
                    plugin.thirdFilter6QTarget = plugin.midRegionQFactor;
                    qDiff = plugin.midRegionQFactor - plugin.thirdQFactor6;
                    plugin.thirdFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter6QStep = 0;
                    plugin.thirdFilter6QSmooth = true;
                end
                
            else % Case: third filter 6 is in high-mid control region
                if plugin.thirdFilter6GainTarget ~= plugin.highMidRegionGain
                    plugin.thirdFilter6GainTarget = plugin.highMidRegionGain;
                    gainDiff = plugin.highMidRegionGain - plugin.thirdGain6; % set differential for gain
                    plugin.thirdFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter6GainStep = 0;
                    plugin.thirdFilter6GainSmooth = true;
                end
                
                if plugin.thirdFilter6QTarget ~= plugin.highMidRegionQFactor
                    plugin.thirdFilter6QTarget = plugin.highMidRegionQFactor;
                    qDiff = plugin.highMidRegionQFactor - plugin.thirdQFactor6;
                    plugin.thirdFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter6QStep = 0;
                    plugin.thirdFilter6QSmooth = true;
                end
            end
            setUpdateThirdFilter6(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdFilter8Params(plugin)
            % Case: third filter 8 is in high-mid control region
            if plugin.thirdFrequency8 < plugin.highCrossoverFreq
                if plugin.thirdFilter8GainTarget ~= plugin.highMidRegionGain
                    plugin.thirdFilter8GainTarget = plugin.highMidRegionGain;
                    gainDiff = plugin.highMidRegionGain - plugin.thirdGain8; % set differential for gain
                    plugin.thirdFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter8GainStep = 0;
                    plugin.thirdFilter8GainSmooth = true;
                end
                
                if plugin.thirdFilter8QTarget ~= plugin.highMidRegionQFactor
                    plugin.thirdFilter8QTarget = plugin.highMidRegionQFactor;
                    qDiff = plugin.highMidRegionQFactor - plugin.thirdQFactor8;
                    plugin.thirdFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter8QStep = 0;
                    plugin.thirdFilter8QSmooth = true;
                end
                
            else % Case: third filter 8 is in high control region
                if plugin.thirdFilter8GainTarget ~= plugin.highRegionGain
                    plugin.thirdFilter8GainTarget = plugin.highRegionGain;
                    gainDiff = plugin.highRegionGain - plugin.thirdGain8; % set differential for gain
                    plugin.thirdFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter8GainStep = 0;
                    plugin.thirdFilter8GainSmooth = true;
                end
                
                if plugin.thirdFilter8QTarget ~= plugin.highRegionQFactor
                    plugin.thirdFilter8QTarget = plugin.highRegionQFactor;
                    qDiff = plugin.highRegionQFactor - plugin.thirdQFactor8;
                    plugin.thirdFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.thirdFilter8QStep = 0;
                    plugin.thirdFilter8QSmooth = true;
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
            plugin.thirdFilter7GainTarget = val;
            gainDiff = val - plugin.thirdGain7; % set differential for gain
            plugin.thirdFilter7GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter7GainStep = 0;
            plugin.thirdFilter7GainSmooth = true;
            
            setUpdateThirdFilter7(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdGain8(plugin,val)
            plugin.thirdFilter8GainTarget = val;
            gainDiff = val - plugin.thirdGain8; % set differential for gain
            plugin.thirdFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter8GainStep = 0;
            plugin.thirdFilter8GainSmooth = true;
            
            setUpdateThirdFilter8(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdGain9(plugin,val)
            plugin.thirdFilter9GainTarget = val;
            gainDiff = val - plugin.thirdGain9; % set differential for gain
            plugin.thirdFilter9GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter9GainStep = 0;
            plugin.thirdFilter9GainSmooth = true;
            
            setUpdateThirdFilter9(plugin);
            updateStateChangeStatus(plugin, true);
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
        
        function updateThirdQFactor7(plugin,val)
            plugin.thirdFilter7QTarget = val;
            qDiff = val - plugin.thirdQFactor7; % set differential for q
            plugin.thirdFilter7QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter7QStep = 0;
            plugin.thirdFilter7QSmooth = true;
            
            setUpdateThirdFilter7(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdQFactor8(plugin,val)
            plugin.thirdFilter8QTarget = val;
            qDiff = val - plugin.thirdQFactor8; % set differential for q
            plugin.thirdFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter8QStep = 0;
            plugin.thirdFilter8QSmooth = true;
            
            setUpdateThirdFilter8(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateThirdQFactor9(plugin,val)
            plugin.thirdFilter9QTarget = val;
            qDiff = val - plugin.thirdQFactor9; % set differential for q
            plugin.thirdFilter9QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.thirdFilter9QStep = 0;
            plugin.thirdFilter9QSmooth = true;
            
            setUpdateThirdFilter9(plugin);
            updateStateChangeStatus(plugin, true);
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
            % set gain to 0
            plugin.thirdFiltersDeactivating = true;
            updateThirdGain1(plugin, 0);
            updateThirdGain2(plugin, 0);
            updateThirdGain3(plugin, 0);
            updateThirdGain4(plugin, 0);
            updateThirdGain5(plugin, 0);
            updateThirdGain6(plugin, 0);
            updateThirdGain7(plugin, 0);
            updateThirdGain8(plugin, 0);
            updateThirdGain9(plugin, 0);
            
        end
        
        function activateThirdFilters(plugin)
            if ~plugin.thirdFiltersActive
                plugin.thirdFiltersActive = true;
                updateThirdFilterParams(plugin);
                plugin.thirdFiltersDeactivating = false;
            end
        end
        
        function changeThirdFilterNote(plugin)
            plugin.thirdFiltersChangingNote = true;
            updateThirdGain1(plugin, 0);
            updateThirdGain2(plugin, 0);
            updateThirdGain3(plugin, 0);
            updateThirdGain4(plugin, 0);
            updateThirdGain5(plugin, 0);
            updateThirdGain6(plugin, 0);
            updateThirdGain7(plugin, 0);
            updateThirdGain8(plugin, 0);
            updateThirdGain9(plugin, 0);
        end
        
        function updateThirdFilterParams(plugin)
            updateThirdGain1(plugin, plugin.lowRegionGain);
            updateThirdQFactor1(plugin, plugin.lowRegionQFactor);
            updateThirdFilter2Params(plugin);
            updateThirdGain3(plugin, plugin.lowMidRegionGain);
            updateThirdQFactor3(plugin, plugin.lowMidRegionQFactor);
            updateThirdFilter4Params(plugin);
            updateThirdGain5(plugin, plugin.midRegionGain);
            updateThirdQFactor5(plugin, plugin.midRegionQFactor);
            updateThirdFilter6Params(plugin);
            updateThirdGain7(plugin, plugin.highMidRegionGain);
            updateThirdQFactor7(plugin, plugin.highMidRegionQFactor);
            updateThirdFilter8Params(plugin);
            updateThirdGain9(plugin, plugin.highRegionGain);
            updateThirdQFactor9(plugin, plugin.highRegionQFactor);
        end
        
        
        %-----------------------Fifth filter updaters----------------------
        function updateFifthFrequencies(plugin)
            fifthFreq = plugin.fifthFrequency1;
            fifthNoteNumber = mod(plugin.rootNoteValue + plugin.fifthIntervalDistance, 12);
            
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
            % Case: fifth filter 2 is in low control region
            if plugin.fifthFrequency2 < plugin.lowCrossoverFreq
                if plugin.fifthFilter2GainTarget ~= plugin.lowRegionGain
                    plugin.fifthFilter2GainTarget = plugin.lowRegionGain;
                    gainDiff = plugin.lowRegionGain - plugin.fifthGain2; % set differential for gain
                    plugin.fifthFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter2GainStep = 0;
                    plugin.fifthFilter2GainSmooth = true;
                end
                
                if plugin.fifthFilter2QTarget ~= plugin.lowRegionQFactor
                    plugin.fifthFilter2QTarget = plugin.lowRegionQFactor;
                    qDiff = plugin.lowRegionQFactor - plugin.fifthQFactor2;
                    plugin.fifthFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter2QStep = 0;
                    plugin.fifthFilter2QSmooth = true;
                end
                
            else % Case: fifth filter 2 is in mid-low control region
                if plugin.fifthFilter2GainTarget ~= plugin.lowMidRegionGain
                    plugin.fifthFilter2GainTarget = plugin.lowMidRegionGain;
                    gainDiff = plugin.lowMidRegionGain - plugin.fifthGain2; % set differential for gain
                    plugin.fifthFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter2GainStep = 0;
                    plugin.fifthFilter2GainSmooth = true;
                end
                
                if plugin.fifthFilter2QTarget ~= plugin.lowMidRegionQFactor
                    plugin.fifthFilter2QTarget = plugin.lowMidRegionQFactor;
                    qDiff = plugin.lowMidRegionQFactor - plugin.fifthQFactor2;
                    plugin.fifthFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter2QStep = 0;
                    plugin.fifthFilter2QSmooth = true;
                end
            end
            setUpdateFifthFilter2(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthFilter4Params(plugin)
            % Case: fifth filter 4 is in low-mid control region
            if plugin.fifthFrequency4 < plugin.lowMidCrossoverFreq
                if plugin.fifthFilter4GainTarget ~= plugin.lowMidRegionGain
                    plugin.fifthFilter4GainTarget = plugin.lowMidRegionGain;
                    gainDiff = plugin.lowMidRegionGain - plugin.fifthGain4; % set differential for gain
                    plugin.fifthFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter4GainStep = 0;
                    plugin.fifthFilter4GainSmooth = true;
                end
                
                if plugin.fifthFilter4QTarget ~= plugin.lowMidRegionQFactor
                    plugin.fifthFilter4QTarget = plugin.lowMidRegionQFactor;
                    qDiff = plugin.lowMidRegionQFactor - plugin.fifthQFactor4;
                    plugin.fifthFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter4QStep = 0;
                    plugin.fifthFilter4QSmooth = true;
                end
                
            else % Case: fifth filter 4 is in mid control region
                if plugin.fifthFilter4GainTarget ~= plugin.midRegionGain
                    plugin.fifthFilter4GainTarget = plugin.midRegionGain;
                    gainDiff = plugin.midRegionGain - plugin.fifthGain4; % set differential for gain
                    plugin.fifthFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter4GainStep = 0;
                    plugin.fifthFilter4GainSmooth = true;
                end
                
                if plugin.fifthFilter4QTarget ~= plugin.midRegionQFactor
                    plugin.fifthFilter4QTarget = plugin.midRegionQFactor;
                    qDiff = plugin.midRegionQFactor - plugin.fifthQFactor4;
                    plugin.fifthFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter4QStep = 0;
                    plugin.fifthFilter4QSmooth = true;
                end
            end
            setUpdateFifthFilter4(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthFilter6Params(plugin)
            % Case: fifth filter 6 is in mid control region
            if plugin.fifthFrequency6 < plugin.midHighCrossoverFreq
                if plugin.fifthFilter6GainTarget ~= plugin.midRegionGain
                    plugin.fifthFilter6GainTarget = plugin.midRegionGain;
                    gainDiff = plugin.midRegionGain - plugin.fifthGain6; % set differential for gain
                    plugin.fifthFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter6GainStep = 0;
                    plugin.fifthFilter6GainSmooth = true;
                end
                
                if plugin.fifthFilter6QTarget ~= plugin.midRegionQFactor
                    plugin.fifthFilter6QTarget = plugin.midRegionQFactor;
                    qDiff = plugin.midRegionQFactor - plugin.fifthQFactor6;
                    plugin.fifthFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter6QStep = 0;
                    plugin.fifthFilter6QSmooth = true;
                end
                
            else % Case: fifth filter 6 is in high-mid control region
                if plugin.fifthFilter6GainTarget ~= plugin.highMidRegionGain
                    plugin.fifthFilter6GainTarget = plugin.highMidRegionGain;
                    gainDiff = plugin.highMidRegionGain - plugin.fifthGain6; % set differential for gain
                    plugin.fifthFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter6GainStep = 0;
                    plugin.fifthFilter6GainSmooth = true;
                end
                
                if plugin.fifthFilter6QTarget ~= plugin.highMidRegionQFactor
                    plugin.fifthFilter6QTarget = plugin.highMidRegionQFactor;
                    qDiff = plugin.highMidRegionQFactor - plugin.fifthQFactor6;
                    plugin.fifthFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter6QStep = 0;
                    plugin.fifthFilter6QSmooth = true;
                end
            end
            setUpdateFifthFilter6(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthFilter8Params(plugin)
            % Case: fifth filter 8 is in high-mid control region
            if plugin.fifthFrequency8 < plugin.highCrossoverFreq
                if plugin.fifthFilter8GainTarget ~= plugin.highMidRegionGain
                    plugin.fifthFilter8GainTarget = plugin.highMidRegionGain;
                    gainDiff = plugin.highMidRegionGain - plugin.fifthGain8; % set differential for gain
                    plugin.fifthFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter8GainStep = 0;
                    plugin.fifthFilter8GainSmooth = true;
                end
                
                if plugin.fifthFilter8QTarget ~= plugin.highMidRegionQFactor
                    plugin.fifthFilter8QTarget = plugin.highMidRegionQFactor;
                    qDiff = plugin.highMidRegionQFactor - plugin.fifthQFactor8;
                    plugin.fifthFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter8QStep = 0;
                    plugin.fifthFilter8QSmooth = true;
                end
                
            else % Case: fifth filter 8 is in high control region
                if plugin.fifthFilter8GainTarget ~= plugin.highRegionGain
                    plugin.fifthFilter8GainTarget = plugin.highRegionGain;
                    gainDiff = plugin.highRegionGain - plugin.fifthGain8; % set differential for gain
                    plugin.fifthFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter8GainStep = 0;
                    plugin.fifthFilter8GainSmooth = true;
                end
                
                if plugin.fifthFilter8QTarget ~= plugin.highRegionQFactor
                    plugin.fifthFilter8QTarget = plugin.highRegionQFactor;
                    qDiff = plugin.highRegionQFactor - plugin.fifthQFactor8;
                    plugin.fifthFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.fifthFilter8QStep = 0;
                    plugin.fifthFilter8QSmooth = true;
                end
            end
            setUpdateFifthFilter8(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthGain1(plugin,val)
            plugin.fifthFilter1GainTarget = val;
            gainDiff = val - plugin.fifthGain1; % set differential for gain
            plugin.fifthFilter1GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter1GainStep = 0;
            plugin.fifthFilter1GainSmooth = true;
            
            setUpdateFifthFilter1(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthGain2(plugin,val)
            plugin.fifthFilter2GainTarget = val;
            gainDiff = val - plugin.fifthGain2; % set differential for gain
            plugin.fifthFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter2GainStep = 0;
            plugin.fifthFilter2GainSmooth = true;
            
            setUpdateFifthFilter2(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthGain3(plugin,val)
            plugin.fifthFilter3GainTarget = val;
            gainDiff = val - plugin.fifthGain3; % set differential for gain
            plugin.fifthFilter3GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter3GainStep = 0;
            plugin.fifthFilter3GainSmooth = true;
            
            setUpdateFifthFilter3(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthGain4(plugin,val)
            plugin.fifthFilter4GainTarget = val;
            gainDiff = val - plugin.fifthGain4; % set differential for gain
            plugin.fifthFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter4GainStep = 0;
            plugin.fifthFilter4GainSmooth = true;
            
            setUpdateFifthFilter4(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthGain5(plugin,val)
            plugin.fifthFilter5GainTarget = val;
            gainDiff = val - plugin.fifthGain5; % set differential for gain
            plugin.fifthFilter5GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter5GainStep = 0;
            plugin.fifthFilter5GainSmooth = true;
            
            setUpdateFifthFilter5(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthGain6(plugin,val)
            plugin.fifthFilter6GainTarget = val;
            gainDiff = val - plugin.fifthGain6; % set differential for gain
            plugin.fifthFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter6GainStep = 0;
            plugin.fifthFilter6GainSmooth = true;
            
            setUpdateFifthFilter6(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthGain7(plugin,val)
            plugin.fifthFilter7GainTarget = val;
            gainDiff = val - plugin.fifthGain7; % set differential for gain
            plugin.fifthFilter7GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter7GainStep = 0;
            plugin.fifthFilter7GainSmooth = true;
            
            setUpdateFifthFilter7(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthGain8(plugin,val)
            plugin.fifthFilter8GainTarget = val;
            gainDiff = val - plugin.fifthGain8; % set differential for gain
            plugin.fifthFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter8GainStep = 0;
            plugin.fifthFilter8GainSmooth = true;
            
            setUpdateFifthFilter8(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthGain9(plugin,val)
            plugin.fifthFilter9GainTarget = val;
            gainDiff = val - plugin.fifthGain9; % set differential for gain
            plugin.fifthFilter9GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter9GainStep = 0;
            plugin.fifthFilter9GainSmooth = true;
            
            setUpdateFifthFilter9(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthQFactor1(plugin,val)
            plugin.fifthFilter1QTarget = val;
            qDiff = val - plugin.fifthQFactor1; % set differential for q
            plugin.fifthFilter1QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter1QStep = 0;
            plugin.fifthFilter1QSmooth = true;
            
            setUpdateFifthFilter1(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthQFactor2(plugin,val)
            plugin.fifthFilter2QTarget = val;
            qDiff = val - plugin.fifthQFactor2; % set differential for q
            plugin.fifthFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter2QStep = 0;
            plugin.fifthFilter2QSmooth = true;
            
            setUpdateFifthFilter2(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthQFactor3(plugin,val)
            plugin.fifthFilter3QTarget = val;
            qDiff = val - plugin.fifthQFactor3; % set differential for q
            plugin.fifthFilter3QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter3QStep = 0;
            plugin.fifthFilter3QSmooth = true;
            
            setUpdateFifthFilter3(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthQFactor4(plugin,val)
            plugin.fifthFilter4QTarget = val;
            qDiff = val - plugin.fifthQFactor4; % set differential for q
            plugin.fifthFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter4QStep = 0;
            plugin.fifthFilter4QSmooth = true;
            
            setUpdateFifthFilter4(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthQFactor5(plugin,val)
            plugin.fifthFilter5QTarget = val;
            qDiff = val - plugin.fifthQFactor5; % set differential for q
            plugin.fifthFilter5QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter5QStep = 0;
            plugin.fifthFilter5QSmooth = true;
            
            setUpdateFifthFilter5(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthQFactor6(plugin,val)
            plugin.fifthFilter6QTarget = val;
            qDiff = val - plugin.fifthQFactor6; % set differential for q
            plugin.fifthFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter6QStep = 0;
            plugin.fifthFilter6QSmooth = true;
            
            setUpdateFifthFilter6(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthQFactor7(plugin,val)
            plugin.fifthFilter7QTarget = val;
            qDiff = val - plugin.fifthQFactor7; % set differential for q
            plugin.fifthFilter7QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter7QStep = 0;
            plugin.fifthFilter7QSmooth = true;
            
            setUpdateFifthFilter7(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthQFactor8(plugin,val)
            plugin.fifthFilter8QTarget = val;
            qDiff = val - plugin.fifthQFactor8; % set differential for q
            plugin.fifthFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter8QStep = 0;
            plugin.fifthFilter8QSmooth = true;
            
            setUpdateFifthFilter8(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateFifthQFactor9(plugin,val)
            plugin.fifthFilter9QTarget = val;
            qDiff = val - plugin.fifthQFactor9; % set differential for q
            plugin.fifthFilter9QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.fifthFilter9QStep = 0;
            plugin.fifthFilter9QSmooth = true;
            
            setUpdateFifthFilter9(plugin);
            updateStateChangeStatus(plugin, true);
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
            % set gain to 0, then deactivate
            plugin.fifthFiltersDeactivating = true;
            updateFifthGain1(plugin, 0);
            updateFifthGain2(plugin, 0);
            updateFifthGain3(plugin, 0);
            updateFifthGain4(plugin, 0);
            updateFifthGain5(plugin, 0);
            updateFifthGain6(plugin, 0);
            updateFifthGain7(plugin, 0);
            updateFifthGain8(plugin, 0);
            updateFifthGain9(plugin, 0);
        end
        
        function activateFifthFilters(plugin)
            if ~plugin.fifthFiltersActive
                plugin.fifthFiltersActive = true;
                updateFifthFilterParams(plugin);
                plugin.fifthFiltersDeactivating = false;
            end
        end
        
        function changeFifthFilterNote(plugin)
            plugin.fifthFiltersChangingNote = true;
            updateFifthGain1(plugin, 0);
            updateFifthGain2(plugin, 0);
            updateFifthGain3(plugin, 0);
            updateFifthGain4(plugin, 0);
            updateFifthGain5(plugin, 0);
            updateFifthGain6(plugin, 0);
            updateFifthGain7(plugin, 0);
            updateFifthGain8(plugin, 0);
            updateFifthGain9(plugin, 0);
        end
        
        function updateFifthFilterParams(plugin)
            updateFifthGain1(plugin, plugin.lowRegionGain);
            updateFifthQFactor1(plugin, plugin.lowRegionQFactor);
            updateFifthFilter2Params(plugin);
            updateFifthGain3(plugin, plugin.lowMidRegionGain);
            updateFifthQFactor3(plugin, plugin.lowMidRegionQFactor);
            updateFifthFilter4Params(plugin);
            updateFifthGain5(plugin, plugin.midRegionGain);
            updateFifthQFactor5(plugin, plugin.midRegionQFactor);
            updateFifthFilter6Params(plugin);
            updateFifthGain7(plugin, plugin.highMidRegionGain);
            updateFifthQFactor7(plugin, plugin.highMidRegionQFactor);
            updateFifthFilter8Params(plugin);
            updateFifthGain9(plugin, plugin.highRegionGain);
            updateFifthQFactor9(plugin, plugin.highRegionQFactor);
        end
        
        
        %----------------------Seventh filter updaters---------------------
        function updateSeventhFrequencies(plugin)
            seventhFreq = plugin.seventhFrequency1;
            seventhNoteNumber = mod(plugin.rootNoteValue + plugin.seventhIntervalDistance, 12);
            
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
            % Case: seventh filter 2 is in low control region
            if plugin.seventhFrequency2 < plugin.lowCrossoverFreq
                if plugin.seventhFilter2GainTarget ~= plugin.lowRegionGain
                    plugin.seventhFilter2GainTarget = plugin.lowRegionGain;
                    gainDiff = plugin.lowRegionGain - plugin.seventhGain2; % set differential for gain
                    plugin.seventhFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter2GainStep = 0;
                    plugin.seventhFilter2GainSmooth = true;
                end
                
                if plugin.seventhFilter2QTarget ~= plugin.lowRegionQFactor
                    plugin.seventhFilter2QTarget = plugin.lowRegionQFactor;
                    qDiff = plugin.lowRegionQFactor - plugin.seventhQFactor2;
                    plugin.seventhFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter2QStep = 0;
                    plugin.seventhFilter2QSmooth = true;
                end
                
            else % Case: seventh filter 2 is in mid-low control region
                if plugin.seventhFilter2GainTarget ~= plugin.lowMidRegionGain
                    plugin.seventhFilter2GainTarget = plugin.lowMidRegionGain;
                    gainDiff = plugin.lowMidRegionGain - plugin.seventhGain2; % set differential for gain
                    plugin.seventhFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter2GainStep = 0;
                    plugin.seventhFilter2GainSmooth = true;
                end
                
                if plugin.seventhFilter2QTarget ~= plugin.lowMidRegionQFactor
                    plugin.seventhFilter2QTarget = plugin.lowMidRegionQFactor;
                    qDiff = plugin.lowMidRegionQFactor - plugin.seventhQFactor2;
                    plugin.seventhFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter2QStep = 0;
                    plugin.seventhFilter2QSmooth = true;
                end
            end
            setUpdateSeventhFilter2(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhFilter4Params(plugin)
            % Case: seventh filter 4 is in low-mid control region
            if plugin.seventhFrequency4 < plugin.lowMidCrossoverFreq
                if plugin.seventhFilter4GainTarget ~= plugin.lowMidRegionGain
                    plugin.seventhFilter4GainTarget = plugin.lowMidRegionGain;
                    gainDiff = plugin.lowMidRegionGain - plugin.seventhGain4; % set differential for gain
                    plugin.seventhFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter4GainStep = 0;
                    plugin.seventhFilter4GainSmooth = true;
                end
                
                if plugin.seventhFilter4QTarget ~= plugin.lowMidRegionQFactor
                    plugin.seventhFilter4QTarget = plugin.lowMidRegionQFactor;
                    qDiff = plugin.lowMidRegionQFactor - plugin.seventhQFactor4;
                    plugin.seventhFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter4QStep = 0;
                    plugin.seventhFilter4QSmooth = true;
                end
                
            else % Case: seventh filter 4 is in mid control region
                if plugin.seventhFilter4GainTarget ~= plugin.midRegionGain
                    plugin.seventhFilter4GainTarget = plugin.midRegionGain;
                    gainDiff = plugin.midRegionGain - plugin.seventhGain4; % set differential for gain
                    plugin.seventhFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter4GainStep = 0;
                    plugin.seventhFilter4GainSmooth = true;
                end
                
                if plugin.seventhFilter4QTarget ~= plugin.midRegionQFactor
                    plugin.seventhFilter4QTarget = plugin.midRegionQFactor;
                    qDiff = plugin.midRegionQFactor - plugin.seventhQFactor4;
                    plugin.seventhFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter4QStep = 0;
                    plugin.seventhFilter4QSmooth = true;
                end
            end
            setUpdateSeventhFilter4(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhFilter6Params(plugin)
            % Case: seventh filter 6 is in mid control region
            if plugin.seventhFrequency6 < plugin.midHighCrossoverFreq
                if plugin.seventhFilter6GainTarget ~= plugin.midRegionGain
                    plugin.seventhFilter6GainTarget = plugin.midRegionGain;
                    gainDiff = plugin.midRegionGain - plugin.seventhGain6; % set differential for gain
                    plugin.seventhFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter6GainStep = 0;
                    plugin.seventhFilter6GainSmooth = true;
                end
                
                if plugin.seventhFilter6QTarget ~= plugin.midRegionQFactor
                    plugin.seventhFilter6QTarget = plugin.midRegionQFactor;
                    qDiff = plugin.midRegionQFactor - plugin.seventhQFactor6;
                    plugin.seventhFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter6QStep = 0;
                    plugin.seventhFilter6QSmooth = true;
                end
                
            else % Case: seventh filter 6 is in high-mid control region
                if plugin.seventhFilter6GainTarget ~= plugin.highMidRegionGain
                    plugin.seventhFilter6GainTarget = plugin.highMidRegionGain;
                    gainDiff = plugin.highMidRegionGain - plugin.seventhGain6; % set differential for gain
                    plugin.seventhFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter6GainStep = 0;
                    plugin.seventhFilter6GainSmooth = true;
                end
                
                if plugin.seventhFilter6QTarget ~= plugin.highMidRegionQFactor
                    plugin.seventhFilter6QTarget = plugin.highMidRegionQFactor;
                    qDiff = plugin.highMidRegionQFactor - plugin.seventhQFactor6;
                    plugin.seventhFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter6QStep = 0;
                    plugin.seventhFilter6QSmooth = true;
                end
            end
            setUpdateSeventhFilter6(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhFilter8Params(plugin)
            % Case: seventh filter 8 is in high-mid control region
            if plugin.seventhFrequency8 < plugin.highCrossoverFreq
                if plugin.seventhFilter8GainTarget ~= plugin.highMidRegionGain
                    plugin.seventhFilter8GainTarget = plugin.highMidRegionGain;
                    gainDiff = plugin.highMidRegionGain - plugin.seventhGain8; % set differential for gain
                    plugin.seventhFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter8GainStep = 0;
                    plugin.seventhFilter8GainSmooth = true;
                end
                
                if plugin.seventhFilter8QTarget ~= plugin.highMidRegionQFactor
                    plugin.seventhFilter8QTarget = plugin.highMidRegionQFactor;
                    qDiff = plugin.highMidRegionQFactor - plugin.seventhQFactor8;
                    plugin.seventhFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter8QStep = 0;
                    plugin.seventhFilter8QSmooth = true;
                end
                
            else % Case: seventh filter 8 is in high control region
                if plugin.seventhFilter8GainTarget ~= plugin.highRegionGain
                    plugin.seventhFilter8GainTarget = plugin.highRegionGain;
                    gainDiff = plugin.highRegionGain - plugin.seventhGain8; % set differential for gain
                    plugin.seventhFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter8GainStep = 0;
                    plugin.seventhFilter8GainSmooth = true;
                end
                
                if plugin.seventhFilter8QTarget ~= plugin.highRegionQFactor
                    plugin.seventhFilter8QTarget = plugin.highRegionQFactor;
                    qDiff = plugin.highRegionQFactor - plugin.seventhQFactor8;
                    plugin.seventhFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
                    
                    plugin.seventhFilter8QStep = 0;
                    plugin.seventhFilter8QSmooth = true;
                end
            end
            setUpdateSeventhFilter8(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhGain1(plugin,val)
            plugin.seventhFilter1GainTarget = val;
            gainDiff = val - plugin.seventhGain1; % set differential for gain
            plugin.seventhFilter1GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter1GainStep = 0;
            plugin.seventhFilter1GainSmooth = true;
            
            setUpdateSeventhFilter1(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhGain2(plugin,val)
            plugin.seventhFilter2GainTarget = val;
            gainDiff = val - plugin.seventhGain2; % set differential for gain
            plugin.seventhFilter2GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter2GainStep = 0;
            plugin.seventhFilter2GainSmooth = true;
            
            setUpdateSeventhFilter2(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhGain3(plugin,val)
            plugin.seventhFilter3GainTarget = val;
            gainDiff = val - plugin.seventhGain3; % set differential for gain
            plugin.seventhFilter3GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter3GainStep = 0;
            plugin.seventhFilter3GainSmooth = true;
            
            setUpdateSeventhFilter3(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhGain4(plugin,val)
            plugin.seventhFilter4GainTarget = val;
            gainDiff = val - plugin.seventhGain4; % set differential for gain
            plugin.seventhFilter4GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter4GainStep = 0;
            plugin.seventhFilter4GainSmooth = true;
            
            setUpdateSeventhFilter4(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhGain5(plugin,val)
            plugin.seventhFilter5GainTarget = val;
            gainDiff = val - plugin.seventhGain5; % set differential for gain
            plugin.seventhFilter5GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter5GainStep = 0;
            plugin.seventhFilter5GainSmooth = true;
            
            setUpdateSeventhFilter5(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhGain6(plugin,val)
            plugin.seventhFilter6GainTarget = val;
            gainDiff = val - plugin.seventhGain6; % set differential for gain
            plugin.seventhFilter6GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter6GainStep = 0;
            plugin.seventhFilter6GainSmooth = true;
            
            setUpdateSeventhFilter6(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhGain7(plugin,val)
            plugin.seventhFilter7GainTarget = val;
            gainDiff = val - plugin.seventhGain7; % set differential for gain
            plugin.seventhFilter7GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter7GainStep = 0;
            plugin.seventhFilter7GainSmooth = true;
            
            setUpdateSeventhFilter7(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhGain8(plugin,val)
            plugin.seventhFilter8GainTarget = val;
            gainDiff = val - plugin.seventhGain8; % set differential for gain
            plugin.seventhFilter8GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter8GainStep = 0;
            plugin.seventhFilter8GainSmooth = true;
            
            setUpdateSeventhFilter8(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhGain9(plugin,val)
            plugin.seventhFilter9GainTarget = val;
            gainDiff = val - plugin.seventhGain9; % set differential for gain
            plugin.seventhFilter9GainDiff = gainDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter9GainStep = 0;
            plugin.seventhFilter9GainSmooth = true;
            
            setUpdateSeventhFilter9(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhQFactor1(plugin,val)
            plugin.seventhFilter1QTarget = val;
            qDiff = val - plugin.seventhQFactor1; % set differential for q
            plugin.seventhFilter1QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter1QStep = 0;
            plugin.seventhFilter1QSmooth = true;
            
            setUpdateSeventhFilter1(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhQFactor2(plugin,val)
            plugin.seventhFilter2QTarget = val;
            qDiff = val - plugin.seventhQFactor2; % set differential for q
            plugin.seventhFilter2QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter2QStep = 0;
            plugin.seventhFilter2QSmooth = true;
            
            setUpdateSeventhFilter2(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhQFactor3(plugin,val)
            plugin.seventhFilter3QTarget = val;
            qDiff = val - plugin.seventhQFactor3; % set differential for q
            plugin.seventhFilter3QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter3QStep = 0;
            plugin.seventhFilter3QSmooth = true;
            
            setUpdateSeventhFilter3(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhQFactor4(plugin,val)
            plugin.seventhFilter4QTarget = val;
            qDiff = val - plugin.seventhQFactor4; % set differential for q
            plugin.seventhFilter4QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter4QStep = 0;
            plugin.seventhFilter4QSmooth = true;
            
            setUpdateSeventhFilter4(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhQFactor5(plugin,val)
            plugin.seventhFilter5QTarget = val;
            qDiff = val - plugin.seventhQFactor5; % set differential for q
            plugin.seventhFilter5QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter5QStep = 0;
            plugin.seventhFilter5QSmooth = true;
            
            setUpdateSeventhFilter5(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhQFactor6(plugin,val)
            plugin.seventhFilter6QTarget = val;
            qDiff = val - plugin.seventhQFactor6; % set differential for q
            plugin.seventhFilter6QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter6QStep = 0;
            plugin.seventhFilter6QSmooth = true;
            
            setUpdateSeventhFilter6(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhQFactor7(plugin,val)
            plugin.seventhFilter7QTarget = val;
            qDiff = val - plugin.seventhQFactor7; % set differential for q
            plugin.seventhFilter7QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter7QStep = 0;
            plugin.seventhFilter7QSmooth = true;
            
            setUpdateSeventhFilter7(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhQFactor8(plugin,val)
            plugin.seventhFilter8QTarget = val;
            qDiff = val - plugin.seventhQFactor8; % set differential for q
            plugin.seventhFilter8QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter8QStep = 0;
            plugin.seventhFilter8QSmooth = true;
            
            setUpdateSeventhFilter8(plugin);
            updateStateChangeStatus(plugin, true);
        end
        
        function updateSeventhQFactor9(plugin,val)
            plugin.seventhFilter9QTarget = val;
            qDiff = val - plugin.seventhQFactor9; % set differential for q
            plugin.seventhFilter9QDiff = qDiff / plugin.numberOfSmoothSteps;
            
            plugin.seventhFilter9QStep = 0;
            plugin.seventhFilter9QSmooth = true;
            
            setUpdateSeventhFilter9(plugin);
            updateStateChangeStatus(plugin, true);
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
            % set gain to 0, flag for deactivation
            plugin.seventhFiltersDeactivating = true;
            updateSeventhGain1(plugin, 0);
            updateSeventhGain2(plugin, 0);
            updateSeventhGain3(plugin, 0);
            updateSeventhGain4(plugin, 0);
            updateSeventhGain5(plugin, 0);
            updateSeventhGain6(plugin, 0);
            updateSeventhGain7(plugin, 0);
            updateSeventhGain8(plugin, 0);
            updateSeventhGain9(plugin, 0);
        end
        
        function activateSeventhFilters(plugin)
            if ~plugin.seventhFiltersActive
                plugin.seventhFiltersActive = true;
                updateSeventhFilterParams(plugin);
                plugin.seventhFiltersDeactivating = false;
            end
        end
        
        function changeSeventhFilterNote(plugin)
            plugin.seventhFiltersChangingNote = true;
            updateSeventhGain1(plugin, 0);
            updateSeventhGain2(plugin, 0);
            updateSeventhGain3(plugin, 0);
            updateSeventhGain4(plugin, 0);
            updateSeventhGain5(plugin, 0);
            updateSeventhGain6(plugin, 0);
            updateSeventhGain7(plugin, 0);
            updateSeventhGain8(plugin, 0);
            updateSeventhGain9(plugin, 0);
        end
        
        function updateSeventhFilterParams(plugin)
            updateSeventhGain1(plugin, plugin.lowRegionGain);
            updateSeventhQFactor1(plugin, plugin.lowRegionQFactor);
            updateSeventhFilter2Params(plugin);
            updateSeventhGain3(plugin, plugin.lowMidRegionGain);
            updateSeventhQFactor3(plugin, plugin.lowMidRegionQFactor);
            updateSeventhFilter4Params(plugin);
            updateSeventhGain5(plugin, plugin.midRegionGain);
            updateSeventhQFactor5(plugin, plugin.midRegionQFactor);
            updateSeventhFilter6Params(plugin);
            updateSeventhGain7(plugin, plugin.highMidRegionGain);
            updateSeventhQFactor7(plugin, plugin.highMidRegionQFactor);
            updateSeventhFilter8Params(plugin);
            updateSeventhGain9(plugin, plugin.highRegionGain);
            updateSeventhQFactor9(plugin, plugin.highRegionQFactor);
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
                % If not, set to an allpass filter (just for visual)
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
        
        %--------------------Audio Processing Helpers----------------------
        function updateRootFiltersForProcessing(plugin,fs)
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
        end
        
        function updateThirdFiltersForProcessing(plugin,fs)
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
        end
        
        function updateFifthFiltersForProcessing(plugin,fs)
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
        end
        
        function updateSeventhFiltersForProcessing(plugin,fs)
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
        end
        
        function out = processRootFilters(plugin,in)
            [out, plugin.rootPrevState1] = filter(plugin.rootCoeffb1,...
                plugin.rootCoeffa1, in, plugin.rootPrevState1);
            [out, plugin.rootPrevState2] = filter(plugin.rootCoeffb2,...
                plugin.rootCoeffa2, out, plugin.rootPrevState2);
            [out, plugin.rootPrevState3] = filter(plugin.rootCoeffb3,...
                plugin.rootCoeffa3, out, plugin.rootPrevState3);
            [out, plugin.rootPrevState4] = filter(plugin.rootCoeffb4,...
                plugin.rootCoeffa4, out, plugin.rootPrevState4);
            [out, plugin.rootPrevState5] = filter(plugin.rootCoeffb5,...
                plugin.rootCoeffa5, out, plugin.rootPrevState5);
            [out, plugin.rootPrevState6] = filter(plugin.rootCoeffb6,...
                plugin.rootCoeffa6, out, plugin.rootPrevState6);
            [out, plugin.rootPrevState7] = filter(plugin.rootCoeffb7,...
                plugin.rootCoeffa7, out, plugin.rootPrevState7);
            [out, plugin.rootPrevState8] = filter(plugin.rootCoeffb8,...
                plugin.rootCoeffa8, out, plugin.rootPrevState8);
            [out, plugin.rootPrevState9] = filter(plugin.rootCoeffb9,...
                plugin.rootCoeffa9, out, plugin.rootPrevState9);
        end
        
        function out = processThirdFilters(plugin,in)
            [out, plugin.thirdPrevState1] = filter(plugin.thirdCoeffb1,...
                plugin.thirdCoeffa1, in, plugin.thirdPrevState1);
            [out, plugin.thirdPrevState2] = filter(plugin.thirdCoeffb2,...
                plugin.thirdCoeffa2, out, plugin.thirdPrevState2);
            [out, plugin.thirdPrevState3] = filter(plugin.thirdCoeffb3,...
                plugin.thirdCoeffa3, out, plugin.thirdPrevState3);
            [out, plugin.thirdPrevState4] = filter(plugin.thirdCoeffb4,...
                plugin.thirdCoeffa4, out, plugin.thirdPrevState4);
            [out, plugin.thirdPrevState5] = filter(plugin.thirdCoeffb5,...
                plugin.thirdCoeffa5, out, plugin.thirdPrevState5);
            [out, plugin.thirdPrevState6] = filter(plugin.thirdCoeffb6,...
                plugin.thirdCoeffa6, out, plugin.thirdPrevState6);
            [out, plugin.thirdPrevState7] = filter(plugin.thirdCoeffb7,...
                plugin.thirdCoeffa7, out, plugin.thirdPrevState7);
            [out, plugin.thirdPrevState8] = filter(plugin.thirdCoeffb8,...
                plugin.thirdCoeffa8, out, plugin.thirdPrevState8);
            [out, plugin.thirdPrevState9] = filter(plugin.thirdCoeffb9,...
                plugin.thirdCoeffa9, out, plugin.thirdPrevState9);
        end
        
        function out = processFifthFilters(plugin,in)
            [out, plugin.fifthPrevState1] = filter(plugin.fifthCoeffb1,...
                plugin.fifthCoeffa1, in, plugin.fifthPrevState1);
            [out, plugin.fifthPrevState2] = filter(plugin.fifthCoeffb2,...
                plugin.fifthCoeffa2, out, plugin.fifthPrevState2);
            [out, plugin.fifthPrevState3] = filter(plugin.fifthCoeffb3,...
                plugin.fifthCoeffa3, out, plugin.fifthPrevState3);
            [out, plugin.fifthPrevState4] = filter(plugin.fifthCoeffb4,...
                plugin.fifthCoeffa4, out, plugin.fifthPrevState4);
            [out, plugin.fifthPrevState5] = filter(plugin.fifthCoeffb5,...
                plugin.fifthCoeffa5, out, plugin.fifthPrevState5);
            [out, plugin.fifthPrevState6] = filter(plugin.fifthCoeffb6,...
                plugin.fifthCoeffa6, out, plugin.fifthPrevState6);
            [out, plugin.fifthPrevState7] = filter(plugin.fifthCoeffb7,...
                plugin.fifthCoeffa7, out, plugin.fifthPrevState7);
            [out, plugin.fifthPrevState8] = filter(plugin.fifthCoeffb8,...
                plugin.fifthCoeffa8, out, plugin.fifthPrevState8);
            [out, plugin.fifthPrevState9] = filter(plugin.fifthCoeffb9,...
                plugin.fifthCoeffa9, out, plugin.fifthPrevState9);
        end
        
        function out = processSeventhFilters(plugin,in)
            [out, plugin.seventhPrevState1] = filter(plugin.seventhCoeffb1,...
                plugin.seventhCoeffa1, in, plugin.seventhPrevState1);
            [out, plugin.seventhPrevState2] = filter(plugin.seventhCoeffb2,...
                plugin.seventhCoeffa2, out, plugin.seventhPrevState2);
            [out, plugin.seventhPrevState3] = filter(plugin.seventhCoeffb3,...
                plugin.seventhCoeffa3, out, plugin.seventhPrevState3);
            [out, plugin.seventhPrevState4] = filter(plugin.seventhCoeffb4,...
                plugin.seventhCoeffa4, out, plugin.seventhPrevState4);
            [out, plugin.seventhPrevState5] = filter(plugin.seventhCoeffb5,...
                plugin.seventhCoeffa5, out, plugin.seventhPrevState5);
            [out, plugin.seventhPrevState6] = filter(plugin.seventhCoeffb6,...
                plugin.seventhCoeffa6, out, plugin.seventhPrevState6);
            [out, plugin.seventhPrevState7] = filter(plugin.seventhCoeffb7,...
                plugin.seventhCoeffa7, out, plugin.seventhPrevState7);
            [out, plugin.seventhPrevState8] = filter(plugin.seventhCoeffb8,...
                plugin.seventhCoeffa8, out, plugin.seventhPrevState8);
            [out, plugin.seventhPrevState9] = filter(plugin.seventhCoeffb9,...
                plugin.seventhCoeffa9, out, plugin.seventhPrevState9);
        end
        
        
        %--------------------Harmonic Analysis Helpers---------------------
        function setResetAnalysisBufferFlag(plugin)
            plugin.resetAnalysisBufferFlag = true;
        end
        
        function initializeTransformMatrix(plugin)
            fs = getSampleRate(plugin);

            % Set analysis FFT size based on samplerate
            if fs <= 48000
                numFFT = 2048;
                plugin.nFFT = 2048;
            elseif fs <= 96000
                numFFT = 4096;
                plugin.nFFT = 4096;
            else
                numFFT = 8192;
                plugin.nFFT = 8192;
            end
            
            % Build chroma transform matrix
            plugin.chromaTransformMatrix = buildChromaTransform(numFFT, fs);
        end
        
        function monoOut = sumToMono(~,in)
            [~,n] = size(in);
            
            if n == 2
                monoOut = sum(in, 2);
            end
        end
        
        function resetAnalysisBuffer(plugin)
            % Clear analysis buffer and forget the last chord estimate
            read(plugin.analysisBuffer);
            plugin.prevEstimateIndex = 0;
            plugin.resetAnalysisBufferFlag = false;
        end
        
        function out = getPowSpectrum(plugin, n_fft, n_fft2)
            % Reads from analysis buffer with n_fft/2 overlap, applies a
            % Hann window, performs FFT, and returns the power spectrum for
            % the first 1 + n_fft/2 points.
            analysisFrame = read(plugin.analysisBuffer, n_fft, n_fft2);
            analysisFrame = analysisFrame .* plugin.hannWindow;
            
            fftOut = fft(analysisFrame);
            mag = abs(fftOut(1:n_fft2+1));
            out = mag .^ 2;
        end
        
        function chromaVector = getNormChroma(plugin,powSpectrum)
            rawChroma = plugin.chromaTransformMatrix * powSpectrum;
            % Normalize chroma vector
            chromaVector = zeros(12,1);
            rawMax = max(rawChroma);
            for i = 1:12
                chromaVector(i) = rawChroma(i) / rawMax;
            end
        end
        
        function [bestSimIndex, bestSimilarity, simOfPrevEstimate] = ...
                getSimilarities(~,chromaVector, chordTemplates,...
                previousIndex)
            bestSimilarity = 0;
            bestSimIndex = 0;
            simOfPrevEstimate = 0;
            [m,~] = size(chordTemplates);
            
            for i = 1:m
                similarity = dot(chordTemplates(i,:), chromaVector) / ...
                    (norm(chordTemplates(i,:)) * norm(chromaVector));
                if i < 13
                    similarity = 0.9 * similarity; % De-emphasize 5 chords
                elseif i > 36
                    similarity = 0.75 * similarity; % De-emphasize non major/minor chords
                end
                if i == previousIndex
                    similarity = 1.035 * similarity; % Give weighting to previous estimate
                    simOfPrevEstimate = similarity;
                end
                if similarity > bestSimilarity
                    bestSimilarity = similarity;
                    bestSimIndex = i;
                end
            end
        end
        
        function mode = checkMode(plugin)
            mode = plugin.automaticMode;
        end
        
        function estimateOut = getChordEstimate(~,...
                bestSimilarityIndex, bestSimilarity,...
                prevIndex, prevIndexSimilarity)
            if bestSimilarityIndex == prevIndex
                % If current best similarity index matches the previous
                % index, then they're in agreement and use that
                estimateOut = bestSimilarityIndex;
            elseif 1 - prevIndexSimilarity/bestSimilarity < 0.05
                % If the similarity of the new estimate is not
                % significantly more than the similarity of the last,
                % don't update. Default to stability.
                estimateOut = prevIndex;
            elseif bestSimilarity > 0.6
                % If the current best similarity is significantly more
                % confident greater than 0.6, update to new one
                estimateOut = bestSimilarityIndex;
            else
                estimateOut = prevIndex;
            end
        end
        
        %test
        function updateRootNote(plugin, rootNote)
            % Update the root note if it does not match the newest
            % estimation.
            switch rootNote
                case 'A'
                    if plugin.privateRootNote ~= EQRootNote.A
                        plugin.privateRootNote = EQRootNote.A;
                    end
                case 'Bb'
                    if plugin.privateRootNote ~= EQRootNote.Bb
                        plugin.privateRootNote = EQRootNote.Bb;
                    end
                case 'B'
                    if plugin.privateRootNote ~= EQRootNote.B
                        plugin.privateRootNote = EQRootNote.B;
                    end
                case 'C'
                    if plugin.privateRootNote ~= EQRootNote.C
                        plugin.privateRootNote = EQRootNote.C;
                    end
                case 'Db'
                    if plugin.privateRootNote ~= EQRootNote.Db
                        plugin.privateRootNote = EQRootNote.Db;
                    end
                case 'D'
                    if plugin.privateRootNote ~= EQRootNote.D
                        plugin.privateRootNote = EQRootNote.D;
                    end
                case 'Eb'
                    if plugin.privateRootNote ~= EQRootNote.Eb
                        plugin.privateRootNote = EQRootNote.Eb;
                    end
                case 'E'
                    if plugin.privateRootNote ~= EQRootNote.E
                        plugin.privateRootNote = EQRootNote.E;
                    end
                case 'F'
                    if plugin.privateRootNote ~= EQRootNote.F
                        plugin.privateRootNote = EQRootNote.F;
                    end
                case 'Gb'
                    if plugin.privateRootNote ~= EQRootNote.Gb
                        plugin.privateRootNote = EQRootNote.Gb;
                    end
                case 'G'
                    if plugin.privateRootNote ~= EQRootNote.G
                        plugin.privateRootNote = EQRootNote.G;
                    end
                case 'Ab'
                    if plugin.privateRootNote ~= EQRootNote.Ab
                        plugin.privateRootNote = EQRootNote.Ab;
                    end
            end
            
            if ~plugin.rootFiltersActive
                activateRootFilters(plugin);
            end
            changeRootFilterNote(plugin);
            updateChord(plugin);
            
            setUpdateRootFilters(plugin);
            setUpdateThirdFilters(plugin);
            setUpdateFifthFilters(plugin);
            setUpdateSeventhFilters(plugin);
            
            % Update visualizer
            updateStateChangeStatus(plugin,true);
            
        end
        
        function updateChordType(plugin, chordType)
            % Update the chord type if it does not match the newest
            % estimation.
           switch chordType
               case 'five'
                   if plugin.privateChordType ~= EQChordType.five
                       plugin.privateChordType = EQChordType.five;
                   end
               case 'minor'
                   if plugin.privateChordType ~= EQChordType.minor
                       plugin.privateChordType = EQChordType.minor;
                   end
               case 'major'
                   if plugin.privateChordType ~= EQChordType.major
                       plugin.privateChordType = EQChordType.major;
                   end
               case 'diminished'
                   if plugin.privateChordType ~= EQChordType.diminished
                       plugin.privateChordType = EQChordType.diminished;
                   end
               case 'augmented'
                   if plugin.privateChordType ~= EQChordType.augmented
                       plugin.privateChordType = EQChordType.augmented;
                   end
               case 'minor7'
                   if plugin.privateChordType ~= EQChordType.minor7
                       plugin.privateChordType = EQChordType.minor7;
                   end
               case 'dominant7'
                   if plugin.privateChordType ~= EQChordType.dominant7
                       plugin.privateChordType = EQChordType.dominant7;
                   end
               case 'major7'
                   if plugin.privateChordType ~= EQChordType.major7
                       plugin.privateChordType = EQChordType.major7;
                   end
               case 'minor7b5'
                   if plugin.privateChordType ~= EQChordType.minor7b5
                       plugin.privateChordType = EQChordType.minor7b5;
                   end
               case 'diminished7'
                   if plugin.privateChordType ~= EQChordType.diminished7
                       plugin.privateChordType = EQChordType.diminished7;
                   end
           end
        end
        
        function out = peakLevelDetection(plugin, in, prevLevel, peakAlpha)
            % Input in signal level, output in dB
            inLevel = abs(in);
            out = inLevel;
            if inLevel > prevLevel
                out = (1 - peakAlpha) * prevLevel + ...
                peakAlpha * inLevel;
            end
            out = mag2db(out);
        end
        
        function out = outputGainSmoothing(plugin, outGain)
            out = plugin.gainOut - 0.6 * (plugin.gainOut - outGain);
        end
        
    end
    
    
end
















