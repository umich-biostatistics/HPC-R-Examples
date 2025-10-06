#!/bin/bash

#SBATCH --job-name=combine_csv
#SBATCH --output=logs/%x/%j.out
#SBATCH --ntasks=1
#SBATCH --time=00:01:00
#SBATCH --mem=1g
#SBATCH --mail-type=FAILED,END

mkdir -p logs

ml R/4.4

Rscript --vanilla combine_csv.R
