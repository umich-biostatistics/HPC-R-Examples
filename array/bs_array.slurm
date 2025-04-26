#!/bin/bash
#SBATCH --job-name=bootstrap_array
#SBATCH --output=logs/%A/bootstrap_%a.out
#SBATCH --array=1-10
#SBATCH --ntasks=1
#SBATCH --time=00:05:00
#SBATCH --mem=1g
#SBATCH --partition=standard
#SBATCH --mail-type=ALL

# ! Make sure to update this with the proper SLURM account!
#SBATCH --account=SLURM_ACCOUNT

ml R/4.4

Rscript --vanilla bs_array.R
