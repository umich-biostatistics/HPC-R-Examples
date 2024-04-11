#!/bin/bash

# Simple 10-array job

#SBATCH --job-name=simple_array
#SBATCH --time=5:00
#SBATCH --mail-type=NONE
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --array=1-10
#SBATCH --partition=standard

mkdir ./r_out

R CMD BATCH --no-save --no-restore arrayscript.R ./r_out/arrayscript_$SLURM_ARRAY_TASK_ID.Rout
