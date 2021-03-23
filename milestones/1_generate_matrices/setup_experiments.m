%{
    Danielle Nadin 2020-04-27
    Setup experimental variables for analyzing tDCS scalp data. 
    Modified from Yacine's motif analysis augmented code. 
%}

% General Experiment Variables
raw_data_path='~/projects/def-sblain/raphchr/DATA/Resting state analysis';
output_path='~/projects/def-sblain/raphchr/analysis/gtpaper/first';

participants = {'MDFA03', 'MDFA05', 'MDFA06', 'MDFA07', 'MDFA10', 'MDFA11', 'MDFA12', 'MDFA15','MDFA17'};
%'MDFA03', 'MDFA05', 'MDFA06', 'MDFA07', 'MDFA10', 'MDFA11', 'MDFA12', 'MDFA15', 
sessions = {'T1'};
states = {'baseline', 'induction_first_5', 'emergence_first_5', 'emergence_last_5', '30_post_recovery', '60_post_recovery', '90_post_recovery', '120_post_recovery', '150_post_recovery', '180_post_recovery'};
%
eyes = 'EC'; %eyes open or eyes closed 

% Power Spectra and Topography Variables
power_param = struct();
power_param.topo_frequency_band = [8 13]; % topographic map
power_param.spect_frequency_band = [1 30]; % spectrogram/PSD
power_param.figures = 1;
power_param.average = 0; % TODO: Do you want to generate the average topographic map (across participants)?

% wPLI Variables
wpli_param = struct();
wpli_param.frequency_band = [8 13]; % This is in Hz
wpli_param.window_size = 10; % This is in seconds and will be how we chunk the whole dataset
wpli_param.number_surrogate = 20; % Number of surrogate wPLI to create
wpli_param.p_value = 0.05; % the p value to make our test on
wpli_param.step_size = 1; 
wpli_param.figure = 1;

% dPLI Variables
dpli_param = struct();
dpli_param.frequency_band = [8 13]; % This is in Hz
dpli_param.window_size = 10; % This is in seconds and will be how we chunk the whole dataset
dpli_param.number_surrogate = 20; % Number of surrogate wPLI to create
dpli_param.p_value = 0.05; % the p value to make our test on
dpli_param.step_size = 1 ;
dpli_param.figure = 1; 

% Threshold sweep Experiment Variable
sweep_param = struct();
sweep_param.range = 0.90:-0.01:0.01; %more connected to less connected

% graph theory experiment variables
graph_param = struct();
graph_param.threshold = 0.41;%[0.66;0.48]
graph_param.number_surrogate = 10;
graph_param.figure = 1; 
graph_param.average = 0; %TODO

% The other parameters are recording dependant and will be dynamically
% generated
