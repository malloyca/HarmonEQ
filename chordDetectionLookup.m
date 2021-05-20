function chord = chordDetectionLookup(index)
% I will eventually want to change this to [root, chordType] =
% chordDetectionLookup(index)
    if index < 13 % case: five chord
        switch index
            case 1
                chord = 'A5';
            case 2
                chord = 'Bb5';
            case 3
                chord = 'B5';
            case 4
                chord = 'C5';
            case 5
                chord = 'Db5';
            case 6
                chord = 'D5';
            case 7
                chord = 'Eb5';
            case 8
                chord = 'E5';
            case 9
                chord = 'F5';
            case 10
                chord = 'Gb5';
            case 11
                chord = 'G5';
            case 12
                chord = 'Ab5';
        end
        
    elseif index < 25 % major chord
        switch index
            case 13
                chord = 'A major';
            case 14
                chord = 'bb major';
            case 15
                chord = 'B major';
            case 16
                chord = 'C major';
            case 17
                chord = 'Db major';
            case 18
                chord = 'D major';
            case 19
                chord = 'Eb major';
            case 20
                chord = 'E major';
            case 21
                chord = 'F major';
            case 22
                chord = 'Gb major';
            case 23
                chord = 'G major';
            case 24
                chord = 'Ab major';
        end
        
    elseif index < 37 % case: minor chord
        switch index
            case 25
                chord = 'A minor';
            case 26
                chord = 'Bb minor';
            case 27
                chord = 'B minor';
            case 28
                chord = 'C minor';
            case 29
                chord = 'Db minor';
            case 30
                chord = 'D minor';
            case 31
                chord = 'Eb minor';
            case 32
                chord = 'E minor';
            case 33
                chord = 'F minor';
            case 34
                chord = 'Gb minor';
            case 35
                chord = 'G minor';
            case 36
                chord = 'Ab minor';
        end
        
    elseif index < 49 % case: diminished chord
        switch index
            case 37
                chord = 'A diminished';
            case 38
                chord = 'Bb diminished';
            case 39
                chord = 'B diminished';
            case 40
                chord = 'C diminished';
            case 41
                chord = 'Db diminished';
            case 42
                chord = 'D diminished';
            case 43
                chord = 'Eb diminished';
            case 44
                chord = 'E diminished';
            case 45
                chord = 'F diminished';
            case 46
                chord = 'Gb diminished';
            case 47
                chord = 'G diminished';
            case 48
                chord = 'Ab diminished';
        end
        
    elseif index < 61 % case: augmented chord
        switch index
            case 49
                chord = 'A augmented';
            case 50
                chord = 'Bb augmented';
            case 51
                chord = 'B augmented';
            case 52
                chord = 'C augmented';
            case 53
                chord = 'Db augmented';
            case 54
                chord = 'D augmented';
            case 55
                chord = 'Eb augmented';
            case 56
                chord = 'E augmented';
            case 57
                chord = 'F augmented';
            case 58
                chord = 'Gb augmented';
            case 59
                chord = 'G augmented';
            case 60
                chord = 'Ab augmented';
        end
        
    elseif index < 73 % case: major 7 chord
        switch index
            case 61
                chord = 'A major 7';
            case 62
                chord = 'Bb major 7';
            case 63
                chord = 'B major 7';
            case 64
                chord = 'C major 7';
            case 65
                chord = 'Db major 7';
            case 66
                chord = 'D major 7';
            case 67
                chord = 'Eb major 7';
            case 68
                chord = 'E major 7';
            case 69
                chord = 'F major 7';
            case 70
                chord = 'Gb major 7';
            case 71
                chord = 'G major 7';
            case 72
                chord = 'Ab major 7';
        end
        
    elseif index < 85 % case: dominant 7 chord
        switch index
            case 73
                chord = 'A dominant 7';
            case 74
                chord = 'Bb dominant 7';
            case 75
                chord = 'B dominant 7';
            case 76
                chord = 'C dominant 7';
            case 77
                chord = 'Db dominant 7';
            case 78
                chord = 'D dominant 7';
            case 79
                chord = 'Eb dominant 7';
            case 80
                chord = 'E dominant 7';
            case 81
                chord = 'F dominant 7';
            case 82
                chord = 'Gb dominant 7';
            case 83
                chord = 'G dominant 7';
            case 84
                chord = 'Ab dominant 7';
        end
        
    elseif index < 97 % case: minor 7 chord
        switch index
            case 85
                chord = 'A minor 7';
            case 86
                chord = 'Bb minor 7';
            case 87
                chord = 'B minor 7';
            case 88
                chord = 'C minor 7';
            case 89
                chord = 'Db minor 7';
            case 90
                chord = 'D minor 7';
            case 91
                chord = 'Eb minor 7';
            case 92
                chord = 'E minor 7';
            case 93
                chord = 'F minor 7';
            case 94
                chord = 'Gb minor 7';
            case 95
                chord = 'G minor 7';
            case 96
                chord = 'Ab minor 7';
        end
        
    elseif index < 109 % case: minor 7 flat 5 chord
        switch index
            case 97
                chord = 'A minor 7 b5';
            case 98
                chord = 'Bb minor 7 b5';
            case 99
                chord = 'B minor 7 b5';
            case 100
                chord = 'C minor 7 b5';
            case 101
                chord = 'Db minor 7 b5';
            case 102
                chord = 'D minor 7 b5';
            case 103
                chord = 'Eb minor 7 b5';
            case 104
                chord = 'E minor 7 b5';
            case 105
                chord = 'F minor 7 b5';
            case 106
                chord = 'Gb minor 7 b5';
            case 107
                chord = 'G minor 7 b5';
            case 108
                chord = 'Ab minor 7 b5';
        end
        
    else
        switch index
            case 109
                chord = 'A diminished 7';
            case 110
                chord = 'Bb diminished 7';
            case 111
                chord = 'B diminished 7';
            case 112
                chord = 'C diminished 7';
            case 113
                chord = 'Db diminished 7';
            case 114
                chord = 'D diminished 7';
            case 115
                chord = 'Eb diminished 7';
            case 116
                chord = 'E diminished 7';
            case 117
                chord = 'F diminished 7';
            case 118
                chord = 'Gb diminished 7';
            case 119
                chord = 'G diminished 7';
            case 120
                chord = 'Ab diminished 7';
        end
    end
end