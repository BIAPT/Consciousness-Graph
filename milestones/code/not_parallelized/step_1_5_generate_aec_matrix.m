%% Raphael Christin December 4 2020
% adapted from charlotte's code to fit in the framework for my project.

%% Charlotte Maschke November 11 2020
% This script goal is to generate the AEC matrices that are needed to
% calculate the features for each participants from the source localized
% data. The matrices will be generated twice: once with overlapping and
% once with non-overlapping windows in the alpha bandwidth.  

%% Seting up the variables
clear % to keep only what is needed for this experiment
setup_project;
setup_experiments % see this file to edit the experiments

% Create the output directory
aec_output_path = mkdir_if_not_exist(output_path,'aec');

% indice of the scalp regions
%SCALP_REGIONS = [82 62 54 56 58 60 30 26 34 32 28 24 36 86 66 76 84 74 72 70 88 3 78 52 50 48 5 22 46 38 40 98 92 90 96 94 68 16 18 20 44 83 63 55 57 59 61 31 27 35 33 29 25 37 87 67 77 85 75 71 73 89 4 79 53 51 49 6 23 47 39 41 99 93 91 97 95 69 17 19 21 45];
%NUM_REGIONS = length(SCALP_REGIONS);

% AEC Parameters:
% Alpha bandpass
low_frequency = 8;
high_frequency = 13;

% Size of the cuts for the data
window_size = 10; % in seconds
%this parameter is set to 1 (overlapping windows)and 10(non-overlapping windows).
step_size = {1,10}; % in seconds

% cut_amount: amount of points from hilbert transform to remove from the start and end.
% the goal is to not keep cut_amount from the start and cut_amount from the end.
cut_amount = 10;

% Type of graph to calculate
graph = 'aec';
session = 'T1';
eyes = 'EC';

% Participant Path (will need to iterate at the end over all the files)
% Participant Path (will need to iterate at the end over all the files)
for s = 1:length(step_size)
    step = step_size{s};
    for p = 1:length(participants)
       participant = participants{p};
       participant_out_path = mkdir_if_not_exist(aec_output_path, strcat(participant,filesep,session));
       for e = 1:length(states)
            state = states{e};

            fprintf("Analyzing participant '%s' at epoch '%s'\n", participant, state);
            
            raw_data_filename = strcat(participant,'_',session,'_',state,'_',eyes,'.set');
            data_location = strcat(raw_data_path,filesep,participant,filesep,'DATA',filesep,session);

            
            %participant_in_path = strcat(INPUT_DIR, p_id, filesep, p_id, '_', epoch, '.mat');
            
 
            if step == 1
                state_out_path = strcat(participant_out_path,'alpha_step1/', participant, '_', state, '_', graph, '.mat');            
            elseif step == 10
                participant_out_path = strcat(OUTPUT_DIR,'alpha_step10/', participant, '_', state, '_', graph, '.mat');
            end

            %% Load data
            recording = load_set(raw_data_filename,data_location);

            %Value = Value(SCALP_REGIONS,:);
            %Atlas.Scouts = Atlas.Scouts(SCALP_REGIONS);

            % Get ROI labels from atlas
            %LABELS = cell(1,NUM_REGIONS);
            %for ii = 1:NUM_REGIONS
                %LABELS{ii} = Atlas.Scouts(ii).Label;
            %end

            % Sampling frequency : need to round
            %fd = 1/(Time(2)-Time(1));

            
            %% Filtering
            % Frequency filtering, requires eeglab or other frequency filter.
            %Vfilt = filter_bandpass(Value, fd, low_frequency, high_frequency);
            %Vfilt = Vfilt';
            frequency_band = [low_frequency, high_frequency];
            filtered_data = recording.filter_data(recording.data, frequency_band);

            % number of time points and Regions of Interest
            num_points = length(filtered_data);

            %% Slice up the data into windows

            sampling_rate = 1000; % in Hz
            [windowed_data, num_window] = create_sliding_window(filtered_data, window_size, step, sampling_rate);

            %% Iterate over each window and calculate pairwise corrected aec
            result = struct();
            aec = zeros(recording.number_channels, recording.number_channels, num_window);

            parfor win_i = 1:num_window
               disp(strcat("AEC at window: ",string(win_i)," of ", string(num_window))); 
               segment_data = squeeze(windowed_data(win_i,:,:));
               aec(:,:, win_i) = aec_pairwise_corrected(segment_data, recording.number_channels, cut_amount);
            end

            % Average amplitude correlations over all windows with pairwise
            % correction. Correction is asymmetric so we take the average of the
            % elements above and below the diagonal:
            % e.g. ( corr(env(1)', env(2)) +  corr(env(1),env(2)') )/2,
            % where (1) is an ROI and env' indicates a corrected envelope.
            result.aec = (aec + permute(aec,[2,1,3]))/2; 

            % Bundling some metadata that could be useful along with the graph
            result.window_size = window_size;
            result.step_size = step;
            result.labels = recording.channels_location;

            % Save the result structure at the right spot
            save(participant_out_path, 'result');
            
            %reorder channels
            [r_aec, r_labels, r_regions, r_location] = reorder_channels(result.aec, result.labels,'biapt_egi129.csv');

            plot_wpli(r_aec,strcat(participant," ",session," ",state," ",eyes," Whole Brain AEC"),[],'jet',0); 
            colorbar
            imagepath = strcat(participant_output_path,filesep,state,'_whole_aec.fig');
            saveas(gcf,imagepath);
            %r_regions([left_ind right_ind])
            %imagepath = strcat(dpli_participant_output_path,filesep,state,'_whole_wpli.png');
            %saveas(gcf,imagepath);
            close(gcf)
            %plot_sidebar(imagepath,0,0.3,r_regions([left_ind right_ind]));
       end
    end
