#!/bin/bash
#SBATCH --job-name=bs_multicore
#SBATCH --output=logs/%x/%j.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=00:15:00
#SBATCH --mem=1G
#SBATCH --partition=standard
#SBATCH --mail-type=FAIL,END
# Replace SLURM_ACCOUNT with your allocation before submitting.
#SBATCH --account=SLURM_ACCOUNT

# Submit from HPC-R-Examples/: sbatch multicore/bs_multicore.slurm
# Stop the job if loading R or running a command fails.
set -e

mkdir -p logs

module load R/4.4

Rscript --vanilla multicore/bs_multicore.R
