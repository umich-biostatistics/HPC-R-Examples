#!/bin/bash

#SBATCH --job-name=combine_csv
#SBATCH --output=logs/%x/%j.out
#SBATCH --ntasks=1
#SBATCH --time=00:01:00
#SBATCH --mem=1g
#SBATCH --partition=standard
#SBATCH --mail-type=FAILED,END

mkdir -p logs

SCRIPT_DIR="$(find . -type f -name "combine_csv.R" -exec dirname {} \;)"
cd "$SCRIPT_DIR" || exit 1

ml R/4.4

Rscript --vanilla combine_csv.R
