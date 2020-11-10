%{
    Raphael Christin 2020-11-04
    Modified for only dpli, with participant input from slurm file
    
    Danielle Nadin 2020-04-30
    Modified for healthy tDC S analysis - automate figure generation. 
  
    Yac ine Mah did 202  0- 01-08
    This script will  calcul  ate the wpli and the dpli matrices (at alpha)
    that are ne  ede d to run the subsequent analysis. The parameters for the
    analysis can be  found in this script

    * Warning: This exp  eriment use the setup_experiments.m script to 
    load variables. Therefore if you are trying to edit this code and you
    don't know what a variable mean take a look at the setup_experiments.m
    script.

    The participant variable must be set in the slurm file setting up the
    task for running on beluga
%}

%% Seting up the variables
%clear;
setup_project %create appropriate paths
setup_experiments % see this file to edit the experiments

% Create the wpli directory
dpli_output_path = mkdir_if_not_exist(output_path,'dpli');

%setup for parallelization
%code from Yacine mahdid's youtube channel
%introduction to high performance computing for machine learning

%NUM_CORE = 10;%number of cores, maybe change later

%Create a local cluster objects
%local_cluster = parcluster('local')
%modify the JobStorageLocation to $SLURM_TMPDIR
%pc.JobStorageLocation = strcat('/scratch/raphchr/', getenv('SLURM_JOB_ID'))
%start the parallel pool
%parpool(local_cluster, NUM_CORE)

%display participant, must be set through slurm file
disp(strcat("Participant : ",participant));
    
% Iterate over sessions
for t = 1:length(sessions)
        
    session = sessions{t};
    disp(strcat("Session:", session));
    dpli_participant_output_path = mkdir_if_not_exist(dpli_output_path,strcat(participant,filesep,session));
        
    % Iterate over the states
    parfor s = 1:length(states)
        state = states{s};

        % Load the recording
        raw_data_filename = strcat(participant,'_',session,'_',state,'_',eyes,'.set');
        data_location = strcat(raw_data_path,filesep,participant,filesep,'DATA',filesep,session);
        recording = load_set(raw_data_filename,data_location);

        % Calculate dpli
        dpli_state_filename = strcat(dpli_participant_output_path,filesep,state,'_dpli.mat');
        result_dpli = na_dpli(recording, dpli_param.frequency_band, ...
                              dpli_param.window_size, dpli_param.step_size, ...
                              dpli_param.number_surrogate, dpli_param.p_value);
        parsave(dpli_state_filename, result_dpli);
            
        %sort matrix by region
        [r_dpli, r_labels, r_regions, r_location] = reorder_channels(result_dpli.data.avg_dpli, result_dpli.metadata.channels_location,'biapt_egi129.csv');

        if dpli_param.figure
                
            %left brain
            left_ind = find([r_location.is_left]);
            left_matrix = r_dpli(left_ind,left_ind);
            plot_pli(left_matrix,r_regions(left_ind),left_matrix(:),'*RdYlBu');
            title(strcat(participant," ",session," ",state," ",eyes," Left Hemisphere dPLI"))
            colorbar
            imagepath = strcat(dpli_participant_output_path,filesep,state,'_left_dpli.fig');
            saveas(gcf,imagepath);
            imagepath = strcat(dpli_participant_output_path,filesep,state,'_left_dpli.png');
            saveas(gcf,imagepath);
            close(gcf)
                
            %right brain
            right_ind = find([r_location.is_right]);
            right_matrix = r_dpli(right_ind,right_ind);
            plot_pli(right_matrix,r_regions(right_ind),right_matrix(:),'*RdYlBu');
            title(strcat( participant," ",session," ",state," ",eyes," Right Hemisphere dPLI"))
            colorbar
            imagepath = strcat(dpli_participant_output_path,filesep,state,'_right_dpli.fig');
            saveas(gcf,imagepath);
            imagepath = strcat(dpli_participant_output_path,filesep,state,'_right_dpli.png');
            saveas(gcf,imagepath);
            close(gcf)
                
            %to have as one big matrix :
            plot_pli(r_dpli,r_regions, r_dpli(:), '*RdYlBu');
            title(strcat(participant," ",session," ",state," ",eyes," Whole Brain dPLI"))
            colorbar
            imagepath = strcat(dpli_participant_output_path,filesep,state,'_whole_dpli.fig');
            saveas(gcf,imagepath);
            imagepath = strcat(dpli_participant_output_path,filesep,state,'_whole_dpli.png');
            saveas(gcf,imagepath);
            close(gcf)
               
        end   
    end
end

function parsave(filename, name)
    %function to save in the parallel loop
    save(filename, 'name');
end