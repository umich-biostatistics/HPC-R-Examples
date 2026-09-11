#!/bin/bash
#SBATCH --job-name=bootstrap_array
#SBATCH --output=logs/%x/%A_%a.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:15:00
#SBATCH --mem=1G
#SBATCH --partition=standard
#SBATCH --mail-type=FAIL,END
# Replace SLURM_ACCOUNT with your allocation before submitting.
#SBATCH --account=SLURM_ACCOUNT
#SBATCH --array=1-4

# Submit from HPC-R-Examples/: sbatch array/bs_array.slurm
# Stop the job if loading R or running a command fails.
set -e

mkdir -p logs

module load R/4.4

Rscript --vanilla array/bs_array.R
