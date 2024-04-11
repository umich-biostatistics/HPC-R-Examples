#!/bin/bash

# Simple 10-array job

#SBATCH --job-name=simple_array
#SBATCH --time=5:00
#SBATCH --mail-type=NONE
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --array=1-10
#SBATCH --partition=standard
#SBATCH --output=./s_out/slurm_%j-%a.out

# Create output directories in the current directory, if not existing
mkdir -p ./r_out ./s_out

R CMD BATCH --no-save --no-restore arrayscript.R ./r_out/simple_array_$SLURM_JOB_ID-$SLURM_ARRAY_TASK_ID.Rout
