#!/bin/bash
#SBATCH --job-name=bootstrap_array
#SBATCH --output=log/bootstrap_%A_%a.out
#SBATCH --array=1-10
#SBATCH --ntasks=1
#SBATCH --time=00:05:00
#SBATCH --account=support

ml R/4.4

Rscript --vanilla bs_array.R
