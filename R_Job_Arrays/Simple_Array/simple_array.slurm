#!/bin/bash

###########################
### Simple 10-array job ###
###########################

#SBATCH --job-name=simple_array
#SBATCH --time=1:00
#SBATCH --mail-type=NONE
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --array=1-10
#SBATCH --output=log/%x_%A-%a.out

# Create output directories in the submission directory, if not existing
mkdir -p "$SLURM_SUBMIT_DIR"/log "$SLURM_SUBMIT_DIR"/Rdata

# Load the R module
module load R

# Run R script
Rscript --vanilla array_script.R
