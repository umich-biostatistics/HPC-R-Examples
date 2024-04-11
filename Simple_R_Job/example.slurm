#!/bin/bash
#SBATCH --job-name=hello_world
#SBATCH --time=5:00
#SBATCH --mail-type=Begin,End
#SBATCH --mem=4g
#SBATCH --cpus-per-task=1
#SBATCH --partition=standard

R CMD BATCH --no-save --no-restore script.R
