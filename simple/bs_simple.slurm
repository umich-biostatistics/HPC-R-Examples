#!/bin/bash

#SBATCH --job-name=bs_simple
#SBATCH --output=logs/%x/%j.out
#SBATCH --ntasks=1
#SBATCH --time=00:05:00
#SBATCH --mem=1g
#SBATCH --partition=standard
#SBATCH --mail-type=ALL

# ! Make sure to update this with the proper SLURM account!
#SBATCH --account=SLURM_ACCOUNT

mkdir -p logs

ml R/4.4

Rscript --vanilla bs_simple.R
