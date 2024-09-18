#!/bin/bash

#SBATCH --job-name=bs_parallel
#SBATCH --output=log/%x-%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=00:05:00
#SBATCH --account=support

ml R/4.4

Rscript --vanilla bs_parallel.R
