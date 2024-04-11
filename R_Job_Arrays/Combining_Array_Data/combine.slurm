#!/bin/bash
#SBATCH --job-name=combine
#SBATCH --time=5:00
#SBATCH --mail-type=NONE
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --partition=standard
#SBATCH --output=./s_out/slurm_%j.out

# Create directory for Rdata files, if not existing
mkdir -p ./Rdata/combined/

R CMD BATCH --no-save --no-restore combine.R ./r_out/combine_$SLURM_JOB_ID.Rout
