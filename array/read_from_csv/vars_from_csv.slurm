#!/bin/bash

#SBATCH --job-name=param_array
#SBATCH --output=logs/output_%A_%a.out
#SBATCH --array=1-3
#SBATCH --time=00:10:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G

SCRIPT_DIR="$(find . -type f -name "vars_from_csv.R" -exec dirname {} \;)"
cd "$SCRIPT_DIR" || exit 1

# Path to the CSV file containing parameters
CSV_FILE="params.csv"

# Read the line corresponding to the SLURM_ARRAY_TASK_ID
LINE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${CSV_FILE}")

# Extract parameters from the line
IFS=',' read -r sigma beta_mag <<< "$LINE"

module load R
Rscript vars_from_csv.R --sigma="${sigma}" --beta_mag="${beta_mag}"
