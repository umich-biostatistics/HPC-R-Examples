#!/bin/bash

#SBATCH --job-name=bootstrap_array
#SBATCH --output=logs/%x/%A/bootstrap_%a.out
#SBATCH --array=1-10
#SBATCH --ntasks=1
#SBATCH --time=00:01:00
#SBATCH --mem=1g
#SBATCH --partition=standard
#SBATCH --mail-type=FAILED,END

# ! Make sure to update this with the proper SLURM account!
#SBATCH --account=SLURM_ACCOUNT

mkdir -p logs

ml R/4.4

Rscript --vanilla bs_array.R
