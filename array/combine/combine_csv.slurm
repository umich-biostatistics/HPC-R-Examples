#!/bin/bash

#SBATCH --job-name=combine_csv
#SBATCH --output=logs/%j.out
#SBATCH --ntasks=1
#SBATCH --time=00:05:00
#SBATCH --mem=1g
#SBATCH --partition=standard
#SBATCH --mail-type=ALL

# ! Make sure to update this with the proper SLURM account!
#SBATCH --account=SLURM_ACCOUNT

ml Rtidyverse/4.4

Rscript --vanilla combine_csv.R
