function templates = buildChordTemplates()
% BUILDCHORDTEMPLATES This is a function to generate the chord templates
% for harmonic analysis.
% 

    % Generate single note templates
    singleNoteMatrix = diag(ones(1,12));
    
    % Generate 5th chord templates
    % Rows 1-12
    fifthChordMatrix = zeros(12);
    for root = 1:12
        fifth = mod(root + 6,12) + 1;
        fifthChordMatrix(root,:) = singleNoteMatrix(root,:) + singleNoteMatrix(fifth,:);
    end
    
    % Generate major chord templates
    % Rows 13-24
    majorChordMatrix = zeros(12);
    for root = 1:12
        third = mod(root + 3, 12) + 1;
        fifth = mod(root + 6, 12) + 1;
        majorChordMatrix(root,:) = singleNoteMatrix(root,:) + singleNoteMatrix(third,:) + singleNoteMatrix(fifth,:);
    end
    
    % Generate minor chord templates
    % Rows 25-36
    minorChordMatrix = zeros(12);
    for root = 1:12
        third = mod(root + 2, 12) + 1;
        fifth = mod(root + 6, 12) + 1;
        minorChordMatrix(root,:) = singleNoteMatrix(root,:) + singleNoteMatrix(third,:) + singleNoteMatrix(fifth,:);
    end
    
    % Generate diminished chord templates
    % Rows 37-48
    dimChordMatrix = zeros(12);
    for root = 1:12
        third = mod(root + 2, 12) + 1;
        fifth = mod(root + 5, 12) + 1;
        dimChordMatrix(root,:) = singleNoteMatrix(root,:) + singleNoteMatrix(third,:) + singleNoteMatrix(fifth,:);
    end
    
    % Generate augmented chord templates
    % Rows 49-60
    augChordMatrix = zeros(12);
    for root = 1:12
        third = mod(root + 3, 12) + 1;
        fifth = mod(root + 7, 12) + 1;
        augChordMatrix(root,:) = singleNoteMatrix(root,:) + singleNoteMatrix(third,:) + singleNoteMatrix(fifth,:);
    end
    
    % Generate major 7 chord templates
    % Rows 61-72
    maj7ChordMatrix = zeros(12);
    for root = 1:12
        third = mod(root + 3, 12) + 1;
        fifth = mod(root + 6, 12) + 1;
        seventh = mod(root + 10, 12) + 1;
        maj7ChordMatrix(root,:) = singleNoteMatrix(root,:) + singleNoteMatrix(third,:) + singleNoteMatrix(fifth,:) + singleNoteMatrix(seventh,:);
    end
    
    % Generate dominant 7 chord templates
    % Rows 73-84
    dom7ChordMatrix = zeros(12);
    for root = 1:12
        third = mod(root + 3, 12) + 1;
        fifth = mod(root + 6, 12) + 1;
        seventh = mod(root + 9, 12) + 1;
        dom7ChordMatrix(root,:) = singleNoteMatrix(root,:) + singleNoteMatrix(third,:) + singleNoteMatrix(fifth,:) + singleNoteMatrix(seventh,:);
    end
    
    % Generate minor 7 chord templates
    % Rows 85-96
    min7ChordMatrix = zeros(12);
    for root = 1:12
        third = mod(root + 2, 12) + 1;
        fifth = mod(root + 6, 12) + 1;
        seventh = mod(root + 9, 12) + 1;
        min7ChordMatrix(root,:) = singleNoteMatrix(root,:) + singleNoteMatrix(third,:) + singleNoteMatrix(fifth,:) + singleNoteMatrix(seventh,:);
    end
    
    % Generate minor 7 flat 5 chord templates
    % Rows 97-108
    min7b5ChordMatrix = zeros(12);
    for root = 1:12
        third = mod(root + 2, 12) + 1;
        fifth = mod(root + 5, 12) + 1;
        seventh = mod(root + 9, 12) + 1;
        min7b5ChordMatrix(root,:) = singleNoteMatrix(root,:) + singleNoteMatrix(third,:) + singleNoteMatrix(fifth,:) + singleNoteMatrix(seventh,:);
    end
    
    % Generate diminished 7 chord templates
    % Rows 109 - 120
    dim7ChordMatrix = zeros(12);
    for root = 1:12
        third = mod(root + 2, 12) + 1;
        fifth = mod(root + 5, 12) + 1;
        seventh = mod(root + 8, 12) + 1;
        dim7ChordMatrix(root,:) = singleNoteMatrix(root,:) + singleNoteMatrix(third,:) + singleNoteMatrix(fifth,:) + singleNoteMatrix(seventh,:);
    end
    
    % Combine templates into single matrix
    templates = [fifthChordMatrix;
        majorChordMatrix; minorChordMatrix;
        dimChordMatrix; augChordMatrix;
        maj7ChordMatrix; dom7ChordMatrix; min7ChordMatrix;
        min7b5ChordMatrix; dim7ChordMatrix];
end