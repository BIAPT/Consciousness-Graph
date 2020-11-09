#!/bin/bash -l
#SBATCH --job-name=generate-wpli-05 # give a name to the job
#SBATCH --account=def-sblain # adjust to match the accounting group
#SBATCH --time=0-12:00:00 # adjust to match the time required for the job, (D-HH:MM:SS) be as accurate ap
#SBATCH --nodes=1 # adjust to the number of nodes
#SBATCH --ntasks=1 # number of tasks
#SBATCH --cpus-per-task=40 # adjust if parallel commands
#SBATCH --mem=9000 # adjust to memory required per node in MegaBytes
#SBATCH --mail-user=raphael.christin@mail.mcgill.ca
#SBATCH --mail-type=ALL

# load modules (choose matlab version)
module load matlab/2020a  # maybe 2020a?

# create temporary job info location
mkdir -p /scratch/$USER/$SLURM_JOB_ID

# run
srun matlab -nodisplay -r "participant = 'MDFA05'; generate_wpli" # will run on at most 40 cores

# cleanup
rm -rf /scratch/$USER/$SLURM_JOB_ID
