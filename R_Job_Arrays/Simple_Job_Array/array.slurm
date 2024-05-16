#!/bin/bash

# Simple 10-array job

#SBATCH --job-name=simple_array
#SBATCH --time=5:00
#SBATCH --mail-type=NONE
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --array=1-10
#SBATCH --output=./s_out/%x_%A-%a.out

# Make sure to update the following!
#SBATCH --partition=standard
#SBATCH --account=training

# Create output directories in the submission directory, if not existing
mkdir -p $SLURM_SUBMIT_DIR/r_out $SLURM_SUBMIT_DIR/s_out

module load R

# Run arrayscript.R and place stdout in ./r_out/
R CMD BATCH --no-save --no-restore arrayscript.R $SLURM_SUBMIT_DIR/r_out/$SLURM_JOB_NAME_$SLURM_ARRAY_JOB_ID-$SLURM_ARRAY_TASK_ID.Rout
