#!/bin/bash

# Combine Rdata files in directory defined in combine.R

#SBATCH --job-name=combine
#SBATCH --time=1:00
#SBATCH --mail-type=ALL
#SBATCH --mem=100m
#SBATCH --cpus-per-task=1
#SBATCH --output=log/%x_%j.out

# Create directory for Rdata files, if not existing
mkdir -p "$SLURM_SUBMIT_DIR"/Rdata/combined/ "$SLURM_SUBMIT_DIR"/log

# Load the R module
module load R

# Run R script
Rscript --vanilla combine.R
