#!/bin/bash

#SBATCH --job-name=bootstrap_array
#SBATCH --output=logs/%x/%A/bootstrap_%a.out
#SBATCH --array=1-10
#SBATCH --ntasks=1
#SBATCH --time=00:01:00
#SBATCH --mem=1g
#SBATCH --mail-type=FAILED,END

mkdir -p logs

ml R/4.4

Rscript --vanilla bs_array.R
