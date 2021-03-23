%{
    Danielle Nadin 2020-02-20

    Generate graph theoretical network properties based on previously calculated wPLI matrix.

    * Warning: This experiment use the setup_experiments.m script to
    load variables. Therefore if you are trying to edit this code and you
    don't know what a variable mean take a look at the setup_experiments.m
    script.

    Adapted by Raphael Christin, 2021-03-22

    make sure to edit the setup_experiments and setup_project to your needs
%}

%make sure to uncomment the right lines at line 23, lines 28-29, lines 119-121

%% Seting up the variables
%clear % to keep only what is needed for this experiment
setup_project;
setup_experiments % see this file to edit the experiments
step_1b_threshold_mcg;%uncomment for mcg
mode = 'wpli';
% Create the output directory
graph_output_path = mkdir_if_not_exist(output_path,'graph theory');
mode_output_path = mkdir_if_not_exist(graph_output_path, mode);
pli_input_path = strcat(output_path,filesep,mode);
%threshold=sprintf('%.2f',current_threshold);%uncomment for threshold range
threshold = 'mcg';%uncomment and change name for mcg and omst 
threshold_output_path = mkdir_if_not_exist(mode_output_path, strcat('threshold_', threshold));
average_output_path = mkdir_if_not_exist(threshold_output_path,'average');


%create a struct to store participant data
all_participants = struct();
all_participants.clustering_coef = zeros(length(participants),length(states)); % normalized clustering coefficient
all_participants.geff = zeros(length(participants),length(states));  % global efficiency
all_participants.bsw = zeros(length(participants),length(states));
all_participants.mod = zeros(length(participants),length(states));

%store current number of participant processed
num_participant = 1;

