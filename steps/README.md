# Documentation 
This is the documentation for the code used in this experiment. The code is split into two steps: 
- generate_matrices, which contains the code necessary to compute the wpli, dpli and aec matrices from the .set eeglab preprocessed data
- calculated_graph_properties,  which contains the code necessary to compute the graph theoretical properties from those matrices 
## Preparation
The data files should be ordered and named in the following way: raw_data_path/participant(s)/session(s)/participant_session_state_eyes.set, where eyes is the status of the patient´s eyes, EC for eyes closed
## How to generate the matrices
This section covers how to generate the wpli, dpli and aec matrices from the eeglab .set files. The code discussed in this section is present in the 1_generate_matrices folder.
### Adjusting the code
To run the code, one needs to adjust the code in the following ways:
- Adjust the neuroalgo_path variable in the setup_project file to the absolute path to the folder containing the NeuroAlgo library on the machine running the code
- Adjust the raw_data_path and output_path variables in the setup experiments file to the location of the raw data (the folder that contains all the participants´directories, as described above) and the desired output path on the machine running the code
- Adjust the participants, states and sessions variables in the setup_experiments file to the participants, sessions and states for which one wants to compute the matrices
- Adjust other parameters in the setup_experiments as necessary
- Adjust the high_frequency, low_frequency, window_size, step_size, cut_amount, session, eyes and sampling_rate (line 94) variables in the generate_aec file as needed for the experiments, if one wants to compute aec matrices.
### Running the code
This section covers the procedure necessary to run the code, either locally or on the compute canada servers
#### Locally
To run this locally, just adjust the parameters for the wanted matrices and run the according generate_matrix file (for example, generate_wpli for wpli matrices) in matlab. 
#### On compute canada servers 
To run this on compute canada servers, one needs to first obtain access to the servers. Once that is established, one needs to clone this repository on the compute canada server they are using and also download the data they want to analyze on the compute canada server. One then needs to adjust the code as described above. Then, one needs to create a slurm batch file. an example of such a file is presented in the sample.sl file. In the slurm file, one needs to adjust the name of the job, as follows :
```
#SBATCH --job-name=wanted-nem-for-this-job
```
One can also adjust other parameters, comments in the sample.sl file explain what each parameter is for. For example, one can adjust the time allowed to the job by adjusting the following parameter: 
```
#SBATCH --time=0-12:00:00 
```
The time is formatted as days-hours:minutes:seconds.   
One also needs to adjust the following line in the sample.sl file to match their needs:
```
srun matlab -nodisplay -r "participant = 'MDFA03'; generate_wpli"
```
One needs to replace the participant name to match the wanted participant and the generate_wpli to generate_dpli or generate_aec as needed.  
Alternatively, one could write a for loop inside of the wanted script that iterates over all the participants and write as follows: 
```
srun matlab -nodisplay -r "generate_wpli"
```
Then, one needs to submit the job to slurm as follows, in the command line of the compute canada machine:
```
sbatch sample.sl
```
Then, slurm will take care of the job and send you email updates, using the email defined in the slurm file. Of course, one needs to adjust the name from sample.sl to fit their needs.
## How to calculate the graph properties
I computed all the graph properties on my own machine so there is no code to run this on compute canada servers but one could reuse the procedure described above to do it. The graph theoretical properties that are computed are the modularity, the clustering coefficient, the global efficiency and the binary small worldness.
### Adjusting the code
One needs to adjust the code depending on which type of graph and which thresholding method they wish to use. 
#### Keeping the top xx% of the connection
To threshold in this manner, the user needs to adjust to threshold and modes variables in the step_1c_all_thresholds.m file. Then, one needs to comment out line 22 and 23 in the step_1_gnnerate_network_properties.m file, as follows: 
```
%step_1b_threshold_mcg;%uncomment for mcg
%mode = 'wpli';
```
One also needs to uncomment line 28 in the same file, and make sure line 29 is commented out, as follows: 
```
threshold=sprintf('%.2f',current_threshold);%uncomment for threshold range
%threshold = 'mcg';%uncomment and change name for mcg and omst 
```
One also needs to comment out lines 119 and 121, and uncomment line 120, in the same file, as follows: 
```
%t_network = threshold_matrix_mode(pli_matrix, graph_param.threshold(p), mode); %for mcg
t_network = threshold_matrix_mode(pli_matrix, threshold, mode); %for threshold range
%[~, t_network, ~, ~, ~, ~] = threshold_omst_gce_wu(pli_matrix,0);%for omst
```
After all these modifications, running the step_1c_all_trhesholds.m file will compute all the graph properties for the specified modes and threshold range
#### Minimally connected graph
