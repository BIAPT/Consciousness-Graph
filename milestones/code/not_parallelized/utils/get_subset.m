%Modified by Danielle Nadin on 2020-05-25 for tDCS scalp analysis pipeline
%Here only want to get common labels between 2 states because baseline vs
%post0 and baseline vs post30 will have drastically different number of
%channels due to tDCS artifacts
%Want location to be a struct instead of array so we know its region (left,
%right)

function [common_labels, common_region] = get_subset(baseline_location, post_location, baseline_regions, post_regions)
% GET SUBSET is a helper function to get the subset of all the regions that
% are common across all three states
% 
% baseline_location, anesthesia_location, recovery_location: are all three
% array of structure containing channels location (eeglab way)
% baseline_regions, anesthesia_regions, recovery_regions: cell array of
% labels for the FTCPO ordering

    %% Variable initialization
    common_labels = struct([]);
    common_region = {};
    
    % concatenate all three states to be easier to iterate through
    all_location = [baseline_location post_location];
    all_regions = [baseline_regions, post_regions];


    % Iterate over each label in the all_location array to find common
    % location in all three states
    for i = 1:length(all_location)
        % Get the current label and region
        label = all_location(i).labels;
        region = all_regions{i};
        
        % get the Index of the label in each states (if exist)
        b_index = get_label_index(label, baseline_location);
        p_index = get_label_index(label, post_location);
        
        % to be common all index need to be != 0
        if(b_index ~= 0 && p_index ~= 0)
           % Save the location and the region
           common_labels = [common_labels all_location(i)];
           common_region = [common_region region];
           
           % Remove the data from the states to prevent duplication
           baseline_location(b_index) = [];
           post_location(p_index) = [];
        end
    end

end