end
    
% This function is to get overlapping windowed data
function [windowed_data, num_window] = create_sliding_window(data, window_size, step_size, sampling_rate)
%% CREATE SLIDING WINDOW will slice up the data into windows and return them
    %
    % input:
    % data: the points*num regions matrix representing the data
    % window_size: the size of the window in seconds
    % step_size: the size of the step in seconds
    % sampling_rate: the sampling rate of the recording
    %
    % output:
    % windowed_data: the sliced up data which is now a
    % num_window*point*channel tensor
    % num_window: the number of window in the windowed_data
    
    [length_data, num_region] = size(data);
    
    % Need to round from seconds -> points conversion since points are
    % integer valued
    window_size = round(window_size*sampling_rate); % in points
    step_size = round(step_size*sampling_rate); % in points
    
    num_window = length(1:step_size:(length_data - window_size));
    
    windowed_data = zeros(num_window, window_size, num_region);
    index = 1;
    for i = 1:step_size:(length_data - window_size)
        windowed_data(index,:,:) = data(i:i+window_size-1, :);
        index = index + 1;
    end
    
end

function [aec] = aec_pairwise_corrected(data, num_regions, cut_amount)
%% AEC PAIRWISE CORRECTED helper function to calculate the pairwise corrected aec
%
% input:
% data: the data segment to calculate pairwise corrected aec on
% num_regions: number of regions
% cut_amount: the amount we need to remove from the hilbert transform
%
% output:
% aec: a num_region*num_region matrix which has the amplitude envelope
% correlation between two regions
    
    aec = zeros(num_regions, num_regions);
        
    %% Pairwise leakage correction in window for AEC
    % Loops around all possible ROI pairs
    for region_i = 1:num_regions
        y = data(:, region_i);
        for region_j =  1:num_regions
            
            % Skip the correlation between itself
            if region_i == region_j
               continue 
            end
            
            x = data(:, region_j);
            
            % Leakage Reduction
            beta_leak = pinv(y)*x;
            xc = x - y*beta_leak;            
                       
            ht = hilbert([xc,y]);
            ht = ht(cut_amount+1:end-cut_amount,:);
            ht = bsxfun(@minus,ht,mean(ht,1));
            
            % Envelope
            env = abs(ht);
            c = corr(env);
            
            aec(region_i,region_j) = c(1,2);
        end
    end
    
    % Set the diagonal to 0 
    aec(:,:) = aec(:,:).*~eye(num_regions);
end