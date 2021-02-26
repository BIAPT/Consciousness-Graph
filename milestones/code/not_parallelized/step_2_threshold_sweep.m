  %Danielle Nadin 11-12-2019
%Sweep through range of network thresholds and compute binary small-worldness to determine 
% the 'small-world regime range' as defined in Basset et al (2008). 

% modified by Yacine Mahdid 2019-12-12
% modified by Danielle Nadin 2020-02-25 adapt for Motif Analysis Augmented pipeline

clear;
setup_project;
setup_experiments % see this file to edit the experiments
session = 'T1';
mode = 'dpli';

for p = 1: length(participants)
    %for s = 1 : length(states)
        
        %Import pli data
        pli_input_path = strcat(output_path,mode,filesep,participants{p},filesep,session,filesep,'baseline_', mode, '.mat');
        data = load(pli_input_path);
        if strcmp(mode, 'dpli')
            pli_matrix = data.name.data.avg_dpli;
            channels_location = data.name.metadata.channels_location;
        elseif strcmp(mode, 'wpli')
            pli_matrix = data.name.data.avg_wpli;
            channels_location = data.name.metadata.channels_location;
        elseif strcmp(mode, 'aec')
                pli_matrix = data.result.aec;
                [hight, width, len] = size(pli_matrix);
                temp = zeros(hight, width);
                for i=1:hight
                    for j=1:width
                        for k=1:len
                            temp(i,j) = temp(i,j) + pli_matrix(i,j,k);
                        end
                    end
                end
                temp = temp/len;
                pli_matrix=temp;
                channels_location = data.result.labels;
        end
        
        

        % Here we need to filter the non_scalp channels
        [pli_matrix,channels_location] = filter_non_scalp(pli_matrix,channels_location);

        %loop through thresholds
        for j = 1:length(sweep_param.range) 
            current_threshold = sweep_param.range(j);
            disp(strcat("Doing the threshold : ", string(current_threshold)));
    
            % Thresholding and binarization using the current threshold
            t_network = threshold_matrix(pli_matrix, current_threshold, mode);
            b_network = binarize_matrix(t_network);
    
            % check if the binary network is disconnected
            % Here our binary network (b_network) is a weight matrix but also an
            % adjacency matrix.
            distance = distance_bin(b_network);
    
            % Here we check if there is one node that is disconnected
            if(sum(isinf(distance(:))))
                disp(strcat("Final threshold: ", string(sweep_param.range(j-1))));
                graph_param.threshold(p) = sweep_param.range(j-1);
                if strcmp(mode, 'dpli')
                    graph_param.threshold(p) = sweep_param.range(j-1);
                end
                break;
            end
        end
    %end
end

