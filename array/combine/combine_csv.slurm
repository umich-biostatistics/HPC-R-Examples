#!/bin/bash
#SBATCH --job-name=combine_csv
#SBATCH --output=logs/%x/%j.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00
#SBATCH --mem=1G
#SBATCH --partition=standard
#SBATCH --mail-type=FAIL,END
# Replace SLURM_ACCOUNT with your allocation before submitting.
#SBATCH --account=SLURM_ACCOUNT

# Submit from HPC-R-Examples/: sbatch array/combine/combine_csv.slurm
# Stop the job if loading R or running a command fails.
set -e

mkdir -p logs

module load R/4.4

Rscript --vanilla array/combine/combine_csv.R
