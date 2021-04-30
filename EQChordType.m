% Enumeration class definition for chord type
classdef EQChordType < int8
    enumeration
        noChord     (0)
        five        (1)
        min         (2)
        maj         (3)
        dim         (4)
        aug         (5)
        min7        (6)
        dom7        (7)
        maj7        (8)
        m7b5        (9)
        dim7        (10)
    end
end