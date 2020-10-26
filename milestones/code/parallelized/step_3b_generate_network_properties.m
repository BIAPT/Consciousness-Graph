%{
    Danielle Nadin 2020-02-20

    Generate graph theoretical network properties based on previously calculated wPLI matrix.

    * Warning: This experiment use the setup_experiments.m script to
    load variables. Therefore if you are trying to edit this code and you
    don't know what a variable mean take a look at the setup_experiments.m
    script.
%}

%% Seting up the variables
clear % to keep only what is needed for this experiment
setup_project %add ressources to path
setup_experiments % see this file to edit the experiments

% Create the output directory
graph_output_path = mkdir_if_not_exist(output_path,'graph theory');
wpli_input_path = strcat(output_path,filesep,'wpli');

%setup for parallel processing

NUM_CORE = 9;%number of cores, maybe change later

%Create a local cluster objects
local_cluster = parccluster('local')
%modify the JobStorageLocation to $SLURM_TMPDIR
local_cluster.JobStorageLocation = strcat('/scratch/raphchr/', getenv('SLURM_JOB_ID'))
%start the parallel pool
parpool(local_cluster, NUM_CORE)

% Iterate over the participants
parfor p = 1:length(participants)
    
    % Create the participants directory
    participant = participants{p};
    disp(strcat("Participant :", participant));
    
    % Iterate over the sessions
    for t = 1:length(sessions)
        session = sessions{t};
        disp(strcat("Session:", session));
        graph_participant_output_path =  mkdir_if_not_exist(graph_output_path,strcat(participant,filesep,session));
        wpli_participant_input_path = strcat(wpli_input_path,filesep,participant,filesep,session);
        
        result_graph = struct();
        result_graph.channels_location = [];
        result_graph.wpli_matrix = [];
        result_graph.binary_matrix = [];
        result_graph.clustering_coef = zeros(1,length(states)); % normalized clustering coefficient
        result_graph.geff = zeros(1,length(states));  % global efficiency
        result_graph.bsw = zeros(1,length(states));
        result_graph.mod = zeros(1,length(states));
        
        graph_session_filename = strcat(graph_participant_output_path,filesep,'_graph_theory.mat');
        
        % Iterate over the states
        for s = 1:length(states)
            state = states{s};
            disp(strcat("State :", state));
            
            % Load the wpli result
            data = load(strcat(wpli_participant_input_path,filesep,state,'_wpli.mat'));
            result_wpli = data.result_wpli;
            wpli_matrix  = result_wpli.data.avg_wpli;
            channels_location = result_wpli.metadata.channels_location;
            
            % Filter the channels location to match the filtered motifs
            [wpli_matrix,channels_location] = filter_non_scalp(wpli_matrix,channels_location);
            
            % Binarize the network
            t_network = threshold_matrix(wpli_matrix, graph_param.threshold(p,t)); %the threshold is here
            b_network = binarize_matrix(t_network);
            
            % Find average path length
            [lambda,geff,~,~,~] = charpath(distance_bin(b_network),0,0);
            
            % Find clustering coefficient
            clustering_coef = clustering_coef_bu(b_network);
            
            % Find modularity
            [M,mod] = community_louvain(b_network,1); %community, modularity
            
            % Calculate the null network parameters
            random_networks = zeros(graph_param.number_surrogate,length(wpli_matrix),length(wpli_matrix));
            for r = 1:graph_param.number_surrogate
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
            
            %save(graph_state_filename, 'result_graph');
            
        end
        result_graph.channels_location = channels_location;
        result_graph.wpli_matrix = wpli_matrix;
        result_graph.binary_matrix = b_network;
        parsave(graph_session_filename, 'result_graph');
        
        %plot change over states (within session)
        if graph_param.figure
            
            figure
            
            subplot(2,2,1)
            bar(result_graph.geff)
            title(strcat(participants{p}," ",sessions{t}," Global Efficiency"))
            ylabel('geff')
            xticklabels({'baseline','post0','post30'})
            set(gca,'LineWidth',2,'FontSize',12)
            
            subplot(2,2,2)
            bar(result_graph.clustering_coef)
            title(strcat(participants{p}," ",sessions{t}," Clustering Coefficient"))
            ylabel('cc')
            xticklabels({'baseline','post0','post30'})
            set(gca,'LineWidth',2,'FontSize',12)
            
            subplot(2,2,3)
            bar(result_graph.bsw)
            title(strcat(participants{p}," ",sessions{t}," Binary Small-Worldness"))
            ylabel('bsw')
            xticklabels({'baseline','post0','post30'})
            set(gca,'LineWidth',2,'FontSize',12)
            
            subplot(2,2,4)
            bar(result_graph.mod)
            title(strcat(participants{p}," ",sessions{t}," Modularity"))
            ylabel('mod')
            xticklabels({'baseline','post0','post30'})
            set(gca,'LineWidth',2,'FontSize',12)
            
            imagepath = strcat(graph_participant_output_path,filesep,'_graph_theory_1.fig');
            saveas(gcf,imagepath)
            close(gcf)
            
        end
        
    end
end

function parsave(filename, name)
    %to save inside parfor loop
    save(filename, name);
end
