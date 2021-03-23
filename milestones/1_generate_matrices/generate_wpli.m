%{
    Raphael Christin 2020-11-04
    Modified for only wpli, with participant input from slurm file
    
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
wpli_output_path = mkdir_if_not_exist(output_path,'wpli');

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
%create participant loop if needed
disp(strcat("Participant : ",participant));
    
% Iterate over sessions
for t = 1:length(sessions)
        
    session = sessions{t};
    disp(strcat("Session:", session));
    wpli_participant_output_path = mkdir_if_not_exist(wpli_output_path,strcat(participant,filesep,session));
        
    % Iterate over the states
    parfor s = 1:length(states)
        state = states{s};

        % Load the recording
        raw_data_filename = strcat(participant,'_',session,'_',state,'_',eyes,'.set');
        data_location = strcat(raw_data_path,filesep,participant,filesep,'DATA',filesep,session);
        recording = load_set(raw_data_filename,data_location);

        % Calculate wpli
         wpli_state_filename = strcat(wpli_participant_output_path,filesep,state,'_wpli.mat');
         result_wpli = na_wpli(recording, wpli_param.frequency_band, ...
                              wpli_param.window_size, wpli_param.step_size, ...
                              wpli_param.number_surrogate, wpli_param.p_value);
         parsave(wpli_state_filename, result_wpli);
            
         %sort matrix by region
         [r_wpli, r_labels, r_regions, r_location] = reorder_channels(result_wpli.data.avg_wpli, result_wpli.metadata.channels_location,'electrodes.csv');

         if wpli_param.figure
                
             %left brain
             left_ind = find([r_location.is_left]);
             left_matrix = r_wpli(left_ind,left_ind);
             plot_wpli(left_matrix,strcat(participant," ",session," ",state," ",eyes," Left Hemisphere wPLI"),[],'jet',0);
             imagepath = strcat(wpli_participant_output_path,filesep,state,'_left_wpli.fig');
             saveas(gcf,imagepath);
             close(gcf)
             plot_sidebar(imagepath,0,0.3,r_regions(left_ind));
                
             %right brain
             right_ind = find([r_location.is_right]);
             right_matrix = r_wpli(right_ind,right_ind);
             plot_wpli(right_matrix,strcat(participant," ",session," ",state," ",eyes," Right Hemisphere wPLI"),[],'jet',0);
             imagepath = strcat(wpli_participant_output_path,filesep,state,'_right_wpli.fig');
             saveas(gcf,imagepath);
             close(gcf)
             plot_sidebar(imagepath,0,0.3,r_regions(right_ind));
                
             %full brain
             %my (Raphael Christin) best guess as to what would work
             %from the other functions
             %to have as concatenation of 4 matrices : 
             %LR_matrix_W = r_wpli(left_ind,right_ind);
             %RL_matrix_W = r_wpli(right_ind,left_ind);
             %full_matrix = [left_matrix,LR_matrix_W; RL_matrix_W, right_matrix];
             %plot_wpli(full_matrix,strcat(participant," ",session," ",state," ",eyes," Whole Brain wPLI"),[],'jet',0);
                
             %as 1 matrix :
             plot_wpli(r_wpli,strcat(participant," ",session," ",state," ",eyes," Whole Brain wPLI"),[],'jet',0); 
             colorbar
             imagepath = strcat(wpli_participant_output_path,filesep,state,'_whole_wpli.fig');
             saveas(gcf,imagepath);
             close(gcf)
             plot_sidebar(imagepath,0,0.3,r_regions([left_ind right_ind]));
               
        end   
    end
end

function parsave(filename, name)
    %function to save in the parallel loop
    save(filename, 'name');
end