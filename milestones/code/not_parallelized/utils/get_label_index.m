%Modified by Danielle Nadin on 2020-05-25 for tDCS scalp analysis pipeline
%Want location to be a struct instead of array so we know its region (left,
%right)

function [label_index] = get_label_index(label, location)
% GET LABEL INDEX is a helper function to find a given label inside a
% location structure (brute force)
% 
% label: a string label to find
% location: a 1*N channel location structure array from eeglab

    % Iterate over each location and double check if they are the one we
    % are looking for
    label_index = 0;
    for i = 1:length(location)
       if(strcmp(label,location(i).labels))
          label_index = i;
          return
       end
    end
    
end