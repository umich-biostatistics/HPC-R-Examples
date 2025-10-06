#!/bin/bash

#SBATCH --job-name=bs_multicore
#SBATCH --output=logs/%x/%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=00:05:00
#SBATCH --mem=1g
#SBATCH --mail-type=FAIL,END

mkdir -p logs

ml R/4.4

Rscript --vanilla bs_multicore.R
