#!/bin/bash
#SBATCH --job-name=array_hello
#SBATCH --time=5:00
#SBATCH --mail-type=NONE
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --array=1-10
#SBATCH --partition=standard
#SBATCH --account=biostat625f23_class

module load Rtidyverse
R CMD BATCH --no-save --no-restore arrayscript.R arrayscript_$SLURM_ARRAY_TASK_ID.Rout
