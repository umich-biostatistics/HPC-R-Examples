#!/bin/bash
#SBATCH --job-name=param_array
#SBATCH --output=%x-%A_%a.out
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00
#SBATCH --mem=1G
#SBATCH --partition=standard
#SBATCH --mail-type=FAIL,END
# Replace SLURM_ACCOUNT with your allocation before submitting.
#SBATCH --account=SLURM_ACCOUNT
#SBATCH --array=1-3

set -euo pipefail
# Submit from this example's directory. Slurm preserves that working directory.
module load R/4.4
# Prevent numerical libraries from creating extra threads in each R process.
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
# Each row supplies a mean and standard deviation; the CSV has no header.
line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" params.csv)
IFS=',' read -r mean sd <<< "$line"
Rscript --vanilla vars_from_csv.R "$mean" "$sd"
