function templates = buildChordTemplates()
% BUILDCHORDTEMPLATES This is a function to generate the chord templates
% for harmonic analysis.
% 

    % Generate single note templates
    % Rows 1-12
    singleNoteMatrix = diag(ones(1,12));
    disp(singleNoteMatrix);
    
    % Generate 5th chord templates
    % Rows 13-24
    fifthChordMatrix = zeros(12);
    for root = 1:12
        fifth = mod(root + 6,12) + 1;
        fifthChordMatrix(root,:) = singleNoteMatrix(root,:) + singleNoteMatrix(fifth,:);
    end
    
    % Generate major chord templates
    % Rows 25-36
    majorChordMatrix = zeros(12);
    for root = 1:12
        third = mod(root + 3, 12) + 1;
        fifth = mod(root + 6, 12) + 1;
        majorChordMatrix(root,:) = singleNoteMatrix(root,:) + singleNoteMatrix(third,:) + singleNoteMatrix(fifth,:);
    end
    
    % Generate minor chord templates
    % Rows 37-48
    minorChordMatrix = zeros(12);
    for root = 1:12
        third = mod(root + 2, 12) + 1;
        fifth = mod(root + 6, 12) + 1;
        minorChordMatrix(root,:) = singleNoteMatrix(root,:) + singleNoteMatrix(third,:) + singleNoteMatrix(fifth,:);
    end
    
    % Combine templates into single matrix
    templates = [singleNoteMatrix; fifthChordMatrix;
        majorChordMatrix; minorChordMatrix];
end