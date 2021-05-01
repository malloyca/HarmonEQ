% Enumeration class definition for chord type
classdef EQChordType < int8
    enumeration
        noChord     (0)
        five        (1)
        minor       (2)
        major       (3)
        diminished  (4)
        augmented   (5)
        minor7      (6)
        dominant7   (7)
        major7      (8)
        minor7b5    (9)
        diminished7 (10)
    end
end