% Iterate over the participants
for p = 1:length(participants)
    
    % Create the participants directory
    participant = participants{p};
    disp(strcat("Participant :", participant));
    %current_threshold = 0.30;
    
    % Iterate over the sessions
    for t = 1:length(sessions)
        session = sessions{t};
        disp(strcat("Session:", session));
        graph_participant_output_path =  mkdir_if_not_exist(threshold_output_path,strcat(participant,filesep,session));
        pli_participant_input_path = strcat(pli_input_path,filesep,participant,filesep,session);
        
        result_graph = struct();
        result_graph.channels_location = [];
        result_graph.wpli_matrix = [];
        result_graph.binary_matrix = [];
        result_graph.clustering_coef = zeros(1,length(states)); % normalized clustering coefficient
        result_graph.geff = zeros(1,length(states));  % global efficiency
        result_graph.bsw = zeros(1,length(states));
        result_graph.mod = zeros(1,length(states));
        
        binary_matrices = struct();
        binary_matrices.baseline = [];
        binary_matrices.induction_first_5 = [];
        binary_matrices.emergence_first_5 = [];
        binary_matrices.emergence_last_5 = [];
        binary_matrices.post_30 = [];
        binary_matrices.post_60 = [];
        binary_matrices.post_90 = [];
        binary_matrices.post_120 = [];
        binary_matrices.post_150 = [];
        binary_matrices.post_180 = [];
        
        
        graph_session_filename = strcat(graph_participant_output_path,filesep,'_graph_theory.mat');
        bmatrix_session_filename = strcat(graph_participant_output_path,filesep,'binary_matrices.mat');
        
        % Iterate over the states
        for s = 1:length(states)
            state = states{s};
            disp(strcat("State :", state));
            
            % Load the wpli result
            data = load(strcat(pli_participant_input_path,filesep,state,'_',mode,'.mat'));
            if strcmp(mode, 'dpli')
                pli_matrix  = data.name.data.avg_dpli;
                channels_location = data.name.metadata.channels_location;
            elseif strcmp(mode, 'wpli')
                pli_matrix  = data.name.data.avg_wpli;
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
            
            
            % Filter the channels location to match the filtered motifs
            [pli_matrix, r_labels, r_regions, channels_location] = reorder_channels(pli_matrix, channels_location,'electrodes.csv');
            %[pli_matrix,channels_location] = filter_non_scalp(pli_matrix,channels_location); %compare filtering
            
            % Binarize the network
            t_network = threshold_matrix_mode(pli_matrix, graph_param.threshold(p), mode); %for mcg
            %t_network = threshold_matrix_mode(pli_matrix, threshold, mode); %for threshold range
            %[~, t_network, ~, ~, ~, ~] = threshold_omst_gce_wu(pli_matrix,0);%for omst
            b_network = binarize_matrix(t_network);
            %store bmatrix
            switch state
                case 'baseline'
                    binary_matrices.baseline = b_network;
                case 'induction_first_5'
                    binary_matrices.induction_first_5 = b_network;
                case 'emergence_first_5'
                    binary_matrices.emergence_first_5 = b_network;
                case 'emergence_last_5'
                    binary_matrices.emergence_last_5 = b_network;
                case '30_post_recovery'
                    binary_matrices.post_30 = b_network;
                case '60_post_recovery'
                    binary_matrices.post_60 = b_network;
                case '90_post_recovery'
                    binary_matrices.post_90 = b_network;
                case '120_post_recovery'
                    binary_matrices.post_120 = b_network;
                case '150_post_recovery'
                    binary_matrices.post_150 = b_network;
                case '180_post_recovery'
                    binary_matrices.post_180 = b_network;
            end
            
            % Find average path length
            [lambda,geff,~,~,~] = charpath(distance_bin(b_network),0,0);
            
            % Find clustering coefficient
            clustering_coef = clustering_coef_bu(b_network);
            
            % Find modularity
            [M,mod] = community_louvain(b_network,1); %community, modularity
            
            % Calculate the null network parameters
            random_networks = zeros(graph_param.number_surrogate,length(pli_matrix),length(pli_matrix));
            parfor r = 1:graph_param.number_surrogate
                disp(strcat("Random network #",string(r)));
                [random_networks(r,:,:),~] = randmio_und(b_network,10);    % generate random matrix
            end
            
            % Find properties for `number_random_network` random network
            total_random_geff = 0;
            total_random_clustering_coef = 0;
            for r = 1:graph_param.number_surrogate
                % Create the random network based on the pli matrix instead of the binary network
                random_b_network = squeeze(random_networks(r,:,:));
                
                [rlambda,rgeff,~,~,~] = charpath(distance_bin(random_b_network),0,0);   % charpath for random network
                random_clustering_coef = clustering_coef_bu(random_b_network); % cc for random network
                
                total_random_geff = total_random_geff + rgeff;
                total_random_clustering_coef = total_random_clustering_coef + nanmean(random_clustering_coef);
                
            end
            
            rgeff = total_random_geff/graph_param.number_surrogate;
            global_random_clustering_coef = total_random_clustering_coef/graph_param.number_surrogate;
            
            % Normalize network properties against random network and save into
            % structure and into disk
            %result_graph = struct();
            
            result_graph.clustering_coef(1,s) = nanmean(clustering_coef) / global_random_clustering_coef; % normalized clustering coefficient
            result_graph.geff(1,s) = geff / rgeff;  % global efficiency
            result_graph.bsw(1,s) = result_graph.clustering_coef(1,s)*result_graph.geff(1,s);
            result_graph.mod(1,s) = mod; % Note: modularity doesn't need to be normalized against random networks
            
            %add to average graph
            all_participants.clustering_coef(num_participant,s) = result_graph.clustering_coef(1,s);
            all_participants.geff(num_participant,s) = result_graph.geff(1,s);
            all_participants.bsw(num_participant,s) = result_graph.bsw(1,s);
            all_participants.mod(num_participant,s) = result_graph.mod(1,s);
            
            %save(graph_state_filename, 'result_graph');
            
        end
        result_graph.channels_location = channels_location;
        result_graph.pli_matrix = pli_matrix;
        result_graph.binary_matrix = b_network;
        save(graph_session_filename, 'result_graph');
        save(bmatrix_session_filename, 'binary_matrices');
        
        bmatrices_participant_output_path =  mkdir_if_not_exist(graph_participant_output_path,'binary_matrices_plots');
        
        for i = 1: length(states)
            state_ = states{i}
             switch i
                case 1
                    matrix = binary_matrices.baseline;
                case 2
                    matrix = binary_matrices.induction_first_5;
                case 3
                    matrix = binary_matrices.emergence_first_5;
                case 4
                    matrix = binary_matrices.emergence_last_5;
                case 5
                    matrix = binary_matrices.post_30;
                case 6
                    matrix = binary_matrices.post_60;
                case 7
                    matrix = binary_matrices.post_90;
                case 8
                    matrix = binary_matrices.post_120;
                case 9
                    matrix = binary_matrices.post_150;
                case 10
                    matrix = binary_matrices.post_180;
             end
            
             plot_wpli(matrix,strcat(participant," ",session," ",state_," binary matrix"),[],'jet',0); 
             colorbar
             imagepath = strcat(bmatrices_participant_output_path,filesep, state_,'_binary_matrix.fig');
             saveas(gcf,imagepath);
             close(gcf)
        end
        
        %plot change over states (within session)
        if graph_param.figure
            
            figure
            
            subplot(2,2,1)
            bar(result_graph.geff)
            title(strcat(participants{p}," ",sessions{t}," Global Efficiency"))
            ylabel('geff')
            xticklabels({'base','induct','em_1st_5', 'em_last_5', 'post_30', 'post_60', 'post_90','post_120','post_150','post_180'})
            set(gca,'LineWidth',2,'FontSize',12)
            
            subplot(2,2,2)
            bar(result_graph.clustering_coef)
            title(strcat(participants{p}," ",sessions{t}," Clustering Coefficient"))
            ylabel('cc')
            xticklabels({'base','induct','em_1st_5', 'em_last_5', 'post_30', 'post_60', 'post_90','post_120','post_150','post_180'})
            set(gca,'LineWidth',2,'FontSize',12)
            
            subplot(2,2,3)
            bar(result_graph.bsw)
            title(strcat(participants{p}," ",sessions{t}," Binary Small-Worldness"))
            ylabel('bsw')
            xticklabels({'base','induct','em_1st_5', 'em_last_5', 'post_30', 'post_60', 'post_90','post_120','post_150','post_180'})
            set(gca,'LineWidth',2,'FontSize',12)
            
            subplot(2,2,4)
            bar(result_graph.mod)
            title(strcat(participants{p}," ",sessions{t}," Modularity"))
            ylabel('mod')
            xticklabels({'base','induct','em_1st_5', 'em_last_5', 'post_30', 'post_60', 'post_90','post_120','post_150','post_180'})
            set(gca,'LineWidth',2,'FontSize',12)
            
            imagepath = strcat(graph_participant_output_path,filesep,'_graph_theory_1.fig');
            saveas(gcf,imagepath)
            close(gcf)
            
        end
        
    end
    %record number of participants for the average
    num_participant = num_participant + 1;
