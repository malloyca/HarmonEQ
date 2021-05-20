function [chordName, rootNote, chordType] = chordDetectionLookup(index)
% CHORDDETECTIONLOOKUP This is a lookup function for converting from a
% matrix index chord information
%
% Input:
% index - This is an integer value corresponding to the index of the chord
% template returned by the chord detection system.
%
% Output:
% chordName - This is a string containing the name of the chord.
% rootNote - This is a string corresponding to the root note of the
% chord for updating plugin.rootNote.
% chordType - This is a string corresponding to the chord type to use for
% updating plugin.chordType.

    if index < 13 % case: five chord
        switch index
            case 1
                chordName = 'A5';
                rootNote = 'A';
                chordType = 'five';
            case 2
                chordName = 'Bb5';
                rootNote = 'Bb';
                chordType = 'five';
            case 3
                chordName = 'Bfive';
                rootNote = 'B';
                chordType = 'five';
            case 4
                chordName = 'C5';
                rootNote = 'C';
                chordType = 'five';
            case 5
                chordName = 'Db5';
                rootNote = 'Db';
                chordType = 'five';
            case 6
                chordName = 'D5';
                rootNote = 'D';
                chordType = 'five';
            case 7
                chordName = 'Eb5';
                rootNote = 'Eb';
                chordType = 'five';
            case 8
                chordName = 'E5';
                rootNote = 'E';
                chordType = 'five';
            case 9
                chordName = 'F5';
                rootNote = 'F';
                chordType = 'five';
            case 10
                chordName = 'Gb5';
                rootNote = 'Gb';
                chordType = 'five';
            case 11
                chordName = 'G5';
                rootNote = 'G';
                chordType = 'five';
            case 12
                chordName = 'Ab5';
                rootNote = 'Ab';
                chordType = 'five';
        end
        
    elseif index < 25 % major chord
        switch index
            case 13
                chordName = 'A major';
                rootNote = 'A';
                chordType = 'major';
            case 14
                chordName = 'Bb major';
                rootNote = 'Bb';
                chordType = 'major';
            case 15
                chordName = 'B major';
                rootNote = 'B';
                chordType = 'major';
            case 16
                chordName = 'C major';
                rootNote = 'C';
                chordType = 'major';
            case 17
                chordName = 'Db major';
                rootNote = 'Db';
                chordType = 'major';
            case 18
                chordName = 'D major';
                rootNote = 'D';
                chordType = 'major';
            case 19
                chordName = 'Eb major';
                rootNote = 'Eb';
                chordType = 'major';
            case 20
                chordName = 'E major';
                rootNote = 'E';
                chordType = 'major';
            case 21
                chordName = 'F major';
                rootNote = 'F';
                chordType = 'major';
            case 22
                chordName = 'Gb major';
                rootNote = 'Gb';
                chordType = 'major';
            case 23
                chordName = 'G major';
                rootNote = 'G';
                chordType = 'major';
            case 24
                chordName = 'Ab major';
                rootNote = 'Ab';
                chordType = 'major';
        end
        
    elseif index < 37 % case: minor chord
        switch index
            case 25
                chordName = 'A minor';
                rootNote = 'A';
                chordType = 'minor';
            case 26
                chordName = 'Bb minor';
                rootNote = 'Bb';
                chordType = 'minor';
            case 27
                chordName = 'B minor';
                rootNote = 'B';
                chordType = 'minor';
            case 28
                chordName = 'C minor';
                rootNote = 'C';
                chordType = 'minor';
            case 29
                chordName = 'Db minor';
                rootNote = 'Db';
                chordType = 'minor';
            case 30
                chordName = 'D minor';
                rootNote = 'D';
                chordType = 'minor';
            case 31
                chordName = 'Eb minor';
                rootNote = 'Eb';
                chordType = 'minor';
            case 32
                chordName = 'E minor';
                rootNote = 'E';
                chordType = 'minor';
            case 33
                chordName = 'F minor';
                rootNote = 'F';
                chordType = 'minor';
            case 34
                chordName = 'Gb minor';
                rootNote = 'Gb';
                chordType = 'minor';
            case 35
                chordName = 'G minor';
                rootNote = 'G';
                chordType = 'minor';
            case 36
                chordName = 'Ab minor';
                rootNote = 'Ab';
                chordType = 'minor';
        end
        
    elseif index < 49 % case: diminished chord
        switch index
            case 37
                chordName = 'A diminished';
                rootNote = 'A';
                chordType = 'diminished';
            case 38
                chordName = 'Bb diminished';
                rootNote = 'Bb';
                chordType = 'diminished';
            case 39
                chordName = 'B diminished';
                rootNote = 'B';
                chordType = 'diminished';
            case 40
                chordName = 'C diminished';
                rootNote = 'C';
                chordType = 'diminished';
            case 41
                chordName = 'Db diminished';
                rootNote = 'Db';
                chordType = 'diminished';
            case 42
                chordName = 'D diminished';
                rootNote = 'D';
                chordType = 'diminished';
            case 43
                chordName = 'Eb diminished';
                rootNote = 'Eb';
                chordType = 'diminished';
            case 44
                chordName = 'E diminished';
                rootNote = 'E';
                chordType = 'diminished';
            case 45
                chordName = 'F diminished';
                rootNote = 'F';
                chordType = 'diminished';
            case 46
                chordName = 'Gb diminished';
                rootNote = 'Gb';
                chordType = 'diminished';
            case 47
                chordName = 'G diminished';
                rootNote = 'G';
                chordType = 'diminished';
            case 48
                chordName = 'Ab diminished';
                rootNote = 'Ab';
                chordType = 'diminished';
        end
        
    elseif index < 61 % case: augmented chord
        switch index
            case 49
                chordName = 'A augmented';
                rootNote = 'A';
                chordType = 'augmented';
            case 50
                chordName = 'Bb augmented';
                rootNote = 'Bb';
                chordType = 'augmented';
            case 51
                chordName = 'B augmented';
                rootNote = 'B';
                chordType = 'augmented';
            case 52
                chordName = 'C augmented';
                rootNote = 'C';
                chordType = 'augmented';
            case 53
                chordName = 'Db augmented';
                rootNote = 'Db';
                chordType = 'augmented';
            case 54
                chordName = 'D augmented';
                rootNote = 'D';
                chordType = 'augmented';
            case 55
                chordName = 'Eb augmented';
                rootNote = 'Eb';
                chordType = 'augmented';
            case 56
                chordName = 'E augmented';
                rootNote = 'E';
                chordType = 'augmented';
            case 57
                chordName = 'F augmented';
                rootNote = 'F';
                chordType = 'augmented';
            case 58
                chordName = 'Gb augmented';
                rootNote = 'Gb';
                chordType = 'augmented';
            case 59
                chordName = 'G augmented';
                rootNote = 'G';
                chordType = 'augmented';
            case 60
                chordName = 'Ab augmented';
                rootNote = 'Ab';
                chordType = 'augmented';
        end
        
    elseif index < 73 % case: major 7 chord
        switch index
            case 61
                chordName = 'A major 7';
                rootNote = 'A';
                chordType = 'major7';
            case 62
                chordName = 'Bb major 7';
                rootNote = 'Bb';
                chordType = 'major7';
            case 63
                chordName = 'B major 7';
                rootNote = 'B';
                chordType = 'major7';
            case 64
                chordName = 'C major 7';
                rootNote = 'C';
                chordType = 'major7';
            case 65
                chordName = 'Db major 7';
                rootNote = 'Db';
                chordType = 'major7';
            case 66
                chordName = 'D major 7';
                rootNote = 'D';
                chordType = 'major7';
            case 67
                chordName = 'Eb major 7';
                rootNote = 'Eb';
                chordType = 'major7';
            case 68
                chordName = 'E major 7';
                rootNote = 'E';
                chordType = 'major7';
            case 69
                chordName = 'F major 7';
                rootNote = 'F';
                chordType = 'major7';
            case 70
                chordName = 'Gb major 7';
                rootNote = 'Gb';
                chordType = 'major7';
            case 71
                chordName = 'G major 7';
                rootNote = 'G';
                chordType = 'major7';
            case 72
                chordName = 'Ab major 7';
                rootNote = 'Ab';
                chordType = 'major7';
        end
        
    elseif index < 85 % case: dominant 7 chord
        switch index
            case 73
                chordName = 'A dominant 7';
                rootNote = 'A';
                chordType = 'dominant7';
            case 74
                chordName = 'Bb dominant 7';
                rootNote = 'Bb';
                chordType = 'dominant7';
            case 75
                chordName = 'B dominant 7';
                rootNote = 'B';
                chordType = 'dominant7';
            case 76
                chordName = 'C dominant 7';
                rootNote = 'C';
                chordType = 'dominant7';
            case 77
                chordName = 'Db dominant 7';
                rootNote = 'Db';
                chordType = 'dominant7';
            case 78
                chordName = 'D dominant 7';
                rootNote = 'D';
                chordType = 'dominant7';
            case 79
                chordName = 'Eb dominant 7';
                rootNote = 'Eb';
                chordType = 'dominant7';
            case 80
                chordName = 'E dominant 7';
                rootNote = 'E';
                chordType = 'dominant7';
            case 81
                chordName = 'F dominant 7';
                rootNote = 'F';
                chordType = 'dominant7';
            case 82
                chordName = 'Gb dominant 7';
                rootNote = 'Gb';
                chordType = 'dominant7';
            case 83
                chordName = 'G dominant 7';
                rootNote = 'G';
                chordType = 'dominant7';
            case 84
                chordName = 'Ab dominant 7';
                rootNote = 'Ab';
                chordType = 'dominant7';
        end
        
    elseif index < 97 % case: minor 7 chord
        switch index
            case 85
                chordName = 'A minor 7';
                rootNote = 'A';
                chordType = 'minor7';
            case 86
                chordName = 'Bb minor 7';
                rootNote = 'Bb';
                chordType = 'minor7';
            case 87
                chordName = 'B minor 7';
                rootNote = 'B';
                chordType = 'minor7';
            case 88
                chordName = 'C minor 7';
                rootNote = 'C';
                chordType = 'minor7';
            case 89
                chordName = 'Db minor 7';
                rootNote = 'Db';
                chordType = 'minor7';
            case 90
                chordName = 'D minor 7';
                rootNote = 'D';
                chordType = 'minor7';
            case 91
                chordName = 'Eb minor 7';
                rootNote = 'Eb';
                chordType = 'minor7';
            case 92
                chordName = 'E minor 7';
                rootNote = 'E';
                chordType = 'minor7';
            case 93
                chordName = 'F minor 7';
                rootNote = 'F';
                chordType = 'minor7';
            case 94
                chordName = 'Gb minor 7';
                rootNote = 'Gb';
                chordType = 'minor7';
            case 95
                chordName = 'G minor 7';
                rootNote = 'G';
                chordType = 'minor7';
            case 96
                chordName = 'Ab minor 7';
                rootNote = 'Ab';
                chordType = 'minor7';
        end
        
    elseif index < 109 % case: minor 7 flat 5 chord
        switch index
            case 97
                chordName = 'A minor 7 b5';
                rootNote = 'A';
                chordType = 'minor7b5';
            case 98
                chordName = 'Bb minor 7 b5';
                rootNote = 'Bb';
                chordType = 'minor7b5';
            case 99
                chordName = 'B minor 7 b5';
                rootNote = 'B';
                chordType = 'minor7b5';
            case 100
                chordName = 'C minor 7 b5';
                rootNote = 'C';
                chordType = 'minor7b5';
            case 101
                chordName = 'Db minor 7 b5';
                rootNote = 'Db';
                chordType = 'minor7b5';
            case 102
                chordName = 'D minor 7 b5';
                rootNote = 'D';
                chordType = 'minor7b5';
            case 103
                chordName = 'Eb minor 7 b5';
                rootNote = 'Eb';
                chordType = 'minor7b5';
            case 104
                chordName = 'E minor 7 b5';
                rootNote = 'E';
                chordType = 'minor7b5';
            case 105
                chordName = 'F minor 7 b5';
                rootNote = 'F';
                chordType = 'minor7b5';
            case 106
                chordName = 'Gb minor 7 b5';
                rootNote = 'Gb';
                chordType = 'minor7b5';
            case 107
                chordName = 'G minor 7 b5';
                rootNote = 'G';
                chordType = 'minor7b5';
            case 108
                chordName = 'Ab minor 7 b5';
                rootNote = 'Ab';
                chordType = 'minor7b5';
        end
        
    else
        switch index
            case 109
                chordName = 'A diminished 7';
                rootNote = 'A';
                chordType = 'diminished7';
            case 110
                chordName = 'Bb diminished 7';
                rootNote = 'Bb';
                chordType = 'diminished7';
            case 111
                chordName = 'B diminished 7';
                rootNote = 'B';
                chordType = 'diminished7';
            case 112
                chordName = 'C diminished 7';
                rootNote = 'C';
                chordType = 'diminished7';
            case 113
                chordName = 'Db diminished 7';
                rootNote = 'Db';
                chordType = 'diminished7';
            case 114
                chordName = 'D diminished 7';
                rootNote = 'D';
                chordType = 'diminished7';
            case 115
                chordName = 'Eb diminished 7';
                rootNote = 'Eb';
                chordType = 'diminished7';
            case 116
                chordName = 'E diminished 7';
                rootNote = 'E';
                chordType = 'diminished7';
            case 117
                chordName = 'F diminished 7';
                rootNote = 'F';
                chordType = 'diminished7';
            case 118
                chordName = 'Gb diminished 7';
                rootNote = 'Gb';
                chordType = 'diminished7';
            case 119
                chordName = 'G diminished 7';
                rootNote = 'G';
                chordType = 'diminished7';
            case 120
                chordName = 'Ab diminished 7';
                rootNote = 'Ab';
                chordType = 'diminished7';
        end
    end
end