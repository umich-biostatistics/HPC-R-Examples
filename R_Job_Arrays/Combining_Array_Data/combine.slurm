#!/bin/bash

# Combine Rdata files in directory defined in combine.R

#SBATCH --job-name=combine
#SBATCH --time=1:00
#SBATCH --mail-type=ALL
#SBATCH --mem=100m
#SBATCH --cpus-per-task=1
#SBATCH --output=s_out/%x_%j.out

# Create directory for Rdata files, if not existing
mkdir -p "$SLURM_SUBMIT_DIR"/Rdata/combined/ "$SLURM_SUBMIT_DIR"/r_out "$SLURM_SUBMIT_DIR"/s_out

# Load the R module
module load R

# Run R script in batch mode and place 
R CMD BATCH --no-save --no-restore combine.R r_out/"$SLURM_JOB_NAME"_"$SLURM_JOB_ID".Rout
