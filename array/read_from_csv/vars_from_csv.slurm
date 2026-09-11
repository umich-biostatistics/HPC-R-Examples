#!/bin/bash
#SBATCH --job-name=param_array
#SBATCH --output=logs/%x/%A_%a.out
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

# Submit from HPC-R-Examples/: sbatch array/read_from_csv/vars_from_csv.slurm
# Stop the job if loading R or running a command fails.
set -e

mkdir -p logs

module load R/4.4

# Each array task reads one row: mean,standard deviation.
line=$(sed -n "${SLURM_ARRAY_TASK_ID}p" array/read_from_csv/params.csv)
IFS=',' read -r mean sd <<< "$line"
Rscript --vanilla array/read_from_csv/vars_from_csv.R "$mean" "$sd"
