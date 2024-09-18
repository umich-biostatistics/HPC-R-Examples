#!/bin/bash

#SBATCH --job-name=bs_simple
#SBATCH --output=log/%x-%x-%j.out
#SBATCH --ntasks=1
#SBATCH --time=00:05:00
#SBATCH --account=support

ml R/4.4

Rscript --vanilla bs_simple.R