end
%add up the values to conmpute average
average = struct();
average.clustering_coef = zeros(1, length(states));
average.geff = zeros(1, length(states));
average.bsw = zeros(1, length(states));
average.mod = zeros(1, length(states));

for i = 1:length(participants)
    for s = 1:length(states)
        average.clustering_coef(1, s) = average.clustering_coef(1, s) + all_participants.clustering_coef(i, s);
        average.geff(1, s) = average.geff(1, s) + all_participants.geff(i, s);
        average.bsw(1, s) = average.bsw(1, s) + all_participants.bsw(i, s);
        average.mod(1, s) = average.mod(1, s) + all_participants.mod(i, s);
    end
end

%compute average
average.clustering_coef = average.clustering_coef / length(participants);
average.geff = average.geff / length(participants);
average.mod = average.mod / length(participants);
average.bsw = average.bsw / length(participants);

%compute standard deviation
std_dev = struct();
std_dev.clustering_coef = zeros(1, length(states));
std_dev.geff = zeros(1, length(states));
std_dev.mod = zeros(1, length(states));
std_dev.bsw = zeros(1, length(states));

for j=1:length(participants)
    for s = 1:length(states)
        std_dev.clustering_coef(1, s) = std_dev.clustering_coef(1, s) + abs(average.clustering_coef(1, s) - all_participants.clustering_coef(j, s));
        std_dev.geff(1, s) = std_dev.geff(1, s) + abs(average.geff(1, s) - all_participants.geff(j, s));
        std_dev.mod(1, s) = std_dev.mod(1, s) + abs(average.mod(1, s) - all_participants.mod(j, s));
        std_dev.bsw(1, s) = std_dev.bsw(1, s) + abs(average.bsw(1, s) - all_participants.bsw(j, s));
    end
end

std_dev.clustering_coef = std_dev.clustering_coef / length(participants);
std_dev.geff = std_dev.geff / length(participants);
std_dev.mod = std_dev.mod / length(participants);
std_dev.bsw = std_dev.bsw / length(participants);

%plot and save average graph
average_data_filename = strcat(average_output_path,filesep,'average_data.mat');
save(average_data_filename, 'average');

figure

x = 1:10;
subplot(2,2,1)
bar(x, average.geff)
title("Average Global Efficiency")
ylabel('geff')
xticklabels({'base','induct','em_1st_5', 'em_last_5', 'post_30', 'post_60', 'post_90','post_120','post_150','post_180'})
set(gca,'LineWidth',2,'FontSize',12)
hold on
er = errorbar(x, average.geff,std_dev.geff, std_dev.geff);
hold off
            
subplot(2,2,2)
bar(x, average.clustering_coef)
title("Average Clustering Coefficient")
ylabel('cc')
xticklabels({'base','induct','em_1st_5', 'em_last_5', 'post_30', 'post_60', 'post_90','post_120','post_150','post_180'})
set(gca,'LineWidth',2,'FontSize',12)
hold on
er = errorbar(x, average.clustering_coef,std_dev.clustering_coef, std_dev.clustering_coef);
hold off
            
subplot(2,2,3)
bar(x, average.bsw)
title("Average Binary Small-Worldness")
ylabel('bsw')
xticklabels({'base','induct','em_1st_5', 'em_last_5', 'post_30', 'post_60', 'post_90','post_120','post_150','post_180'})
set(gca,'LineWidth',2,'FontSize',12)
hold on
er = errorbar(x, average.bsw,std_dev.bsw, std_dev.bsw);
hold off
            
subplot(2,2,4)
bar(x, average.mod)
title("Average Modularity")
ylabel('mod')
xticklabels({'base','induct','em_1st_5', 'em_last_5', 'post_30', 'post_60', 'post_90','post_120','post_150','post_180'})
set(gca,'LineWidth',2,'FontSize',12)
hold on
er = errorbar(x, average.mod,std_dev.mod, std_dev.mod);
hold off
            
imagepath = strcat(average_output_path,filesep,'average_graph_theory_.fig');
saveas(gcf,imagepath)
close(gcf)


