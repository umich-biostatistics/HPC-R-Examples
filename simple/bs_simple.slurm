#!/bin/bash
#SBATCH --job-name=bs_simple
#SBATCH --output=%x-%j.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00
#SBATCH --mem=1G
#SBATCH --partition=standard
#SBATCH --mail-type=FAIL,END
# Replace SLURM_ACCOUNT with your allocation before submitting.
#SBATCH --account=SLURM_ACCOUNT

set -euo pipefail
# Submit from this example's directory. Slurm preserves that working directory.
module load R/4.4
# Prevent numerical libraries from creating extra threads in each R process.
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
Rscript --vanilla bs_simple.R
